import 'package:flutter_test/flutter_test.dart';
import 'package:subctrl/domain/entities/subscription.dart';

void main() {
  test('copyWith replaces supplied values and preserves others', () {
    final original = Subscription(
      id: 1,
      name: 'Netflix',
      amount: 12.0,
      currency: 'USD',
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2024, 1, 1),
      nextPaymentDate: DateTime(2024, 2, 1),
      isActive: true,
      statusChangedAt: DateTime(2024, 1, 1),
      tagId: 10,
    );

    final copy = original.copyWith(name: 'Spotify', amount: 15, tagId: 11);

    expect(copy.name, 'Spotify');
    expect(copy.amount, 15);
    expect(copy.tagId, 11);
    expect(copy.currency, original.currency);
  });

  test('copyWith allows overriding nextPaymentDate and status', () {
    final original = Subscription(
      id: 2,
      name: 'Apple TV',
      amount: 7.0,
      currency: 'USD',
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2024, 1, 1),
      nextPaymentDate: DateTime(2024, 2, 1),
      statusChangedAt: DateTime(2024, 1, 5),
    );
    final nextDate = DateTime(2024, 3, 1);
    final statusDate = DateTime(2024, 2, 1);
    final updated = original.copyWith(
      nextPaymentDate: nextDate,
      statusChangedAt: statusDate,
      isActive: false,
    );
    expect(updated.nextPaymentDate, nextDate);
    expect(updated.statusChangedAt, statusDate);
    expect(updated.isActive, isFalse);
  });

  test('BillingCycleX addTo handles monthly cycles', () {
    final start = DateTime(2024, 1, 15);
    final next = BillingCycle.monthly.addTo(start);
    expect(next.year, 2024);
    expect(next.month, 2);
    expect(next.day, 15);
  });

  test('BillingCycleX addTo handles daily cycles', () {
    final start = DateTime(2024, 1, 1);
    final next = BillingCycle.daily.addTo(start);
    expect(next, DateTime(2024, 1, 2));
  });

  test('BillingCycleX addTo handles weekly cycles', () {
    final start = DateTime(2024, 1, 1);
    final next = BillingCycle.weekly.addTo(start);
    expect(next, DateTime(2024, 1, 8));
  });

  test('BillingCycleX nextPaymentDate advances past reference', () {
    final purchase = DateTime(2024, 1, 1);
    final reference = DateTime(2024, 3, 1);
    final nextDate = BillingCycle.monthly.nextPaymentDate(purchase, reference);
    final sameDay = nextDate.year == reference.year &&
        nextDate.month == reference.month &&
        nextDate.day == reference.day;
    expect(nextDate.isAfter(reference) || sameDay, isTrue);
  });

  test('BillingCycleX nextPaymentDate keeps current day when reference is later', () {
    final purchase = DateTime(2024, 1, 5);
    final reference = DateTime(2024, 2, 5, 20);
    final nextDate = BillingCycle.monthly.nextPaymentDate(purchase, reference);
    expect(nextDate, DateTime(2024, 2, 5));
  });

  test('BillingCycleX nextPaymentDate defaults to now when no reference', () {
    final now = DateTime.now();
    final purchase = now.subtract(const Duration(days: 40));
    final nextDate = BillingCycle.monthly.nextPaymentDate(purchase);
    expect(nextDate.isAfter(now) || nextDate.isAtSameMomentAs(now), isTrue);
  });
}
