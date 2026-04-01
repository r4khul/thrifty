import 'package:flutter/material.dart';
import 'package:thrifty/core/theme/app_colors.dart';
import 'package:thrifty/core/theme/app_typography.dart';

import '../../domain/financial_data_models.dart';

/// A segmented control for selecting time ranges.
///
/// Features:
/// - Animated sliding indicator.
/// - Pill-style segments.
/// - Clear active state.
class TimeRangeSelector extends StatelessWidget {
  const TimeRangeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TimeRange selected;
  final ValueChanged<TimeRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.grey100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TimeRange.values.map((range) {
          final isSelected = selected == range;

          return GestureDetector(
            onTap: () => onChanged(range),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.grey800 : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.2 : 0.06,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                _getLabel(range),
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected
                      ? (isDark ? Colors.white : AppColors.grey900)
                      : (isDark ? AppColors.grey500 : AppColors.grey600),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getLabel(TimeRange range) {
    switch (range) {
      case TimeRange.daily:
        return 'Day';
      case TimeRange.weekly:
        return 'Week';
      case TimeRange.monthly:
        return 'Month';
      case TimeRange.yearly:
        return 'Year';
    }
  }
}
