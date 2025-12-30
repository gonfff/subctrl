import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import 'package:subctrl/presentation/l10n/app_localizations.dart';

class AnalyticsPieSlice {
  const AnalyticsPieSlice({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;
}

class AnalyticsPieChart extends StatefulWidget {
  const AnalyticsPieChart({
    super.key,
    required this.slices,
    required this.formatAmount,
  });

  final List<AnalyticsPieSlice> slices;
  final String Function(double) formatAmount;

  @override
  State<AnalyticsPieChart> createState() => _AnalyticsPieChartState();
}

class _AnalyticsPieChartState extends State<AnalyticsPieChart> {
  AnalyticsPieSlice? _activeSlice;
  double _totalAmount = 0;
  Size? _chartSize;

  @override
  Widget build(BuildContext context) {
    final displaySlice = _activeSlice;

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.biggest.shortestSide;
          final size = Size(side, side);
          _chartSize = size;
          _totalAmount = widget.slices.fold<double>(
            0,
            (sum, slice) => sum + slice.amount,
          );
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => _updateSelection(details.localPosition),
            child: MouseRegion(
              onHover: (event) => _updateSelection(event.localPosition),
              onExit: (_) => _clearSelection(),
              child: Stack(
                children: [
                  CustomPaint(
                    size: size,
                    painter: _PieChartPainter(
                      slices: widget.slices,
                      highlighted: _activeSlice,
                    ),
                  ),
                  Center(child: _buildCenterLabel(context, displaySlice)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _updateSelection(Offset position) {
    final size = _chartSize;
    if (size == null) return;
    final slice = _findSliceAt(position, size);
    setState(() {
      _activeSlice = slice;
    });
  }

  void _clearSelection() {
    if (_activeSlice == null) return;
    setState(() {
      _activeSlice = null;
    });
  }

  AnalyticsPieSlice? _findSliceAt(Offset position, Size size) {
    final total = widget.slices.fold<double>(
      0,
      (sum, slice) => sum + slice.amount,
    );
    if (total <= 0) return null;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance > radius) return null;

    var angle = math.atan2(dy, dx);
    const startAngle = -math.pi / 2;
    angle -= startAngle;
    while (angle < 0) {
      angle += 2 * math.pi;
    }
    angle %= 2 * math.pi;

    var cumulative = 0.0;
    for (final slice in widget.slices) {
      final sweep = (slice.amount / total) * 2 * math.pi;
      if (angle >= cumulative && angle < cumulative + sweep) {
        return slice;
      }
      cumulative += sweep;
    }
    return null;
  }

  Widget _buildCenterLabel(
    BuildContext context,
    AnalyticsPieSlice? displaySlice,
  ) {
    final localizations = AppLocalizations.of(context);
    final label = displaySlice?.label ??
        localizations.analyticsSummaryTotalLabel;
    final amount = displaySlice?.amount ?? _totalAmount;
    final percentage = _percentageString(displaySlice);
    return _CenterLabel(
      label: label,
      amount: amount,
      percentage: percentage,
      formatAmount: widget.formatAmount,
    );
  }

  String _percentage(double amount) {
    if (_totalAmount <= 0) return '0';
    final value = (amount / _totalAmount) * 100;
    return value.toStringAsFixed(value >= 10 ? 0 : 1);
  }

  String _percentageString(AnalyticsPieSlice? slice) {
    if (_totalAmount <= 0) return '0';
    if (slice == null) {
      return widget.slices.isEmpty ? '0' : '100';
    }
    return _percentage(slice.amount);
  }
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({required this.slices, required this.highlighted});

  final List<AnalyticsPieSlice> slices;
  final AnalyticsPieSlice? highlighted;

  @override
  void paint(Canvas canvas, Size size) {
    final paintableSlices = slices
        .where((slice) => slice.amount > 0)
        .toList(growable: false);
    final total =
        paintableSlices.fold<double>(0, (sum, slice) => sum + slice.amount);
    final diameter = math.min(size.width, size.height) * 0.82;
    final offsetX = (size.width - diameter) / 2;
    final offsetY = (size.height - diameter) / 2;
    final rect = Rect.fromLTWH(offsetX, offsetY, diameter, diameter);
    final radius = diameter / 2;

    if (total <= 0) {
      final fallbackPaint = Paint()
        ..color = CupertinoColors.systemGrey4
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        radius,
        fallbackPaint,
      );
      return;
    }

    final strokeWidth = diameter * 0.16;
    final basePaint = Paint()
      ..color = CupertinoColors.systemGrey5
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius - strokeWidth / 2,
      basePaint,
    );

    final shadowPaint = Paint()
      ..color = CupertinoColors.black.withValues(alpha: 0.08)
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    const startAngleBase = -math.pi / 2;
    var startAngle = startAngleBase;
    final arcRect = rect.deflate(strokeWidth / 2);
    AnalyticsPieSlice? firstSlice;
    double? firstSliceSweep;
    for (final slice in paintableSlices) {
      final sweep = (slice.amount / total) * 2 * math.pi;
      if (sweep <= 0) continue;
      firstSlice ??= slice;
      firstSliceSweep ??= sweep;
      canvas.drawArc(arcRect, startAngle, sweep, false, shadowPaint);
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(arcRect, startAngle, sweep, false, paint);
      final endAngle = startAngle + sweep;
      if (slice == highlighted) {
        final highlightPaint = Paint()
          ..color = CupertinoColors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          arcRect,
          startAngle,
          sweep,
          false,
          highlightPaint,
        );
      }
      startAngle = endAngle;
    }

    if (paintableSlices.length > 1 &&
        firstSlice != null &&
        firstSliceSweep != null) {
      final wrapSweep = math.min(
        firstSliceSweep,
        _capCompensationSweep(arcRect, strokeWidth),
      );
      if (wrapSweep > 0) {
        final wrapPaint = Paint()
          ..color = firstSlice.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          arcRect,
          startAngle - 2 * math.pi,
          wrapSweep,
          false,
          wrapPaint,
        );
        if (firstSlice == highlighted) {
          final highlightPaint = Paint()
            ..color = CupertinoColors.white.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round;
          canvas.drawArc(
            arcRect,
            startAngle - 2 * math.pi,
            wrapSweep,
            false,
            highlightPaint,
          );
        }
      }
    }
  }

  double _capCompensationSweep(Rect arcRect, double strokeWidth) {
    final effectiveRadius = arcRect.width / 2;
    if (effectiveRadius <= 0) {
      return 0;
    }
    final sweep = (strokeWidth / (2 * effectiveRadius)) * 1.2;
    return sweep;
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) {
    return oldDelegate.slices != slices ||
        oldDelegate.highlighted != highlighted;
  }
}

class _CenterLabel extends StatelessWidget {
  const _CenterLabel({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.formatAmount,
  });

  final String label;
  final double amount;
  final String? percentage;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context).textTheme.textStyle;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(formatAmount(amount), style: theme),
        if (percentage != null) ...[
          const SizedBox(height: 4),
          Text(
            '$percentage%',
            style: theme.copyWith(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ],
    );
  }
}
