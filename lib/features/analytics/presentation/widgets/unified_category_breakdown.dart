import 'package:flutter/material.dart';
import 'package:thrifty/core/theme/app_colors.dart';
import 'package:thrifty/core/theme/app_typography.dart';

import '../../../categories/presentation/widgets/category_assets.dart';
import '../../domain/financial_data_models.dart';
import 'category_donut_chart.dart';

/// A unified category breakdown widget that binds a donut chart with a list.
///
/// Features:
/// - Centered donut chart (larger than before).
/// - Interactive list that highlights on chart tap and vice versa.
/// - Detailed progress bars and percentages.
/// - Theme adaptive design.
class UnifiedCategoryBreakdown extends StatefulWidget {
  const UnifiedCategoryBreakdown({
    super.key,
    required this.data,
    required this.totalExpense,
    this.currencySymbol = r'$',
  });

  final List<CategorySpend> data;
  final double totalExpense;
  final String currencySymbol;

  @override
  State<UnifiedCategoryBreakdown> createState() =>
      _UnifiedCategoryBreakdownState();
}

class _UnifiedCategoryBreakdownState extends State<UnifiedCategoryBreakdown> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Centered larger donut chart
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: RepaintBoundary(
              child: CategoryDonutChart(
                data: widget.data,
                totalExpense: widget.totalExpense,
                size: 220, // Increased size
                selectedIndex: _selectedIndex,
                currencySymbol: widget.currencySymbol,
                onSelectionChanged: (index) {
                  setState(() => _selectedIndex = index);
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Interactive Category List as individual cards
        Column(
          children: widget.data.asMap().entries.map((entry) {
            final index = entry.key;
            final cat = entry.value;
            final isSelected = _selectedIndex == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIndex = isSelected ? null : index;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(cat.categoryColor).withValues(alpha: 0.1)
                          : (isDark ? AppColors.darkCard : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Color(cat.categoryColor)
                            : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.grey200),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? Color(cat.categoryColor).withValues(alpha: 0.15)
                              : Colors.black.withValues(
                                  alpha: isDark ? 0.2 : 0.04,
                                ),
                          blurRadius: isSelected ? 16 : 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icon with background
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Color(
                              cat.categoryColor,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            CategoryAssets.getIcon(cat.categoryIcon),
                            size: 22,
                            color: Color(cat.categoryColor),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Name and Progress bar
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.categoryName,
                                style: AppTypography.bodyLarge.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.grey900,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: LinearProgressIndicator(
                                  value: cat.budget != null && cat.budget! > 0
                                      ? (cat.amount / cat.budget!).clamp(
                                          0.0,
                                          1.0,
                                        )
                                      : cat.percentage / 100,
                                  backgroundColor: isDark
                                      ? AppColors.grey800
                                      : AppColors.grey100,
                                  valueColor: AlwaysStoppedAnimation(
                                    cat.budget != null &&
                                            cat.amount > cat.budget!
                                        ? AppColors.error
                                        : Color(cat.categoryColor),
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                              if (cat.budget != null && cat.budget! > 0) ...[
                                const SizedBox(height: 6),
                                Text(
                                  cat.amount > cat.budget!
                                      ? '${widget.currencySymbol}${_formatAmount(cat.amount - cat.budget!)} over budget'
                                      : '${widget.currencySymbol}${_formatAmount(cat.budget! - cat.amount)} left of ${widget.currencySymbol}${_formatAmount(cat.budget!)}',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: cat.amount > cat.budget!
                                        ? AppColors.error
                                        : (isDark
                                              ? AppColors.grey400
                                              : AppColors.grey600),
                                    fontSize: 11,
                                    fontWeight: cat.amount > cat.budget!
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Amount and Percentage
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${widget.currencySymbol}${_formatAmount(cat.amount)}',
                              style: AppTypography.titleMedium.copyWith(
                                color: isDark
                                    ? Colors.white
                                    : AppColors.grey900,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${cat.percentage.toStringAsFixed(1)}%',
                              style: AppTypography.labelSmall.copyWith(
                                color: isSelected
                                    ? Color(cat.categoryColor)
                                    : (isDark
                                          ? AppColors.grey400
                                          : AppColors.grey600),
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(2);
  }
}
