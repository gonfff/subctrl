import 'package:subctrl/domain/entities/notification_plan_item.dart';
import 'package:subctrl/domain/entities/notification_reminder_option.dart';
import 'package:subctrl/domain/entities/subscription.dart';

class SubscriptionNotificationPlanner {
  SubscriptionNotificationPlanner({DateTime? now})
    : _now = now ?? DateTime.now();

  static const int maxPerSubscription = 3;
  static const int maxTotal = 60;
  static const int notificationHour = 10;
  static const int notificationMinute = 00;
  static const int _notificationIdBase = 1000000;
  static const int _notificationIdStride = 10;

  final DateTime _now;

  List<NotificationPlanItem> plan({
    required List<Subscription> subscriptions,
    required NotificationReminderOption reminderOption,
  }) {
    final notifications = <NotificationPlanItem>[];
    final offset = _reminderOffset(reminderOption);

    for (final subscription in subscriptions) {
      if (!subscription.isActive || subscription.id == null) {
        continue;
      }
      var paymentDate = _nextPaymentAfter(subscription);
      var plannedCount = 0;
      var attempts = 0;
      while (plannedCount < maxPerSubscription &&
          attempts < maxPerSubscription * 6) {
        final scheduledAt = _notificationDate(paymentDate, offset);
        if (scheduledAt.isAfter(_now)) {
          notifications.add(
            NotificationPlanItem(
              notificationId: _notificationId(subscription.id!, plannedCount),
              subscriptionId: subscription.id!,
              index: plannedCount,
              paymentDate: paymentDate,
              scheduledDate: scheduledAt,
            ),
          );
          plannedCount += 1;
        }
        paymentDate = subscription.cycle.addTo(paymentDate);
        attempts += 1;
      }
    }

    notifications.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    if (notifications.length > maxTotal) {
      return notifications.sublist(0, maxTotal);
    }
    return notifications;
  }

  static bool isManagedNotificationId(int id) {
    final offset = id - _notificationIdBase;
    if (offset < 0) return false;
    return offset % _notificationIdStride < maxPerSubscription;
  }

  Duration _reminderOffset(NotificationReminderOption option) {
    switch (option) {
      case NotificationReminderOption.weekBefore:
        return const Duration(days: 7);
      case NotificationReminderOption.twoDaysBefore:
        return const Duration(days: 2);
      case NotificationReminderOption.dayBefore:
        return const Duration(days: 1);
      case NotificationReminderOption.sameDay:
        return Duration.zero;
    }
  }

  DateTime _nextPaymentAfter(Subscription subscription) {
    var nextPayment = subscription.nextPaymentDate;
    while (isBeforeDay(nextPayment, _now)) {
      nextPayment = subscription.cycle.addTo(nextPayment);
    }
    return nextPayment;
  }

  DateTime _notificationDate(DateTime paymentDate, Duration offset) {
    final dateOnly = DateTime(
      paymentDate.year,
      paymentDate.month,
      paymentDate.day,
    );
    final reminderDate = dateOnly.subtract(offset);
    return DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      notificationHour,
      notificationMinute,
    );
  }

  int _notificationId(int subscriptionId, int index) {
    return _notificationIdBase + subscriptionId * _notificationIdStride + index;
  }

}
