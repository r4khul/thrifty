import '../../../core/database/daos/account_dao.dart';
import '../../../core/database/database.dart';
import '../../../core/error/failures.dart';
import '../domain/account_entity.dart';
import '../domain/account_repository.dart';

/// Data Layer: Implementation of [AccountRepository].
/// Maps between Drift DB rows and domain entities.
class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this._dao);

  final AccountDao _dao;

  @override
  Stream<List<AccountEntity>> watchAll() {
    return _dao.watchAll().map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<List<AccountEntity>> getAll() async {
    try {
      final rows = await _dao.getAll();
      return rows.map(_toEntity).toList();
    } on Object catch (_) {
      throw const DatabaseFailure(
        'Failed to fetch accounts from local storage.',
      );
    }
  }

  @override
  Future<AccountEntity?> getById(String id) async {
    try {
      final row = await _dao.getById(id);
      return row == null ? null : _toEntity(row);
    } on Object catch (_) {
      throw const DatabaseFailure('Failed to retrieve account details.');
    }
  }

  @override
  Future<void> upsert(AccountEntity account) async {
    try {
      await _dao.upsert(_toRow(account));
    } on Object catch (_) {
      throw const DatabaseFailure('Failed to save account locally.');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dao.deleteById(id);
    } on Object catch (_) {
      throw const DatabaseFailure('Failed to delete account.');
    }
  }

  // ─── Mapping Helpers ────────────────────────────────────────────────────────

  AccountEntity _toEntity(Account row) {
    return AccountEntity(
      id: row.id,
      name: row.name,
      bankName: row.bankName,
      type: AccountType.fromString(row.type),
      balance: row.balance,
      colorValue: row.colorValue,
      iconCodePoint: row.iconCodePoint,
      editedLocally: row.editedLocally,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
    );
  }

  Account _toRow(AccountEntity entity) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Account(
      id: entity.id,
      name: entity.name,
      bankName: entity.bankName,
      type: entity.type.name,
      balance: entity.balance,
      colorValue: entity.colorValue,
      iconCodePoint: entity.iconCodePoint,
      editedLocally: entity.editedLocally,
      createdAt: entity.createdAt?.millisecondsSinceEpoch ?? now,
      updatedAt: now,
    );
  }
}
