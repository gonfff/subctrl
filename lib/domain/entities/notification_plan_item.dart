class NotificationPlanItem {
  NotificationPlanItem({
    required this.notificationId,
    required this.subscriptionId,
    required this.index,
    required this.paymentDate,
    required this.scheduledDate,
  });

  final int notificationId;
  final int subscriptionId;
  final int index;
  final DateTime paymentDate;
  final DateTime scheduledDate;
}
