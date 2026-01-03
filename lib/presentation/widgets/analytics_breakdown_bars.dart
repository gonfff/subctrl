import 'package:flutter/cupertino.dart';
import 'package:subctrl/presentation/viewmodels/analytics_view_model.dart';

class AnalyticsBarData {
  const AnalyticsBarData({
    required this.label,
    required this.color,
    required this.total,
    required this.paid,
  });

  final String label;
  final Color color;
  final double total;
  final double paid;
}

class AnalyticsBreakdownBars extends StatelessWidget {
  const AnalyticsBreakdownBars({
    super.key,
    required this.items,
    required this.formatAmount,
    required this.period,
  });

  final List<AnalyticsBarData> items;
  final String Function(double) formatAmount;
  final AnalyticsPeriod period;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final showFullPeriodTotals = period != AnalyticsPeriod.allTime;
    final maxTotal = items
        .map((item) => showFullPeriodTotals ? item.total : item.paid)
        .fold<double>(0.0, (a, b) => a > b ? a : b);
    final normalizedMaxTotal = maxTotal <= 0 ? 1.0 : maxTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _BarRow(
                item: item,
                maxTotal: normalizedMaxTotal,
                formatAmount: formatAmount,
                showFullPeriodTotals: showFullPeriodTotals,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.item,
    required this.maxTotal,
    required this.formatAmount,
    required this.showFullPeriodTotals,
  });

  final AnalyticsBarData item;
  final double maxTotal;
  final String Function(double) formatAmount;
  final bool showFullPeriodTotals;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context).textTheme.textStyle;
    final rawDisplayTotal = showFullPeriodTotals ? item.total : item.paid;
    final displayTotal = rawDisplayTotal <= 0 ? 0.0 : rawDisplayTotal;
    final totalFactor = calculateAnalyticsBarWidthFactor(
      displayTotal: displayTotal,
      maxTotal: maxTotal,
    );
    final paidFactor = !showFullPeriodTotals
        ? 1.0
        : item.total <= 0
        ? 0.0
        : (item.paid / item.total).clamp(0.0, 1.0);
    final paidAmount = showFullPeriodTotals
        ? item.paid.clamp(0.0, item.total).toDouble()
        : displayTotal;
    final upcomingAmount = showFullPeriodTotals
        ? (displayTotal - paidAmount).clamp(0.0, displayTotal)
        : 0.0;
    final paidAmountLabel = formatAmount(paidAmount);
    final String? upcomingAmountLabel =
        showFullPeriodTotals && upcomingAmount > 0
        ? formatAmount(upcomingAmount)
        : null;
    final totalLabel = formatAmount(displayTotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: theme.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Text(totalLabel),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth * totalFactor;
            if (totalWidth <= 0) return const SizedBox.shrink();
            final paidWidth = totalWidth * paidFactor;
            final upcomingWidth = showFullPeriodTotals
                ? (totalWidth - paidWidth).clamp(0.0, totalWidth)
                : 0.0;
            final upcomingColor = CupertinoColors.systemGrey5.resolveFrom(
              context,
            );
            return Align(
              alignment: Alignment.centerLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: totalWidth,
                  height: 28,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (paidWidth > 0)
                        _BarSegment(
                          width: paidWidth,
                          color: item.color,
                          label: paidAmountLabel,
                          alignment: Alignment.centerLeft,
                          textColor: _segmentLabelColor(item.color),
                        ),
                      if (showFullPeriodTotals &&
                          upcomingWidth > 0 &&
                          upcomingAmountLabel != null)
                        _BarSegment(
                          width: upcomingWidth,
                          color: upcomingColor,
                          label: upcomingAmountLabel,
                          alignment: Alignment.centerRight,
                          textColor: CupertinoColors.secondaryLabel.resolveFrom(
                            context,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BarSegment extends StatelessWidget {
  const _BarSegment({
    required this.width,
    required this.color,
    required this.label,
    required this.alignment,
    required this.textColor,
  });

  final double width;
  final Color color;
  final String label;
  final Alignment alignment;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle.copyWith(
      color: textColor,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
    return SizedBox(
      width: width,
      child: Container(
        color: color,
        child: Align(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: alignment,
              child: Text(label, style: textStyle),
            ),
          ),
        ),
      ),
    );
  }
}

Color _segmentLabelColor(Color color) {
  return color.computeLuminance() > 0.5
      ? CupertinoColors.black
      : CupertinoColors.white;
}

// Keeps very small subscriptions visible even if another subscription dominates.
const double _minBarBaselineShare = 0.1;

@visibleForTesting
double calculateAnalyticsBarWidthFactor({
  required double displayTotal,
  required double maxTotal,
}) {
  if (displayTotal <= 0 || maxTotal <= 0) return 0;
  final baseline = maxTotal * _minBarBaselineShare;
  final paddedTotal = displayTotal + baseline;
  final paddedMaxTotal = maxTotal + baseline;
  return (paddedTotal / paddedMaxTotal).clamp(0.0, 1.0);
}
