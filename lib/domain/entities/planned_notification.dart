class PlannedNotification {
  PlannedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledDate;
  final String? payload;
}
