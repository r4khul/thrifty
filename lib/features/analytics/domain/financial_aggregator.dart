import 'package:intl/intl.dart';

import '../../categories/domain/category_entity.dart';
import '../../transactions/domain/transaction_entity.dart';
import 'financial_data_models.dart';

/// Pure business logic for aggregating financial data.
///
/// Responsibilities:
/// - Grouping transactions by time period.
/// - Computing income/expense flows.
/// - Calculating category breakdowns.
/// - No UI or state management dependencies.
class FinancialAggregator {
  const FinancialAggregator();

  /// Computes a full financial summary for the given transactions and time range.
  FinancialSummary aggregate({
    required List<TransactionEntity> transactions,
    required List<CategoryEntity> categories,
    required TimeRange range,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final filtered = _filterByRange(transactions, range, now);

    final totalIncome = filtered
        .where((t) => t.isIncome)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final totalExpense = filtered
        .where((t) => t.isExpense)
        .fold<double>(0, (sum, t) => sum + t.amount.abs());

    final netSavings = totalIncome - totalExpense;
    final savingsRate = totalIncome > 0
        ? (netSavings / totalIncome) * 100
        : 0.0;

    final flowData = _computeFlowData(filtered, range, now);
    final categoryBreakdown = _computeCategoryBreakdown(filtered, categories);

    return FinancialSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netSavings: netSavings,
      savingsRate: savingsRate,
      flowData: flowData,
      categoryBreakdown: categoryBreakdown,
    );
  }

