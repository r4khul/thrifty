import 'package:freezed_annotation/freezed_annotation.dart';

part 'financial_data_models.freezed.dart';

/// Time range filter for financial data.
enum TimeRange { daily, weekly, monthly, yearly }

/// Represents a single data point for income vs expense visualization.
@freezed
abstract class FlowDataPoint with _$FlowDataPoint {
  const factory FlowDataPoint({
    required DateTime date,
    required double income,
    required double expense,
    String? label,
  }) = _FlowDataPoint;

  const FlowDataPoint._();

  /// Net value (income - |expense|)
  double get netValue => income - expense.abs();

  /// Whether this point has any data
  bool get hasData => income > 0 || expense != 0;
}

/// Category spending data for pie/donut chart.
@freezed
abstract class CategorySpend with _$CategorySpend {
  const factory CategorySpend({
    required String categoryId,
    required String categoryName,
    required String categoryIcon,
    required int categoryColor,
    required double amount,
    required double percentage,
    double? budget,
  }) = _CategorySpend;
}

/// Aggregated financial summary for a time period.
@freezed
abstract class FinancialSummary with _$FinancialSummary {
  const factory FinancialSummary({
    required double totalIncome,
    required double totalExpense,
    required double netSavings,
    required double savingsRate,
    required List<FlowDataPoint> flowData,
    required List<CategorySpend> categoryBreakdown,
  }) = _FinancialSummary;

  const FinancialSummary._();

  /// Whether user is in surplus or deficit
  bool get isPositive => netSavings >= 0;
}
