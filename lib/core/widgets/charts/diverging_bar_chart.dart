import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:thrifty/core/theme/app_colors.dart';
import 'package:thrifty/core/theme/app_typography.dart';
import 'package:thrifty/core/util/formatting_utils.dart';
import 'package:thrifty/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'chart_types.dart';

/// A professional, finance-grade diverging bar chart with a perfectly centered zero baseline.
///
/// Designed to meet high-end dashboard standards (Stripe/Linear style).
/// Features:
/// - Perfectly centered zero baseline.
/// - Symmetrical income (up) and expense (down) bars.
/// - Seamless baseline-out animations.
/// - Interactive hover states with floating tooltips.
/// - Visual density control for various time periods.
class DivergingBarChart extends StatefulWidget {
  const DivergingBarChart({
    super.key,
    required this.data,
    this.period = ChartPeriod.daily,
    this.height = 240,
    this.incomeColor,
    this.expenseColor,
    this.labelColor,
    this.showGrid = true,
  });

  final List<ChartPoint> data;
  final ChartPeriod period;
  final double height;
  final Color? incomeColor;
  final Color? expenseColor;
  final Color? labelColor;
  final bool showGrid;

  @override
  State<DivergingBarChart> createState() => _DivergingBarChartState();
}

class _DivergingBarChartState extends State<DivergingBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ScrollController _scrollController;
  int? _hoveredIndex;
  Offset? _hoverPosition;

  // Throttle hover updates to prevent jank
  DateTime? _lastHoverUpdate;
  static const _hoverThrottleMs = 16; // ~60fps max

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // Faster animation for snappier feel
      duration: const Duration(milliseconds: 700),
    );
    _scrollController = ScrollController();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _BarSettings _getBarSettings(ChartPeriod period) {
    switch (period) {
      case ChartPeriod.daily:
        return const _BarSettings(width: 14, spacing: 10);
      case ChartPeriod.weekly:
        return const _BarSettings(width: 22, spacing: 14);
      case ChartPeriod.monthly:
        return const _BarSettings(width: 32, spacing: 18);
      case ChartPeriod.yearly:
        return const _BarSettings(width: 44, spacing: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            l10n?.noDataAvailable ?? 'No data available',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.grey500),
          ),
        ),
      );
    }

    final barSettings = _getBarSettings(widget.period);
    final totalWidth =
        widget.data.length * (barSettings.width + barSettings.spacing) +
        barSettings.spacing +
        32;

    return SizedBox(
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MouseRegion(
              onHover: (event) {
                // Throttle hover updates to ~60fps max
                final now = DateTime.now();
                if (_lastHoverUpdate != null &&
                    now.difference(_lastHoverUpdate!).inMilliseconds <
                        _hoverThrottleMs) {
                  return;
                }
                _lastHoverUpdate = now;

                final newIndex = _calculateIndex(
                  event.localPosition.dx,
                  barSettings,
                );
                // Only rebuild if hover state actually changed
                if (_hoveredIndex != newIndex) {
                  setState(() {
                    _hoverPosition = event.localPosition;
                    _hoveredIndex = newIndex;
                  });
                }
              },
              onExit: (_) {
                setState(() {
                  _hoveredIndex = null;
                  _hoverPosition = null;
                });
              },
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return RepaintBoundary(
                    child: CustomPaint(
                      size: Size(totalWidth - 32, widget.height),
                      painter: _DivergingBarChartPainter(
                        data: widget.data,
                        progress: Curves.fastLinearToSlowEaseIn.transform(
                          _controller.value,
                        ),
                        hoveredIndex: _hoveredIndex,
                        period: widget.period,
                        incomeColor:
                            widget.incomeColor ?? const Color(0xFF10B981),
                        expenseColor:
                            widget.expenseColor ?? const Color(0xFFF43F5E),
                        gridColor: AppColors.grey200.withValues(alpha: 0.5),
                        labelStyle: AppTypography.labelSmall.copyWith(
                          color: widget.labelColor ?? AppColors.grey500,
                          fontWeight: FontWeight.w500,
                        ),
                        barWidth: barSettings.width,
                        barSpacing: barSettings.spacing,
                        showGrid: widget.showGrid,
                        locale: AppLocalizations.of(context)?.localeName,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_hoveredIndex != null && _hoverPosition != null)
            _buildTooltip(
              widget.data[_hoveredIndex!],
              _hoveredIndex!,
              barSettings,
            ),
        ],
      ),
    );
  }

  int? _calculateIndex(double x, _BarSettings settings) {
    final adjustedX = x - settings.spacing / 2;
    if (adjustedX < 0) return null;
    final index = (adjustedX / (settings.width + settings.spacing)).floor();
    if (index >= 0 && index < widget.data.length) {
      return index;
    }
    return null;
  }

  Widget _buildTooltip(ChartPoint point, int index, _BarSettings settings) {
    const currencySymbol = r'$';

    // Calculate position relative to the Stack
    // index * stride + spacing + horizontal_padding_in_scrollview - scroll_offset
    final xPos =
        (index * (settings.width + settings.spacing)) +
        settings.spacing +
        16 -
        _scrollController.offset;
    final yPos = _hoverPosition!.dy;

    return Positioned(
      left: xPos + settings.width / 2 - 80, // Center tooltip on bar
      top: math.max(10, yPos - 100), // Stay within visible area
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _hoveredIndex != null ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: 160,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat(
                    'MMMM d, yyyy',
                    AppLocalizations.of(context)?.localeName,
                  ).format(point.date),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.grey500,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
                _TooltipRow(
                  label: AppLocalizations.of(context)?.income ?? 'Income',
                  value: FormattingUtils.formatCompact(
                    point.income,
                    symbol: currencySymbol,
                  ),
                  color: const Color(0xFF10B981),
                  visible: point.income > 0,
                ),
                if (point.income > 0 && point.expense != 0)
                  const SizedBox(height: 4),
                _TooltipRow(
                  label: AppLocalizations.of(context)?.expense ?? 'Expense',
                  value: FormattingUtils.formatCompact(
                    point.expense.abs(),
                    symbol: currencySymbol,
                  ),
                  color: const Color(0xFFF43F5E),
                  visible: point.expense != 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TooltipRow extends StatelessWidget {
  const _TooltipRow({
    required this.label,
    required this.value,
    required this.color,
    this.visible = true,
  });

  final String label;
  final String value;
  final Color color;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.grey600,
                fontSize: 11,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.grey900,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _BarSettings {
  const _BarSettings({required this.width, required this.spacing});
  final double width;
  final double spacing;
}

class _DivergingBarChartPainter extends CustomPainter {
  _DivergingBarChartPainter({
    required this.data,
    required this.progress,
    required this.hoveredIndex,
    required this.period,
    required this.incomeColor,
    required this.expenseColor,
    required this.gridColor,
    required this.labelStyle,
    required this.barWidth,
    required this.barSpacing,
    required this.showGrid,
    this.locale,
  });

  final List<ChartPoint> data;
  final double progress;
  final int? hoveredIndex;
  final ChartPeriod period;
  final Color incomeColor;
  final Color expenseColor;
  final Color gridColor;
  final TextStyle labelStyle;
  final double barWidth;
  final double barSpacing;
  final bool showGrid;
  final String? locale;

  @override
  void paint(Canvas canvas, Size size) {
    final labelHeight = 32.0;
    final chartHeight = size.height - labelHeight;
    final baselineY = chartHeight / 2;

    // 1. Calculate Scale
    double maxVal = 0;
    for (var p in data) {
      maxVal = math.max(maxVal, p.income);
      maxVal = math.max(maxVal, p.expense.abs());
    }
    // Add headroom and handle 0
    maxVal = maxVal == 0 ? 100 : maxVal * 1.15;

    final halfChartHeight = baselineY;
    final valueToPixels =
        (halfChartHeight - 20) / maxVal; // 20px padding at top/bottom

    // 2. Draw Grid
    if (showGrid) {
      final gridPaint = Paint()
        ..color = gridColor
        ..strokeWidth = 1;

      // Horizontal grid lines
      final steps = 4;
      for (var i = -steps; i <= steps; i++) {
        if (i == 0) continue; // Zero line drawn separately
        final y = baselineY - (i * (maxVal / steps) * valueToPixels);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    // 3. Draw Zero Baseline
    final baselinePaint = Paint()
      ..color = AppColors.grey300
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(0, baselineY),
      Offset(size.width, baselineY),
      baselinePaint,
    );

    // 4. Draw Bars
    final dateFormat = _getDateFormat(period, locale);

    for (var i = 0; i < data.length; i++) {
      final p = data[i];
      final x = i * (barWidth + barSpacing) + barSpacing;
      final isOtherHovered = hoveredIndex != null && hoveredIndex != i;
      final opacity = isOtherHovered ? 0.3 : 1.0;

      // Income (Up)
      if (p.income > 0) {
        final h = p.income * valueToPixels * progress;
        final rect = Rect.fromLTWH(x, baselineY - h, barWidth, h);
        final rrect = RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        );
        canvas.drawRRect(
          rrect,
          Paint()..color = incomeColor.withValues(alpha: opacity),
        );
      }

      // Expense (Down)
      if (p.expense != 0) {
        final h = p.expense.abs() * valueToPixels * progress;
        final rect = Rect.fromLTWH(x, baselineY, barWidth, h);
        final rrect = RRect.fromRectAndCorners(
          rect,
          bottomLeft: const Radius.circular(4),
          bottomRight: const Radius.circular(4),
        );
        canvas.drawRRect(
          rrect,
          Paint()..color = expenseColor.withValues(alpha: opacity),
        );
      }

      // 5. Draw Labels (sampled to avoid overlap)
      if (_shouldShowLabel(i, data.length, period)) {
        final labelText = p.label ?? dateFormat.format(p.date);
        final tp = TextPainter(
          text: TextSpan(text: labelText, style: labelStyle),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(x + (barWidth - tp.width) / 2, chartHeight + 8),
        );
      }
    }
  }

  bool _shouldShowLabel(int index, int total, ChartPeriod period) {
    if (total < 10) return true;
    if (period == ChartPeriod.daily) return index % 2 == 0;
    if (period == ChartPeriod.weekly) return index % 1 == 0;
    if (period == ChartPeriod.monthly) return index % 3 == 0;
    return true;
  }

  DateFormat _getDateFormat(ChartPeriod period, String? locale) {
    switch (period) {
      case ChartPeriod.daily:
        return DateFormat('E', locale);
      case ChartPeriod.weekly:
        return DateFormat('MMM d', locale);
      case ChartPeriod.monthly:
        return DateFormat('MMM', locale);
      case ChartPeriod.yearly:
        return DateFormat('yyyy', locale);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is! _DivergingBarChartPainter) return true;
    return oldDelegate.progress != progress ||
        oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.data != data ||
        oldDelegate.period != period;
  }
}
