import 'package:subctrl/domain/entities/notification_reminder_option.dart';

typedef BaseCurrencyChangedCallback = Future<void> Function(String? code);

typedef NotificationReminderChangedCallback = void Function(
  NotificationReminderOption option,
);

typedef TestingDateOverrideChangedCallback = Future<void> Function(
  DateTime? value,
);
