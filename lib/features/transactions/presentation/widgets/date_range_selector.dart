import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thrifty/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/util/theme_extension.dart';
import '../providers/date_filter_provider.dart';

/// Optimized DateRangeSelector with separate widget classes for each chip.
class DateRangeSelector extends ConsumerWidget {
  const DateRangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentFilter = ref.watch(dateFilterControllerProvider);
    final isDark = context.isDarkMode;

    return RepaintBoundary(
      child: SizedBox(
        height: 60,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          cacheExtent: 200,
          children: [
            _FilterChip(
              label: l10n.today,
              isSelected: currentFilter.label == 'Today',
              isDark: isDark,
              onTap: () =>
                  ref.read(dateFilterControllerProvider.notifier).setToday(),
            ),
            _FilterChip(
              label: l10n.thisWeek,
              isSelected: currentFilter.label == 'This Week',
              isDark: isDark,
              onTap: () =>
                  ref.read(dateFilterControllerProvider.notifier).setThisWeek(),
            ),
            _FilterChip(
              label: l10n.thisMonth,
              isSelected: currentFilter.label == 'This Month',
              isDark: isDark,
              onTap: () => ref
                  .read(dateFilterControllerProvider.notifier)
                  .setThisMonth(),
            ),
            _FilterChip(
              label: l10n.thisYear,
              isSelected: currentFilter.label == 'This Year',
              isDark: isDark,
              onTap: () =>
                  ref.read(dateFilterControllerProvider.notifier).setThisYear(),
            ),
            _FilterChip(
              label: l10n.allTime,
              isSelected: currentFilter.label == 'All Time',
              isDark: isDark,
              onTap: () =>
                  ref.read(dateFilterControllerProvider.notifier).setAllTime(),
            ),
            _CustomRangeChip(
              filter: currentFilter,
              isDark: isDark,
              onTap: () => _showRangePicker(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRangePicker(BuildContext context, WidgetRef ref) async {
    final isDark = context.isDarkMode;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final onSurfaceColor = isDark ? Colors.white : Colors.black;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: surfaceColor,
              onSurface: onSurfaceColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref
          .read(dateFilterControllerProvider.notifier)
          .setCustomRange(picked.start, picked.end);
    }
  }
}

/// Optimized filter chip with faster animations and explicit parameters.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Pre-compute colors to minimize work during build
    final backgroundColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.darkCard : AppColors.grey100);
    final borderColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.darkBorder : AppColors.grey200);
    final textColor = isSelected
        ? Colors.white
        : (isDark ? Colors.white70 : AppColors.grey700);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          // Reduced animation duration for snappier feel
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom range chip with date display when selected.
class _CustomRangeChip extends StatelessWidget {
  const _CustomRangeChip({
    required this.filter,
    required this.isDark,
    required this.onTap,
  });

  final DateRangeFilter filter;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = filter.isCustom;

    final l10n = AppLocalizations.of(context)!;
    var label = l10n.customRange;
    if (isSelected) {
      final df = DateFormat('d MMM', l10n.localeName);
      label = '${df.format(filter.start)} - ${df.format(filter.end)}';
    }

    // Pre-compute colors
    final backgroundColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.darkCard : AppColors.grey100);
    final borderColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.darkBorder : AppColors.grey200);
    final contentColor = isSelected
        ? Colors.white
        : (isDark ? Colors.white70 : AppColors.grey700);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.date_range_rounded, size: 16, color: contentColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: contentColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
