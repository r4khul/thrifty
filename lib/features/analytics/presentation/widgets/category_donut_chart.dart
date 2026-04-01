import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:thrifty/core/theme/app_colors.dart';
import 'package:thrifty/core/theme/app_typography.dart';
import 'package:thrifty/l10n/app_localizations.dart';

import '../../domain/financial_data_models.dart';

/// A modern donut chart showing category-wise expense breakdown.
///
/// Refactored to be modular and support binding with external widgets.
class CategoryDonutChart extends StatefulWidget {
  const CategoryDonutChart({
    super.key,
    required this.data,
    required this.totalExpense,
    this.size = 200,
    this.selectedIndex,
    this.onSelectionChanged,
    this.currencySymbol = r'$',
  });

  final List<CategorySpend> data;
  final double totalExpense;
  final double size;
  final int? selectedIndex;
  final ValueChanged<int?>? onSelectionChanged;
  final String currencySymbol;

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // Faster animation for snappier feel
      duration: const Duration(milliseconds: 700),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(CategoryDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.length != widget.data.length ||
        oldWidget.totalExpense != widget.totalExpense) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.data.isEmpty) {
      return SizedBox(
        height: widget.size,
        child: Center(
          child: Text(
            'No expenses to analyze',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.grey500 : AppColors.grey600,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: GestureDetector(
        onTapDown: (details) => _handleTap(details.localPosition),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return RepaintBoundary(
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _DonutPainter(
                  data: widget.data,
                  progress: _animation.value,
                  selectedIndex: widget.selectedIndex,
                  totalExpense: widget.totalExpense,
                  isDark: isDark,
                  currencySymbol: widget.currencySymbol,
                  totalSpentLabel: AppLocalizations.of(context)!.totalSpent,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleTap(Offset position) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final touchVector = position - center;
    final distance = touchVector.distance;

    final outerRadius = widget.size / 2 - 8;
    final innerRadius = outerRadius * 0.6;

    if (distance < innerRadius || distance > outerRadius) {
      widget.onSelectionChanged?.call(null);
      return;
    }

    var angle = math.atan2(touchVector.dy, touchVector.dx);
    angle = angle + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;

    double currentAngle = 0;
    for (var i = 0; i < widget.data.length; i++) {
      final sweep = (widget.data[i].percentage / 100) * 2 * math.pi;
      if (angle >= currentAngle && angle < currentAngle + sweep) {
        final newIndex = widget.selectedIndex == i ? null : i;
        widget.onSelectionChanged?.call(newIndex);
        return;
      }
      currentAngle += sweep;
    }
    widget.onSelectionChanged?.call(null);
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.data,
    required this.progress,
    required this.selectedIndex,
    required this.totalExpense,
    required this.isDark,
    required this.currencySymbol,
    required this.totalSpentLabel,
  });

  final List<CategorySpend> data;
  final double progress;
  final int? selectedIndex;
  final double totalExpense;
  final bool isDark;
  final String currencySymbol;
  final String totalSpentLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 8;
    final innerRadius = outerRadius * 0.6;
    final strokeWidth = outerRadius - innerRadius;

    final bgPaint = Paint()
      ..color = isDark
          ? AppColors.grey800.withValues(alpha: 0.3)
          : AppColors.grey200.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, innerRadius + strokeWidth / 2, bgPaint);

    var startAngle = -math.pi / 2;

    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      final sweepAngle = (item.percentage / 100) * 2 * math.pi * progress;
      final isSelected = selectedIndex == i;

      final paint = Paint()
        ..color = Color(
          item.categoryColor,
        ).withValues(alpha: selectedIndex != null && !isSelected ? 0.3 : 1.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? strokeWidth + 8 : strokeWidth
        ..strokeCap = StrokeCap.butt;

      final radius = isSelected
          ? innerRadius + strokeWidth / 2 + 4
          : innerRadius + strokeWidth / 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }

    _drawCenterText(canvas, center, totalExpense);
  }

  void _drawCenterText(Canvas canvas, Offset center, double total) {
    final labelPainter = TextPainter(
      text: TextSpan(
        text: totalSpentLabel,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.grey400 : AppColors.grey500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    labelPainter.paint(
      canvas,
      Offset(center.dx - labelPainter.width / 2, center.dy - 16),
    );

    final formattedAmount = _formatAmount(total);
    final amountPainter = TextPainter(
      text: TextSpan(
        text: '$currencySymbol$formattedAmount',
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppColors.grey900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    amountPainter.paint(
      canvas,
      Offset(center.dx - amountPainter.width / 2, center.dy + 2),
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

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.data != data ||
        oldDelegate.isDark != isDark ||
        oldDelegate.currencySymbol != currencySymbol;
  }
}
