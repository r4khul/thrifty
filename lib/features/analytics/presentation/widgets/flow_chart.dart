import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:thrifty/core/theme/app_colors.dart';
import 'package:thrifty/core/theme/app_typography.dart';
import 'package:thrifty/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../domain/financial_data_models.dart';

/// A finance-grade diverging bar chart for income/expense visualization.
class FlowChart extends StatefulWidget {
  const FlowChart({
    super.key,
    required this.data,
    required this.timeRange,
    this.height = 220,
    this.incomeColor,
    this.expenseColor,
    this.currencySymbol = r'$',
  });

  final List<FlowDataPoint> data;
  final TimeRange timeRange;
  final double height;
  final Color? incomeColor;
  final Color? expenseColor;
  final String currencySymbol;

  @override
  State<FlowChart> createState() => _FlowChartState();
}

class _FlowChartState extends State<FlowChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late ScrollController _scrollController;

  int? _selectedIndex;
  Offset? _tapPosition;

  // Cache bar config to avoid recomputation
  _BarConfig? _cachedConfig;
  TimeRange? _cachedTimeRange;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      // Slightly faster animation for snappier feel
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _scrollController = ScrollController();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(FlowChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeRange != widget.timeRange ||
        oldWidget.data.length != widget.data.length) {
      _selectedIndex = null;
      // Reset cached config on data change
      _cachedConfig = null;
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Cached bar config getter to avoid repeated switch evaluation
  _BarConfig get _barConfig {
    if (_cachedConfig != null && _cachedTimeRange == widget.timeRange) {
      return _cachedConfig!;
    }
    _cachedTimeRange = widget.timeRange;
    _cachedConfig = switch (widget.timeRange) {
      TimeRange.daily => const _BarConfig(
        width: 18,
        spacing: 10,
        cornerRadius: 4,
      ),
      TimeRange.weekly => const _BarConfig(
        width: 28,
        spacing: 14,
        cornerRadius: 5,
      ),
      TimeRange.monthly => const _BarConfig(
        width: 24,
        spacing: 8,
        cornerRadius: 4,
      ),
      TimeRange.yearly => const _BarConfig(
        width: 48,
        spacing: 24,
        cornerRadius: 6,
      ),
    };
    return _cachedConfig!;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.data.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'No data for this period',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.grey500 : AppColors.grey600,
            ),
          ),
        ),
      );
    }

    final config = _barConfig;
    final totalWidth =
        widget.data.length * (config.width + config.spacing) +
        config.spacing +
        32;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: widget.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // The Scrollable Chart
              SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTapDown: (details) =>
                      _handleTap(details.localPosition, config),
                  onTapUp: (_) {},
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return RepaintBoundary(
                        child: CustomPaint(
                          size: Size(totalWidth - 32, widget.height),
                          painter: _FlowChartPainter(
                            data: widget.data,
                            progress: _animation.value,
                            selectedIndex: _selectedIndex,
                            config: config,
                            incomeColor:
                                widget.incomeColor ?? const Color(0xFF10B981),
                            expenseColor:
                                widget.expenseColor ?? const Color(0xFFF43F5E),
                            isDark: isDark,
                            timeRange: widget.timeRange,
                            locale: AppLocalizations.of(context)!.localeName,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              if (_selectedIndex != null && _tapPosition != null)
                AnimatedBuilder(
                  animation: _scrollController,
                  builder: (context, _) {
                    return _buildTooltip(
                      context,
                      widget.data[_selectedIndex!],
                      config,
                      constraints.maxWidth,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleTap(Offset position, _BarConfig config) {
    final adjustedX = position.dx - config.spacing / 2;
    if (adjustedX < 0) return;

    final index = (adjustedX / (config.width + config.spacing)).floor();
    if (index >= 0 && index < widget.data.length) {
      setState(() {
        if (_selectedIndex == index) {
          _selectedIndex = null;
          _tapPosition = null;
        } else {
          _selectedIndex = index;
          _tapPosition = position;
        }
      });
    }
  }

  Widget _buildTooltip(
    BuildContext context,
    FlowDataPoint point,
    _BarConfig config,
    double maxWidth,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const tooltipWidth = 170.0;
    const margin = 8.0;

    final xPos =
        (_selectedIndex! * (config.width + config.spacing)) +
        config.spacing +
        16 -
        _scrollController.offset;

    // Hide tooltip if the bar is not visible in the viewport
    if (xPos + config.width < 0 || xPos > maxWidth) {
      return const SizedBox.shrink();
    }

    // Calculate initial centered position
    var left = xPos + config.width / 2 - (tooltipWidth / 2);

    // Smart clamp to keep tooltip within view bounds
    if (left < margin) {
      left = margin;
    } else if (left + tooltipWidth > maxWidth - margin) {
      left = maxWidth - tooltipWidth - margin;
    }

    return Positioned(
      left: left,
      top: 8,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _selectedIndex != null ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: tooltipWidth,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCard.withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.grey200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  point.label ?? _formatDate(point.date),
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark ? AppColors.grey400 : AppColors.grey500,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 10),
                if (point.income > 0)
                  _buildTooltipRow(
                    AppLocalizations.of(context)!.income,
                    '${widget.currencySymbol}${_formatAmount(point.income)}',
                    const Color(0xFF10B981),
                    isDark,
                  ),
                if (point.income > 0 && point.expense != 0)
                  const SizedBox(height: 6),
                if (point.expense != 0)
                  _buildTooltipRow(
                    AppLocalizations.of(context)!.expense,
                    '${widget.currencySymbol}${_formatAmount(point.expense.abs())}',
                    const Color(0xFFF43F5E),
                    isDark,
                  ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.grey200,
                ),
                const SizedBox(height: 8),
                _buildTooltipRow(
                  AppLocalizations.of(context)!.net,
                  '${point.netValue >= 0 ? '+' : ''}${widget.currencySymbol}${_formatAmount(point.netValue.abs())}',
                  point.netValue >= 0
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF43F5E),
                  isDark,
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTooltipRow(
    String label,
    String value,
    Color color,
    bool isDark, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.grey400 : AppColors.grey600,
                fontSize: 11,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: isBold ? color : (isDark ? Colors.white : AppColors.grey900),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

class _BarConfig {
  const _BarConfig({
    required this.width,
    required this.spacing,
    required this.cornerRadius,
  });

  final double width;
  final double spacing;
  final double cornerRadius;
}

class _FlowChartPainter extends CustomPainter {
  _FlowChartPainter({
    required this.data,
    required this.progress,
    required this.selectedIndex,
    required this.config,
    required this.incomeColor,
    required this.expenseColor,
    required this.isDark,
    required this.timeRange,
    required this.locale,
  });

  final List<FlowDataPoint> data;
  final double progress;
  final int? selectedIndex;
  final _BarConfig config;
  final Color incomeColor;
  final Color expenseColor;
  final bool isDark;
  final TimeRange timeRange;
  final String locale;

  @override
  void paint(Canvas canvas, Size size) {
    const labelHeight = 28.0;
    final chartHeight = size.height - labelHeight;
    final baselineY = chartHeight / 2;

    double maxVal = 0;
    for (var p in data) {
      maxVal = math.max(maxVal, p.income);
      maxVal = math.max(maxVal, p.expense.abs());
    }
    maxVal = maxVal == 0 ? 100 : maxVal * 1.1;

    final halfChartHeight = baselineY;
    final valueToPixels = (halfChartHeight - 16) / maxVal;

    _drawGrid(canvas, size, chartHeight, baselineY, maxVal, valueToPixels);

    final baselinePaint = Paint()
      ..color = isDark ? AppColors.grey700 : AppColors.grey300
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(0, baselineY),
      Offset(size.width, baselineY),
      baselinePaint,
    );

    for (var i = 0; i < data.length; i++) {
      final p = data[i];
      final x = i * (config.width + config.spacing) + config.spacing;

      final staggeredProgress = _staggeredProgress(i, data.length, progress);
      final isOtherSelected = selectedIndex != null && selectedIndex != i;
      final opacity = isOtherSelected ? 0.25 : 1.0;

      if (p.income > 0) {
        final h = p.income * valueToPixels * staggeredProgress;
        final rect = Rect.fromLTWH(x, baselineY - h, config.width, h);
        final rrect = RRect.fromRectAndCorners(
          rect,
          topLeft: Radius.circular(config.cornerRadius),
          topRight: Radius.circular(config.cornerRadius),
        );

        canvas.drawRRect(
          rrect,
          Paint()
            ..color = incomeColor.withValues(alpha: opacity)
            ..style = PaintingStyle.fill,
        );
      }

      if (p.expense != 0) {
        final h = p.expense.abs() * valueToPixels * staggeredProgress;
        final rect = Rect.fromLTWH(x, baselineY, config.width, h);
        final rrect = RRect.fromRectAndCorners(
          rect,
          bottomLeft: Radius.circular(config.cornerRadius),
          bottomRight: Radius.circular(config.cornerRadius),
        );

        canvas.drawRRect(
          rrect,
          Paint()
            ..color = expenseColor.withValues(alpha: opacity)
            ..style = PaintingStyle.fill,
        );
      }

      if (_shouldShowLabel(i, data.length)) {
        final labelText = _getLabel(p, timeRange, locale);
        final tp = TextPainter(
          text: TextSpan(
            text: labelText,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.grey500 : AppColors.grey600,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        )..layout();

        tp.paint(
          canvas,
          Offset(x + (config.width - tp.width) / 2, chartHeight + 8),
        );
      }
    }
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    double chartHeight,
    double baselineY,
    double maxVal,
    double valueToPixels,
  ) {
    final gridPaint = Paint()
      ..color = (isDark ? AppColors.grey800 : AppColors.grey200).withValues(
        alpha: 0.5,
      )
      ..strokeWidth = 0.5;

    const steps = 2;
    for (var i = -steps; i <= steps; i++) {
      if (i == 0) continue;
      final y = baselineY - (i * (maxVal / steps) * valueToPixels);
      if (y >= 0 && y <= chartHeight) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }
  }

  double _staggeredProgress(int index, int total, double progress) {
    const staggerDelay = 0.03;
    final adjustedProgress = (progress - (index * staggerDelay)).clamp(
      0.0,
      1.0,
    );
    return Curves.easeOutBack.transform(adjustedProgress);
  }

  String _getLabel(FlowDataPoint point, TimeRange range, String locale) {
    // Prefer formatting date locally over using point.label (which might be in English)
    switch (range) {
      case TimeRange.daily:
        return DateFormat('E', locale).format(point.date);
      case TimeRange.weekly:
        return DateFormat('MMM d', locale).format(point.date);
      case TimeRange.monthly:
        return DateFormat('MMM', locale).format(point.date);
      case TimeRange.yearly:
        return DateFormat('yyyy', locale).format(point.date);
    }
  }

  bool _shouldShowLabel(int index, int total) {
    if (total <= 8) return true;
    if (total <= 14) return index % 2 == 0;
    return index % 3 == 0;
  }

  @override
  bool shouldRepaint(_FlowChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.data != data ||
        oldDelegate.isDark != isDark;
  }
}
