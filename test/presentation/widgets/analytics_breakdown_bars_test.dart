import 'package:flutter_test/flutter_test.dart';
import 'package:subctrl/presentation/widgets/analytics_breakdown_bars.dart';

void main() {
  group('calculateAnalyticsBarWidthFactor', () {
    test('returns zero for non-positive totals', () {
      expect(
        calculateAnalyticsBarWidthFactor(displayTotal: 0, maxTotal: 10),
        0,
      );
      expect(
        calculateAnalyticsBarWidthFactor(displayTotal: -5, maxTotal: 10),
        0,
      );
    });

    test('applies baseline share to very small totals', () {
      final factor = calculateAnalyticsBarWidthFactor(
        displayTotal: 1,
        maxTotal: 100,
      );
      expect(factor, closeTo(0.1, 0.0001));
    });

    test('caps factor at 1 when total matches max', () {
      expect(
        calculateAnalyticsBarWidthFactor(displayTotal: 100, maxTotal: 100),
        1,
      );
      expect(
        calculateAnalyticsBarWidthFactor(displayTotal: 120, maxTotal: 100),
        1,
      );
    });
  });
}
