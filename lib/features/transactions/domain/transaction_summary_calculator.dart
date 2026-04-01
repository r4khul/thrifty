import 'package:thrifty/features/transactions/domain/transaction_entity.dart';
import 'package:thrifty/features/transactions/domain/transaction_summary.dart';

/// Pure logic for calculating transaction summaries.
class TransactionSummaryCalculator {
  const TransactionSummaryCalculator();

  /// Calculates the monthly summary for a given year and month.
  ///
  /// Filters the [transactions] by [year] and [month] based on their timestamp.
  /// Returns a [TransactionSummary] containing total income, total expense,
  /// net amount, and a breakdown of expenses by category.
  TransactionSummary calculateMonthlySummary({
    required List<TransactionEntity> transactions,
    required int year,
    required int month,
  }) {
    // 1. Filter transactions by year and month
    final filteredTransactions = transactions.where((t) {
      return t.timestamp.year == year && t.timestamp.month == month;
    }).toList();

    var totalIncome = 0.0;
    var totalExpense = 0.0;
    final categoryBreakdown = <String, double>{};

    for (final transaction in filteredTransactions) {
      final amount = transaction.amount;

      if (amount > 0) {
        // Income
        totalIncome += amount;
      } else if (amount < 0) {
        // Expense
        final absAmount = amount.abs();
        totalExpense += absAmount;

        // Group by category (Expense-only)
        final categoryId = transaction.categoryId;
        categoryBreakdown.update(
          categoryId,
          (currentSum) => currentSum + absAmount,
          ifAbsent: () => absAmount,
        );
      }
      // Neutral (0) is ignored as per rules
    }

    // Net = Income - Expense (Expense is positive here, so we subtract it)
    // Wait, the requirement says "net = income - expense"
    // "totalExpense = sum of absolute values of negative amounts"
    // So if INCOME is 100, EXPENSE is -50 (abs 50), NET should be 100 - 50 = 50.
    final net = totalIncome - totalExpense;

    return TransactionSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      net: net,
      categoryBreakdown: categoryBreakdown,
    );
  }
}
