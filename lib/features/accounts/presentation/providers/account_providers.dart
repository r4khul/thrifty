import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../data/account_repository_provider.dart';
import '../../domain/account_entity.dart';

part 'account_providers.g.dart';

/// Feature State: Reactive stream of all accounts.
@riverpod
class AccountController extends _$AccountController {
  @override
  Stream<List<AccountEntity>> build() {
    final repository = ref.watch(accountRepositoryProvider);
    return repository.watchAll();
  }

  /// Upserts an account (create or update).
  Future<void> upsertAccount(AccountEntity account) async {
    final repository = ref.read(accountRepositoryProvider);
    var acc = account;

    // Generate ID for new accounts
    if (acc.id.isEmpty) {
      acc = acc.copyWith(id: const Uuid().v4(), createdAt: DateTime.now());
    }

    await repository.upsert(acc);
  }

  /// Deletes an account by [id].
  Future<void> deleteAccount(String id) async {
    await ref.read(accountRepositoryProvider).delete(id);
  }
}
