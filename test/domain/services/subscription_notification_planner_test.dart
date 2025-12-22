import 'package:flutter_test/flutter_test.dart';
import 'package:subctrl/domain/entities/notification_reminder_option.dart';
import 'package:subctrl/domain/entities/subscription.dart';
import 'package:subctrl/domain/services/subscription_notification_planner.dart';

void main() {
  test(
    'plans up to three notifications per subscription at configured time',
    () {
      final planner = SubscriptionNotificationPlanner(
        now: DateTime(2024, 1, 1, 9),
      );
      final subscription = Subscription(
        id: 1,
        name: 'Netflix',
        amount: 10,
        currency: 'USD',
        cycle: BillingCycle.monthly,
        purchaseDate: DateTime(2023, 12, 1),
        nextPaymentDate: DateTime(2024, 1, 2),
      );

      final planned = planner.plan(
        subscriptions: [subscription],
        reminderOption: NotificationReminderOption.sameDay,
      );

      expect(planned, hasLength(3));
      expect(planned.first.scheduledDate, DateTime(2024, 1, 2, 10, 00));
      expect(planned[1].scheduledDate, DateTime(2024, 2, 2, 10, 00));
      expect(planned[2].scheduledDate, DateTime(2024, 3, 2, 10, 00));
    },
  );

  test('uses reminder offsets before payment dates', () {
    final planner = SubscriptionNotificationPlanner(
      now: DateTime(2024, 1, 1, 9),
    );
    final subscription = Subscription(
      id: 2,
      name: 'Spotify',
      amount: 8,
      currency: 'USD',
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2023, 12, 1),
      nextPaymentDate: DateTime(2024, 1, 15),
    );

    final planned = planner.plan(
      subscriptions: [subscription],
      reminderOption: NotificationReminderOption.weekBefore,
    );

    expect(planned.first.scheduledDate, DateTime(2024, 1, 8, 10, 00));
  });

  test('keeps same-day payments when next payment date is today', () {
    final planner = SubscriptionNotificationPlanner(
      now: DateTime(2024, 1, 10, 9),
    );
    final subscription = Subscription(
      id: 5,
      name: 'Disney+',
      amount: 11,
      currency: 'USD',
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2023, 12, 10),
      nextPaymentDate: DateTime(2024, 1, 10),
    );

    final planned = planner.plan(
      subscriptions: [subscription],
      reminderOption: NotificationReminderOption.sameDay,
    );

    expect(planned.first.paymentDate, DateTime(2024, 1, 10));
  });

  test('skips reminders that are already in the past', () {
    final planner = SubscriptionNotificationPlanner(
      now: DateTime(2024, 1, 10, 15),
    );
    final subscription = Subscription(
      id: 3,
      name: 'Apple TV',
      amount: 12,
      currency: 'USD',
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2023, 12, 1),
      nextPaymentDate: DateTime(2024, 1, 11),
    );

    final planned = planner.plan(
      subscriptions: [subscription],
      reminderOption: NotificationReminderOption.dayBefore,
    );

    expect(planned.first.scheduledDate, DateTime(2024, 2, 10, 10, 00));
  });

  test('advances past payment dates to the next cycle', () {
    final planner = SubscriptionNotificationPlanner(
      now: DateTime(2024, 1, 10, 11),
    );
    final subscription = Subscription(
      id: 4,
      name: 'Hulu',
      amount: 9,
      currency: 'USD',
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2023, 12, 1),
      nextPaymentDate: DateTime(2023, 12, 15),
    );

    final planned = planner.plan(
      subscriptions: [subscription],
      reminderOption: NotificationReminderOption.sameDay,
    );

    expect(planned.first.scheduledDate, DateTime(2024, 1, 15, 10, 00));
  });

  test('limits total planned notifications to 60', () {
    final planner = SubscriptionNotificationPlanner(
      now: DateTime(2024, 1, 1, 9),
    );
    final subscriptions = List.generate(25, (index) {
      return Subscription(
        id: index + 1,
        name: 'Service $index',
        amount: 5,
        currency: 'USD',
        cycle: BillingCycle.monthly,
        purchaseDate: DateTime(2023, 12, 1),
        nextPaymentDate: DateTime(2024, 1, 3),
      );
    });

    final planned = planner.plan(
      subscriptions: subscriptions,
      reminderOption: NotificationReminderOption.sameDay,
    );

    expect(planned.length, SubscriptionNotificationPlanner.maxTotal);
  });
}
