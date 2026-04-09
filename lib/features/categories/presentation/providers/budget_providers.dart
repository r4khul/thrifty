import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thrifty/features/categories/domain/category_entity.dart';
import 'package:thrifty/features/categories/presentation/providers/category_providers.dart';
import 'package:thrifty/features/transactions/presentation/providers/transaction_providers.dart';

part 'budget_providers.g.dart';

@riverpod
class BudgetSearchQuery extends _$BudgetSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
Future<Map<String, double>> categoryMonthlySpending(Ref ref) async {
  final transactionsAsync = ref.watch(transactionControllerProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  return transactionsAsync.when(
    data: (transactions) {
      final monthlyTxs = transactions.where((tx) =>
          tx.timestamp.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
          tx.timestamp.isBefore(endOfMonth.add(const Duration(seconds: 1))));

      final spending = <String, double>{};
      for (final tx in monthlyTxs) {
        if (!tx.isIncome) {
          spending[tx.categoryId] = (spending[tx.categoryId] ?? 0) + tx.amount.abs();
        }
      }
      return spending;
    },
    loading: () => <String, double>{},
    error: (_, _) => <String, double>{},
  );
}

@riverpod
Future<List<CategoryEntity>> filteredBudgetCategories(Ref ref) async {
  final categoriesAsync = ref.watch(categoryControllerProvider);
  final query = ref.watch(budgetSearchQueryProvider).toLowerCase();

  return categoriesAsync.when(
    data: (categories) {
      if (query.isEmpty) return categories;
      return categories
          .where((c) => c.name.toLowerCase().contains(query))
          .toList();
    },
    loading: () => [],
    error: (_, _) => [],
  );
}
