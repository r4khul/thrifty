import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'transaction_dao.g.dart';

/// DAO for [Transactions] table.
/// Responsibility: Direct low-level database operations for transactions using data rows.
@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  /// Retrieves all transaction rows ordered by timestamp descending.
  Future<List<Transaction>> getAll() {
    return (select(
      transactions,
    )..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).get();
  }

  /// Reactive stream of all transaction rows ordered by timestamp descending.
  Stream<List<Transaction>> watchAll() {
    return (select(
      transactions,
    )..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();
  }

  /// Reactive stream of transactions within a date range.
  Stream<List<Transaction>> watchInRange(DateTime start, DateTime end) {
    return (select(transactions)
          ..where(
            (t) => t.timestamp.isBetweenValues(
              start.millisecondsSinceEpoch,
              end.millisecondsSinceEpoch,
            ),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .watch();
  }

  /// Fetches a specific transaction row by its [id].
  Future<Transaction?> getById(String id) {
    return (select(
      transactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Reactive stream of a single transaction row.
  Stream<Transaction?> watchById(String id) {
    return (select(
      transactions,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Upserts a transaction row (inserts or replaces on conflict).
  Future<void> upsert(Transaction row) {
    return into(transactions).insertOnConflictUpdate(row);
  }

  /// Deletes a transaction row by its [id].
  Future<int> deleteById(String id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  /// Retrieves all transaction rows that have been edited locally.
  Future<List<Transaction>> getEditedLocally() {
    return (select(
      transactions,
    )..where((t) => t.editedLocally.equals(true))).get();
  }

  /// Clears the editedLocally flag for a specific transaction.
  Future<void> clearEditedLocally(String id) {
    return (update(transactions)..where((t) => t.id.equals(id))).write(
      const TransactionsCompanion(editedLocally: Value(false)),
    );
  }

  /// Deletes all transactions associated with a specific category.
  Future<int> deleteByCategoryId(String categoryId) {
    return (delete(
      transactions,
    )..where((t) => t.categoryId.equals(categoryId))).go();
  }

  /// Reassigns all transactions from one category to another.
  Future<int> reassignCategoryId(String oldCategoryId, String newCategoryId) {
    return (update(transactions)
          ..where((t) => t.categoryId.equals(oldCategoryId)))
        .write(TransactionsCompanion(categoryId: Value(newCategoryId)));
  }

  /// Calculates total expense for a specific category within a date range.
  Future<double> getCategorySpendingInRange(
    String categoryId,
    DateTime start,
    DateTime end,
  ) async {
    final amount = transactions.amount;
    final query = selectOnly(transactions)
      ..addColumns([amount.sum()])
      ..where(
        transactions.categoryId.equals(categoryId) &
            transactions.timestamp.isBetweenValues(
              start.millisecondsSinceEpoch,
              end.millisecondsSinceEpoch,
            ) &
            transactions.amount.isSmallerThanValue(0.0),
      );

    final result = await query.map((row) => row.read(amount.sum())).getSingle();
    return (result ?? 0.0).abs();
  }
}
