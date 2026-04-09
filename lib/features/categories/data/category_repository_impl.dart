import 'dart:async';
import '../../../core/database/daos/category_dao.dart';
import '../../../core/database/daos/transaction_dao.dart';
import '../../../core/database/database.dart';
import '../../../core/error/failures.dart';
import '../../transactions/domain/transaction_repository.dart';
import '../domain/category_entity.dart';
import '../domain/category_repository.dart';
import 'category_remote_data_source.dart';

/// Categories Feature Data: Implementation with explicit error handling.
class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(
    this._categoryDao,
    this._transactionDao,
    this._db,
    this._remoteDataSource,
  );

  final CategoryDao _categoryDao;
  final TransactionDao _transactionDao;
  final AppDatabase _db;
  final CategoryRemoteDataSource _remoteDataSource;

  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  SyncStatus _currentStatus = SyncStatus.idle;
  Completer<void>? _activeSync;

  @override
  Stream<SyncStatus> get syncStatus async* {
    yield _currentStatus;
    yield* _syncStatusController.stream;
  }

  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
  }

  @override
  void dispose() {
    _syncStatusController.close();
  }

  @override
  Future<List<CategoryEntity>> getAll() async {
    try {
      final rows = await _categoryDao.getAll();
      return rows.map(_toEntity).toList();
    } on Object catch (_) {
      throw const DatabaseFailure(
        'Could not load categories. Ensure database health.',
      );
    }
  }

  @override
  Stream<List<CategoryEntity>> watchAll() {
    return _categoryDao.watchAll().map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<CategoryEntity?> getById(String id) async {
    try {
      final row = await _categoryDao.getById(id);
      return row != null ? _toEntity(row) : null;
    } on Object catch (_) {
      throw const DatabaseFailure('Failed to retrieve category details.');
    }
  }

  @override
  Stream<CategoryEntity?> watchById(String id) {
    return _categoryDao
        .watchById(id)
        .map((row) => row != null ? _toEntity(row) : null);
  }

  @override
  Future<void> upsert(CategoryEntity category) async {
    try {
      await _categoryDao.upsert(_toRow(category));
    } on Object catch (_) {
      throw const DatabaseFailure('Failed to save category.');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      // Logic for strict deletion: check usage first (handled at service/controller level usually,
      // but let's implement the base delete here).
      await _categoryDao.deleteById(id);
    } on Object catch (_) {
      throw const DatabaseFailure('Failed to remove category.');
    }
  }

  @override
  Future<bool> isCategoryUsed(String id) async {
    try {
      return await _categoryDao.isUsed(id);
    } on Object catch (_) {
      return true; // Conservative approach on error
    }
  }

  @override
  Future<void> deleteWithTransactions(String id) async {
    try {
      // Use transaction for atomicity
      await _db.transaction(() async {
        await _transactionDao.deleteByCategoryId(id);
        await _categoryDao.deleteById(id);
      });
    } on Object catch (_) {
      throw const DatabaseFailure(
        'Failed to remove category and its transactions.',
      );
    }
  }

  @override
  Future<void> reassignAndAndDelete(String oldId, String newId) async {
    try {
      await _db.transaction(() async {
        await _transactionDao.reassignCategoryId(oldId, newId);
        await _categoryDao.deleteById(oldId);
      });
    } on Object catch (_) {
      throw const DatabaseFailure(
        'Failed to reassign transactions and remove category.',
      );
    }
  }

  @override
  Future<void> syncWithRemote() async {
    if (_activeSync != null) return _activeSync!.future;

    _activeSync = Completer<void>();
    _updateStatus(SyncStatus.syncing);

    try {
      // 1. Push Phase: Pick up local changes and replicate to remote.
      final editedLocally = await _categoryDao.getEditedLocally();
      for (final row in editedLocally) {
        await _remoteDataSource.push(_toEntity(row));
        // On success, clear the local dirtiness flag.
        await _categoryDao.clearEditedLocally(row.id);
      }

      // 2. Pull Phase: Fetch remote state and merge into local.
      final remoteRecords = await _remoteDataSource.fetchAll();
      for (final remote in remoteRecords) {
        final localRow = await _categoryDao.getById(remote.id);

        if (localRow == null) {
          // Rule: Insert remote records not present locally.
          await _categoryDao.upsert(
            _toRow(remote).copyWith(editedLocally: false),
          );
        } else {
          final local = _toEntity(localRow);
          // Last-write-wins logic using updatedAt
          final localUpdated = local.updatedAt;
          final remoteUpdated = remote.updatedAt;

          if (!local.editedLocally) {
            // If local is not dirty, remote wins if it's newer or if local has no info
            if (remoteUpdated != null &&
                (localUpdated == null || remoteUpdated.isAfter(localUpdated))) {
              await _categoryDao.upsert(
                _toRow(remote).copyWith(editedLocally: false),
              );
            }
          } else {
            // Rule: Preserve locally edited records over remote.
            // Requirement states: "Preserve locally edited records over remote."
            // But also: "Apply last-write-wins using timestamps."
            // I'll stick to preserving local if editedLocally == true,
            // UNLESS remote is strictly newer (last-write-wins).
            if (remoteUpdated != null &&
                localUpdated != null &&
                remoteUpdated.isAfter(localUpdated)) {
              await _categoryDao.upsert(
                _toRow(remote).copyWith(editedLocally: false),
              );
            }
          }
        }
      }

      _updateStatus(SyncStatus.idle);
      _activeSync?.complete();
    } on Failure catch (e) {
      _updateStatus(SyncStatus.failed);
      _activeSync?.completeError(e);
      rethrow;
    } on Object catch (e) {
      _updateStatus(SyncStatus.failed);
      final failure = SyncFailure('Category sync failed: $e');
      _activeSync?.completeError(failure);
      throw failure;
    } finally {
      _activeSync = null;
    }
  }

  /// Maps Database Row to Domain Entity.
  CategoryEntity _toEntity(Category row) {
    return CategoryEntity(
      id: row.id,
      name: row.name,
      icon: row.icon,
      color: row.color,
      budget: row.budget,
      editedLocally: row.editedLocally,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
    );
  }

  /// Maps Domain Entity to Database Row.
  Category _toRow(CategoryEntity entity) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Category(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      color: entity.color,
      budget: entity.budget,
      editedLocally: true, // Default to true for local changes
      createdAt: entity.updatedAt?.millisecondsSinceEpoch ?? now,
      updatedAt: now,
    );
  }
}
