enum NotificationReminderOption {
  weekBefore('week_before'),
  twoDaysBefore('two_days_before'),
  dayBefore('day_before'),
  sameDay('same_day');

  const NotificationReminderOption(this.storageValue);

  final String storageValue;

  static NotificationReminderOption fromStorage(String? value) {
    return NotificationReminderOption.values.firstWhere(
      (option) => option.storageValue == value,
      orElse: () => NotificationReminderOption.twoDaysBefore,
    );
  }
}
