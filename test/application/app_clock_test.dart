import 'package:flutter_test/flutter_test.dart';
import 'package:subctrl/application/app_clock.dart';

void main() {
  test('returns override date when set', () {
    final clock = AppClock();
    final override = DateTime(2024, 3, 14, 10, 30);

    clock.setOverrideDate(override);

    final now = clock.now();
    expect(now.year, override.year);
    expect(now.month, override.month);
    expect(now.day, override.day);
  });

  test('strips time when setting override date', () {
    final clock = AppClock();
    final override = DateTime(2024, 3, 14, 10, 30);

    clock.setOverrideDate(override);

    final stored = clock.overrideDate;
    expect(stored, isNotNull);
    expect(stored!.hour, 0);
    expect(stored.minute, 0);
    expect(stored.second, 0);
  });

  test('clears override date', () {
    final clock = AppClock();
    clock.setOverrideDate(DateTime(2024, 3, 14));

    clock.setOverrideDate(null);

    expect(clock.overrideDate, isNull);
  });
}
