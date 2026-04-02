import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'account_dao.g.dart';

/// DAO for [Accounts] table.
/// Responsibility: Low-level database operations for accounts.
@DriftAccessor(tables: [Accounts])
class AccountDao extends DatabaseAccessor<AppDatabase> with _$AccountDaoMixin {
  AccountDao(super.db);

  /// Reactive stream of all account rows ordered by createdAt asc.
  Stream<List<Account>> watchAll() {
    return (select(
      accounts,
    )..orderBy([(a) => OrderingTerm.asc(a.createdAt)])).watch();
  }

  /// Fetches all accounts once.
  Future<List<Account>> getAll() {
    return (select(
      accounts,
    )..orderBy([(a) => OrderingTerm.asc(a.createdAt)])).get();
  }

  /// Fetches a single account by [id].
  Future<Account?> getById(String id) {
    return (select(accounts)..where((a) => a.id.equals(id))).getSingleOrNull();
  }

  /// Reactive stream of a single account by [id].
  Stream<Account?> watchById(String id) {
    return (select(
      accounts,
    )..where((a) => a.id.equals(id))).watchSingleOrNull();
  }

  /// Upserts an account row (insert or replace on conflict).
  Future<void> upsert(Account row) {
    return into(accounts).insertOnConflictUpdate(row);
  }

  /// Deletes an account row by [id].
  Future<int> deleteById(String id) {
    return (delete(accounts)..where((a) => a.id.equals(id))).go();
  }
}
