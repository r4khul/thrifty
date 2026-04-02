import 'account_entity.dart';

/// Domain Repository Interface for [AccountEntity].
///
/// Abstracts data source interactions from domain/presentation layers.
abstract interface class AccountRepository {
  /// Returns a reactive stream of all accounts.
  Stream<List<AccountEntity>> watchAll();

  /// Fetches all accounts once.
  Future<List<AccountEntity>> getAll();

  /// Fetches a single account by [id].
  Future<AccountEntity?> getById(String id);

  /// Upserts an account (creates or updates).
  Future<void> upsert(AccountEntity account);

  /// Deletes an account by [id].
  Future<void> delete(String id);
}
