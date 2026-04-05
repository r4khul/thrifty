import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../data/transaction_repository_provider.dart';
import '../../domain/transaction_entity.dart';
import 'date_filter_provider.dart';

part 'transaction_providers.g.dart';

/// Feature State: Manages the collection of transactions.
/// Responsibility: Provides an observable list of transactions and handles mutative actions.
/// Ownership: Owns the transaction logic; calls repository only.
@riverpod
class TransactionController extends _$TransactionController {
  @override
  Stream<List<TransactionEntity>> build() async* {
    final repository = ref.watch(transactionRepositoryProvider);

    // Initial sync logic: if local DB is empty, try to pull from server
    try {
      final transactions = await repository.getAll();
      if (transactions.isEmpty) {
        try {
          await repository.syncWithRemote();
        } on Object catch (_) {
          // Silent failure for sync, repo handles status updates
        }
      }
    } on Object catch (_) {
      // Basic protection against DB init issues
    }

    yield* repository.watchAll();
  }

  /// Retries loading transactions.
  void refresh() {
    ref.invalidateSelf();
  }

  Future<void> upsertTransaction(
    TransactionEntity transaction, {
    required bool isIncome,
  }) async {
    final repository = ref.read(transactionRepositoryProvider);
    var tx = transaction;

    // Handle ID generation if new
    if (tx.id.isEmpty) {
      tx = tx.copyWith(id: const Uuid().v4());
    }

    // Handle amount sign based on business rules
    final absAmount = tx.amount.abs();
    tx = tx.copyWith(amount: isIncome ? absAmount : -absAmount);

    await repository.upsert(tx);
  }

  /// Deletes a transaction by ID.
  Future<void> deleteTransaction(String id) async {
    await ref.read(transactionRepositoryProvider).delete(id);
  }
}

/// Feature State: Exposes a single transaction by its ID.
@riverpod
Stream<TransactionEntity?> transactionById(Ref ref, String id) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchById(id);
}

@riverpod
class AccountFilterController extends _$AccountFilterController {
  @override
  String? build() => null;

  void selectAccount(String? accountId) {
    state = accountId;
  }
}

@riverpod
Stream<List<TransactionEntity>> filteredTransactions(Ref ref) {
  final filter = ref.watch(dateFilterControllerProvider);
  final accountId = ref.watch(accountFilterControllerProvider);
  final repository = ref.watch(transactionRepositoryProvider);
  
  return repository.watchInRange(filter.start, filter.end).map((txs) {
    if (accountId == null) return txs;
    return txs.where((t) => t.accountId == accountId).toList();
  });
}
