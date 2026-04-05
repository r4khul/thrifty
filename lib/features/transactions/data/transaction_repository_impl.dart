import 'dart:async';
import '../../../core/database/daos/attachment_dao.dart';
import '../../../core/database/daos/transaction_dao.dart';
import '../../../core/database/database.dart';
import '../../../core/error/failures.dart';
import '../domain/attachment_entity.dart';
import '../domain/transaction_entity.dart';
import '../domain/transaction_repository.dart';
import 'transaction_remote_data_source.dart';

/// Transactions Feature Data: Implementation of TransactionRepository.
/// Orchestrates data flow with explicit error handling for local persistence.
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(
    this._transactionDao,
    this._attachmentDao,
    this._remoteDataSource,
  );

  final TransactionDao _transactionDao;
  final AttachmentDao _attachmentDao;
  final TransactionRemoteDataSource _remoteDataSource;

  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  SyncStatus _currentStatus = SyncStatus.idle;
  Completer<void>? _activeSync;

  @override
  Stream<SyncStatus> get syncStatus async* {
    yield _currentStatus;
    yield* _syncStatusController.stream;
  }

  @override
  void dispose() {
    _syncStatusController.close();
  }

  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
  }

  @override
  Future<List<TransactionEntity>> getAll() async {
    try {
      final rows = await _transactionDao.getAll();
      return rows.map(_toEntity).toList();
    } on Object catch (_) {
      throw const DatabaseFailure(
        'Failed to fetch transactions from local storage.',
      );
    }
  }

  @override
  Stream<List<TransactionEntity>> watchAll() {
    return _transactionDao.watchAll().map(
      (rows) => rows.map(_toEntity).toList(),
    );
  }

  @override
  Stream<List<TransactionEntity>> watchInRange(DateTime start, DateTime end) {
    return _transactionDao
        .watchInRange(start, end)
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<TransactionEntity?> getById(String id) async {
    try {
      final row = await _transactionDao.getById(id);
      if (row == null) return null;

      final attachmentRows = await _attachmentDao.getByTransactionId(id);
      return _toEntity(
        row,
      ).copyWith(attachments: attachmentRows.map(_toAttachmentEntity).toList());
    } on Object catch (_) {
      throw const DatabaseFailure('Failed to retrieve transaction details.');
    }
  }

  @override
  Stream<TransactionEntity?> watchById(String id) {
    return _transactionDao.watchById(id).asyncMap((row) async {
      if (row == null) return null;
      final attachments = await _attachmentDao.getByTransactionId(id);
      return _toEntity(
        row,
      ).copyWith(attachments: attachments.map(_toAttachmentEntity).toList());
    });
  }

  @override
  Future<void> upsert(TransactionEntity transaction) async {
    try {
      // Upsert transaction row
      await _transactionDao.upsert(_toRow(transaction));

      // Handle attachments
      // Handle attachments with diff-based updates
      final existing = await _attachmentDao.getByTransactionId(transaction.id);
      final newIds = transaction.attachments.map((a) => a.id).toSet();

      // Delete removed attachments
      for (final a in existing) {
        if (!newIds.contains(a.id)) {
          await _attachmentDao.deleteAttachment(a.id);
        }
      }

      // Upsert current attachments (new or updated)
      for (final attachment in transaction.attachments) {
        // Since drift's insertOnConflictUpdate might be heavy if no change,
        // strictly we could check dirty state, but this is safe and cleaner than delete-all.
        await _attachmentDao.insertAttachment(_toAttachmentRow(attachment));
      }
    } on Object catch (_) {
      throw const DatabaseFailure('Failed to save transaction locally.');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      // Explicitly delete attachments first to avoid FK constraint violations
      // and ensure clean cleanup.
      final existing = await _attachmentDao.getByTransactionId(id);
      for (final a in existing) {
        await _attachmentDao.deleteAttachment(a.id);
      }

      await _transactionDao.deleteById(id);
    } on Object catch (_) {
      throw const DatabaseFailure('Failed to remove transaction.');
    }
  }

  @override
  Future<void> syncWithRemote() async {
    if (_activeSync != null) return _activeSync!.future;

    _activeSync = Completer<void>();
    _updateStatus(SyncStatus.syncing);

    try {
      // 1. Push Phase: Pick up local changes and replicate to remote.
      final editedLocally = await _transactionDao.getEditedLocally();
      for (final row in editedLocally) {
        await _remoteDataSource.push(_toEntity(row));
        // On success, clear the local dirtiness flag.
        await _transactionDao.clearEditedLocally(row.id);
      }

      // 2. Pull Phase: Fetch remote state and merge into local.
      final remoteRecords = await _remoteDataSource.fetchAll();
      for (final remote in remoteRecords) {
        final localRow = await _transactionDao.getById(remote.id);

        if (localRow == null) {
          // Rule: Insert remote records not present locally.
          await _transactionDao.upsert(
            _toRow(remote).copyWith(editedLocally: false),
          );
        } else {
          final local = _toEntity(localRow);
          final localUpdated = local.updatedAt;
          final remoteUpdated = remote.updatedAt;

          if (!local.editedLocally) {
            // If local is not dirty, remote wins if it's newer or local has no info
            if (remoteUpdated != null &&
                (localUpdated == null || remoteUpdated.isAfter(localUpdated))) {
              await _transactionDao.upsert(
                _toRow(remote).copyWith(editedLocally: false),
              );
            }
          } else {
            // Rule: Preserve locally edited records over remote unless remote is strictly newer.
            if (remoteUpdated != null &&
                localUpdated != null &&
                remoteUpdated.isAfter(localUpdated)) {
              await _transactionDao.upsert(
                _toRow(remote).copyWith(editedLocally: false),
              );
            }
          }
        }
      }

      _updateStatus(SyncStatus.idle);
      _activeSync?.complete();
    } on Failure catch (e) {
      // Surface domain failures with state update
      _updateStatus(SyncStatus.failed);
      _activeSync?.completeError(e);
      rethrow;
    } on Object catch (e) {
      // Catch unexpected errors, wrap in SyncFailure, update state
      _updateStatus(SyncStatus.failed);
      final failure = SyncFailure('Sync failed due to unexpected error: $e');
      _activeSync?.completeError(failure);
      throw failure;
    } finally {
      _activeSync = null;
    }
  }

  /// Maps Database Row to Domain Entity.
  /// Ignores infra-only fields (createdAt, updatedAt).
  TransactionEntity _toEntity(Transaction row) {
    return TransactionEntity(
      id: row.id,
      amount: row.amount,
      categoryId: row.categoryId,
      accountId: row.accountId,
      timestamp: DateTime.fromMillisecondsSinceEpoch(row.timestamp),
      note: row.note,
      editedLocally: row.editedLocally,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
    );
  }

  /// Maps Domain Entity to Database Row.
  /// Sets editedLocally = true for local lifecycle management.
  Transaction _toRow(TransactionEntity entity) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Transaction(
      id: entity.id,
      amount: entity.amount,
      categoryId: entity.categoryId,
      accountId: entity.accountId,
      timestamp: entity.timestamp.millisecondsSinceEpoch,
      note: entity.note,
      editedLocally: true, // Mark as edited locally on save/update
      createdAt: entity.updatedAt?.millisecondsSinceEpoch ?? now,
      updatedAt: now,
    );
  }

  AttachmentEntity _toAttachmentEntity(Attachment row) {
    return AttachmentEntity(
      id: row.id,
      transactionId: row.transactionId,
      fileName: row.fileName,
      filePath: row.filePath,
      mimeType: row.mimeType,
      sizeBytes: row.sizeBytes,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    );
  }

  Attachment _toAttachmentRow(AttachmentEntity entity) {
    return Attachment(
      id: entity.id,
      transactionId: entity.transactionId,
      fileName: entity.fileName,
      filePath: entity.filePath,
      mimeType: entity.mimeType,
      sizeBytes: entity.sizeBytes,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
    );
  }
}
