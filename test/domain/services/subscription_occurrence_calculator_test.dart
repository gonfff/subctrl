import 'package:flutter_test/flutter_test.dart';
import 'package:subctrl/domain/entities/subscription.dart';
import 'package:subctrl/domain/services/subscription_occurrence_calculator.dart';

void main() {
  test('counts daily occurrences within the selected range', () {
    final result = calculateSubscriptionOccurrences(
      cycle: BillingCycle.daily,
      purchaseDate: DateTime(2024, 1, 1),
      rangeStart: DateTime(2024, 5, 1),
      rangeEnd: DateTime(2024, 5, 5),
      today: DateTime(2024, 5, 3),
    );

    expect(result.totalOccurrences, 5);
    expect(result.occurredOccurrences, 3);
  });

  test('handles monthly subscriptions purchased before the range start', () {
    final result = calculateSubscriptionOccurrences(
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2023, 1, 10),
      rangeStart: DateTime(2024, 5, 1),
      rangeEnd: DateTime(2024, 5, 31),
      today: DateTime(2024, 5, 9),
    );

    expect(result.totalOccurrences, 1);
    expect(result.occurredOccurrences, 0);
  });

  test('returns zero when subscription starts after the range', () {
    final result = calculateSubscriptionOccurrences(
      cycle: BillingCycle.weekly,
      purchaseDate: DateTime(2024, 6, 1),
      rangeStart: DateTime(2024, 5, 1),
      rangeEnd: DateTime(2024, 5, 31),
      today: DateTime(2024, 5, 15),
    );

    expect(result.totalOccurrences, 0);
    expect(result.occurredOccurrences, 0);
  });

  test('treats all occurrences as paid when today is after the range', () {
    final result = calculateSubscriptionOccurrences(
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2023, 1, 5),
      rangeStart: DateTime(2024, 4, 1),
      rangeEnd: DateTime(2024, 4, 30),
      today: DateTime(2024, 5, 10),
    );

    expect(result.totalOccurrences, 1);
    expect(result.occurredOccurrences, 1);
  });
}
