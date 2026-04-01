import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:thrifty/core/theme/app_colors.dart';
import 'package:thrifty/core/widgets/charts/chart_types.dart';
import 'package:thrifty/core/widgets/charts/diverging_bar_chart.dart';
import 'package:thrifty/features/transactions/presentation/providers/analytics_provider.dart';
import 'package:thrifty/l10n/app_localizations.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  ChartPeriod _selectedPeriod = ChartPeriod.daily;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chartDataAsync = ref.watch(
      aggregatedChartDataProvider(_selectedPeriod),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analytics),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: chartDataAsync.when(
        data: (List<ChartPoint> chartData) {
          if (chartData.isEmpty) {
            return Center(child: Text(l10n.noTransactionsAnalyze));
          }

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.financialOverview,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 16),
                _PeriodSelector(
                  selected: _selectedPeriod,
                  onChanged: (period) =>
                      setState(() => _selectedPeriod = period),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Container(
                          height: 300,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.incomeVsExpense,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  // Could add totals here
                                ],
                              ),
                              const SizedBox(height: 24),
                              Expanded(
                                child: DivergingBarChart(
                                  data: chartData,
                                  period: _selectedPeriod,
                                  incomeColor: AppColors.success,
                                  expenseColor: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object err, StackTrace stack) =>
            Center(child: Text('${l10n.error}: $err')),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onChanged});

  final ChartPeriod selected;
  final ValueChanged<ChartPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ChartPeriod.values.map((period) {
          final isSelected = selected == period;
          String label;
          switch (period) {
            case ChartPeriod.daily:
              label = l10n.daily;
              break;
            case ChartPeriod.weekly:
              label = l10n.weekly;
              break;
            case ChartPeriod.monthly:
              label = l10n.monthly;
              break;
            case ChartPeriod.yearly:
              label = l10n.yearly;
              break;
          }
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label.toUpperCase()),
              selected: isSelected,
              onSelected: (_) => onChanged(period),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : AppColors.grey600,
              ),
              selectedColor: AppColors.primary,
              backgroundColor: Theme.of(context).cardColor,
              // Remove checkmark
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : AppColors.grey300,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
