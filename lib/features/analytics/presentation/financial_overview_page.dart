import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thrifty/core/theme/app_colors.dart';
import 'package:thrifty/core/theme/app_typography.dart';
import 'package:thrifty/features/settings/presentation/providers/currency_provider.dart';
import 'package:thrifty/l10n/app_localizations.dart';

import '../domain/financial_data_models.dart';
import 'providers/financial_analytics_provider.dart';
import 'widgets/flow_chart.dart';
import 'widgets/summary_cards.dart';
import 'widgets/unified_category_breakdown.dart';

/// The main Financial Overview page.
///
/// Refactored to use a dropdown for time selection and smooth fade transitions.
class FinancialOverviewPage extends ConsumerWidget {
  const FinancialOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedRange = ref.watch(selectedTimeRangeProvider);
    final summaryAsync = ref.watch(financialSummaryProvider);
    final currencyAsync = ref.watch(currencyControllerProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.financialOverview,
          style: AppTypography.titleLarge.copyWith(
            color: isDark ? Colors.white : AppColors.grey900,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : AppColors.grey900,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          _buildRangePicker(context, ref, selectedRange, isDark),
          const SizedBox(width: 8),
        ],
      ),
      body: currencyAsync.when(
        data: (currency) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: KeyedSubtree(
            key: ValueKey(selectedRange),
            child: summaryAsync.when(
              data: (summary) => SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 40),
                child: _buildContent(
                  context,
                  ref,
                  summary,
                  selectedRange,
                  currency.symbol,
                ),
              ),
              loading: () => _buildLoadingState(context),
              error: (error, stack) => _buildErrorState(context, error),
            ),
          ),
        ),
        loading: () => _buildLoadingState(context),
        error: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  Widget _buildRangePicker(
    BuildContext context,
    WidgetRef ref,
    TimeRange current,
    bool isDark,
  ) {
    return PopupMenuButton<TimeRange>(
      initialValue: current,
      onSelected: (range) {
        ref.read(selectedTimeRangeProvider.notifier).setRange(range);
      },
      offset: const Offset(0, 48),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? AppColors.darkCard : Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                current.getLabel(AppLocalizations.of(context)!),
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => TimeRange.values.map((range) {
        final isSelected = current == range;
        return PopupMenuItem<TimeRange>(
          value: range,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  range.getLabel(AppLocalizations.of(context)!),
                  style: AppTypography.bodyMedium.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? Colors.white : AppColors.grey900),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    FinancialSummary summary,
    TimeRange selectedRange,
    String currencySymbol,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Net Savings Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: NetSavingsCard(
            netSavings: summary.netSavings,
            savingsRate: summary.savingsRate,
            isPositive: summary.isPositive,
            currencySymbol: currencySymbol,
          ),
        ),

        const SizedBox(height: 16),

        // Summary Cards Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: AppLocalizations.of(context)!.income,
                  value: '$currencySymbol${_formatAmount(summary.totalIncome)}',
                  icon: Icons.unarchive_rounded,
                  iconColor: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  title: AppLocalizations.of(context)!.expense,
                  value:
                      '$currencySymbol${_formatAmount(summary.totalExpense)}',
                  icon: Icons.archive_rounded,
                  iconColor: const Color(0xFFF43F5E),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Flow Chart Section
        _buildSectionHeader(
          context,
          AppLocalizations.of(context)!.moneyFlow,
          Icons.bar_chart_rounded,
          isDark,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.grey200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: _buildChartLegend(
                              AppLocalizations.of(context)!.income,
                              const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: _buildChartLegend(
                              AppLocalizations.of(context)!.expense,
                              const Color(0xFFF43F5E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (summary.flowData.length > 8)
                      Row(
                        children: [
                          Icon(
                            Icons.swap_horiz_rounded,
                            size: 16,
                            color: isDark
                                ? AppColors.grey500
                                : AppColors.grey400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!.scrollable,
                            style: AppTypography.labelSmall.copyWith(
                              color: isDark
                                  ? AppColors.grey500
                                  : AppColors.grey400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                FlowChart(
                  data: summary.flowData,
                  timeRange: selectedRange,
                  currencySymbol: currencySymbol,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Category Breakdown Section
        if (summary.categoryBreakdown.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            AppLocalizations.of(context)!.whereYourMoneyGoes,
            Icons.donut_large_rounded,
            isDark,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: UnifiedCategoryBreakdown(
              data: summary.categoryBreakdown,
              totalExpense: summary.totalExpense,
              currencySymbol: currencySymbol,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                color: isDark ? Colors.white : AppColors.grey900,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.grey500,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.analyzingFinances,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.couldNotLoadAnalytics,
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(
                color: isDark ? Colors.white : AppColors.grey900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.grey500 : AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

extension TimeRangeX on TimeRange {
  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case TimeRange.daily:
        return l10n.daily;
      case TimeRange.weekly:
        return l10n.weekly;
      case TimeRange.monthly:
        return l10n.monthly;
      case TimeRange.yearly:
        return l10n.yearly;
    }
  }
}
