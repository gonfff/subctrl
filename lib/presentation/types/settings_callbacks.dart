import 'package:subctrl/presentation/types/notification_reminder_option.dart';

typedef BaseCurrencyChangedCallback = Future<void> Function(String? code);

typedef NotificationReminderChangedCallback = void Function(
  NotificationReminderOption option,
);
