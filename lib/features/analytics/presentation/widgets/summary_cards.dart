import 'package:flutter/material.dart';
import 'package:thrifty/core/theme/app_colors.dart';
import 'package:thrifty/core/theme/app_typography.dart';
import 'package:thrifty/core/util/formatting_utils.dart';
import 'package:thrifty/l10n/app_localizations.dart';

/// Summary card widget for displaying financial metrics.
///
/// Features:
/// - Glassmorphic card design.
/// - Icon with colored background.
/// - Animated value display.
/// - Trend indicator (optional).
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.trend,
    this.trendPositive = true,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? trend;
  final bool trendPositive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const Spacer(),
              if (trend != null) _buildTrend(isDark),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.grey400 : AppColors.grey600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: isDark ? Colors.white : AppColors.grey900,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTrend(bool isDark) {
    final color = trendPositive
        ? const Color(0xFF10B981)
        : const Color(0xFFF43F5E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trendPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            trend!,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// A larger summary card for net savings/balance.
class NetSavingsCard extends StatelessWidget {
  const NetSavingsCard({
    super.key,
    required this.netSavings,
    required this.savingsRate,
    required this.isPositive,
    this.currencySymbol = r'$',
  });

  final double netSavings;
  final double savingsRate;
  final bool isPositive;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isPositive
        ? const Color(0xFF10B981)
        : const Color(0xFFF43F5E);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPositive ? Icons.savings_rounded : Icons.warning_rounded,
                  size: 22,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPositive
                          ? AppLocalizations.of(context)!.netSavings
                          : AppLocalizations.of(context)!.netDeficit,
                      style: AppTypography.labelLarge.copyWith(
                        color: isDark ? AppColors.grey300 : AppColors.grey700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPositive
                          ? AppLocalizations.of(
                              context,
                            )!.savingsRateMsg(savingsRate.toStringAsFixed(0))
                          : AppLocalizations.of(context)!.spendingExceedsIncome,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.grey500 : AppColors.grey500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          Text(
            '${isPositive ? '+' : '-'} ${FormattingUtils.formatCompact(netSavings, symbol: currencySymbol)}',
            style: AppTypography.displayMedium.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w800,
              fontSize: 36,
              letterSpacing: -1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