  List<TransactionEntity> _filterByRange(
    List<TransactionEntity> transactions,
    TimeRange range,
    DateTime now,
  ) {
    final DateTime startDate;
    final DateTime endDate;

    switch (range) {
      case TimeRange.daily:
        // Last 14 days
        startDate = DateTime(now.year, now.month, now.day - 13);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case TimeRange.weekly:
        // Last 8 weeks
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        startDate = weekStart.subtract(const Duration(days: 7 * 7));
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case TimeRange.monthly:
        // This year, all months
        startDate = DateTime(now.year);
        endDate = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
      case TimeRange.yearly:
        // Last 5 years
        startDate = DateTime(now.year - 4);
        endDate = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
    }

    return transactions.where((t) {
      return t.timestamp.isAfter(
            startDate.subtract(const Duration(seconds: 1)),
          ) &&
          t.timestamp.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();
  }

  List<FlowDataPoint> _computeFlowData(
    List<TransactionEntity> transactions,
    TimeRange range,
    DateTime now,
  ) {
    final incomeByKey = <String, double>{};
    final expenseByKey = <String, double>{};
    final dateByKey = <String, DateTime>{};

    // Group transactions by key
    for (final tx in transactions) {
      final key = _getGroupKey(tx.timestamp, range);
      final normalizedDate = _normalizeDate(tx.timestamp, range);

      dateByKey[key] = normalizedDate;

      if (tx.isIncome) {
        incomeByKey[key] = (incomeByKey[key] ?? 0) + tx.amount;
      } else {
        expenseByKey[key] = (expenseByKey[key] ?? 0) + tx.amount.abs();
      }
    }

    // Generate all expected keys (even empty ones)
    final allKeys = _generateAllKeys(range, now);

    final result = <FlowDataPoint>[];
    for (final entry in allKeys) {
      final key = entry.key;
      final date = entry.date;
      final income = incomeByKey[key] ?? 0;
      final expense = expenseByKey[key] ?? 0;

      result.add(
        FlowDataPoint(
          date: date,
          income: income,
          expense: -expense, // Store as negative for diverging chart
          label: entry.label,
        ),
      );
    }

    return result;
  }

  List<CategorySpend> _computeCategoryBreakdown(
    List<TransactionEntity> transactions,
    List<CategoryEntity> categories,
  ) {
    // Only consider expenses for category breakdown
    final expenses = transactions.where((t) => t.isExpense).toList();
    final totalExpense = expenses.fold<double>(
      0,
      (sum, t) => sum + t.amount.abs(),
    );

    if (totalExpense == 0) return [];

    // Group by category
    final amountByCategory = <String, double>{};
    for (final tx in expenses) {
      amountByCategory[tx.categoryId] =
          (amountByCategory[tx.categoryId] ?? 0) + tx.amount.abs();
    }

    // Build category map for lookup
    final categoryMap = {for (var c in categories) c.id: c};

    // Create CategorySpend list
    final spends = <CategorySpend>[];
    for (final entry in amountByCategory.entries) {
      final cat = categoryMap[entry.key];
      if (cat != null) {
        spends.add(
          CategorySpend(
            categoryId: cat.id,
            categoryName: cat.name,
            categoryIcon: cat.icon,
            categoryColor: cat.color,
            amount: entry.value,
            percentage: (entry.value / totalExpense) * 100,
            budget: cat.budget,
          ),
        );
      } else {
        // Handle orphaned transactions (category not found)
        // Create a fallback category entry
        spends.add(
          CategorySpend(
            categoryId: entry.key,
            categoryName: _formatCategoryName(entry.key),
            categoryIcon: 'help_outline',
            categoryColor: 0xFF9E9E9E, // Gray for unknown categories
            amount: entry.value,
            percentage: (entry.value / totalExpense) * 100,
          ),
        );
      }
    }

    // Sort by amount descending
    spends.sort((a, b) => b.amount.compareTo(a.amount));

    // Optionally bucket small categories into "Others"
    if (spends.length > 5) {
      final top5 = spends.take(5).toList();
      final others = spends.skip(5).toList();
      final othersTotal = others.fold<double>(0, (sum, c) => sum + c.amount);
      final othersPercentage = others.fold<double>(
        0,
        (sum, c) => sum + c.percentage,
      );

      top5.add(
        CategorySpend(
          categoryId: 'others',
          categoryName: 'Others',
          categoryIcon: 'more_horiz',
          categoryColor: 0xFF9E9E9E,
          amount: othersTotal,
          percentage: othersPercentage,
        ),
      );
      return top5;
    }

    return spends;
  }

  /// Formats a category ID into a human-readable name.
  /// Handles both simple strings and complex IDs.
  String _formatCategoryName(String categoryId) {
    // If it's a simple word, capitalize it
    if (!categoryId.contains('_') && !categoryId.contains('-')) {
      return categoryId[0].toUpperCase() + categoryId.substring(1);
    }

    // Handle snake_case or kebab-case
    return categoryId
        .split(RegExp(r'[_-]'))
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  String _getGroupKey(DateTime date, TimeRange range) {
    switch (range) {
      case TimeRange.daily:
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case TimeRange.weekly:
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        return '${weekStart.year}-W${_weekNumber(weekStart).toString().padLeft(2, '0')}';
      case TimeRange.monthly:
        return '${date.year}-${date.month.toString().padLeft(2, '0')}';
      case TimeRange.yearly:
        return '${date.year}';
    }
  }

  DateTime _normalizeDate(DateTime date, TimeRange range) {
    switch (range) {
      case TimeRange.daily:
        return DateTime(date.year, date.month, date.day);
      case TimeRange.weekly:
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        return DateTime(weekStart.year, weekStart.month, weekStart.day);
      case TimeRange.monthly:
        return DateTime(date.year, date.month);
      case TimeRange.yearly:
        return DateTime(date.year);
    }
  }

  int _weekNumber(DateTime date) {
    final dayOfYear = int.parse(DateFormat('D').format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  List<_KeyEntry> _generateAllKeys(TimeRange range, DateTime now) {
    final result = <_KeyEntry>[];

    switch (range) {
      case TimeRange.daily:
        // Last 14 days
        for (var i = 13; i >= 0; i--) {
          final date = DateTime(now.year, now.month, now.day - i);
          final key = _getGroupKey(date, range);
          final label = DateFormat('E').format(date);
          result.add(_KeyEntry(key: key, date: date, label: label));
        }
        break;

      case TimeRange.weekly:
        // Last 8 weeks
        final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
        for (var i = 7; i >= 0; i--) {
          final date = currentWeekStart.subtract(Duration(days: 7 * i));
          final key = _getGroupKey(date, range);
          final label = DateFormat('MMM d').format(date);
          result.add(_KeyEntry(key: key, date: date, label: label));
        }
        break;

      case TimeRange.monthly:
        // All months of current year
        for (var month = 1; month <= 12; month++) {
          final date = DateTime(now.year, month);
          final key = _getGroupKey(date, range);
          final label = DateFormat('MMM').format(date);
          result.add(_KeyEntry(key: key, date: date, label: label));
        }
        break;

      case TimeRange.yearly:
        // Last 5 years
        for (var i = 4; i >= 0; i--) {
          final date = DateTime(now.year - i);
          final key = _getGroupKey(date, range);
          final label = date.year.toString();
          result.add(_KeyEntry(key: key, date: date, label: label));
        }
        break;
    }

    return result;
  }
}

class _KeyEntry {
  const _KeyEntry({required this.key, required this.date, required this.label});

  final String key;
  final DateTime date;
  final String label;
}
