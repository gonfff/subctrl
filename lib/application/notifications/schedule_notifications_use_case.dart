import 'package:subctrl/domain/entities/planned_notification.dart';
import 'package:subctrl/infrastructure/platform/local_notifications_service.dart';

class ScheduleNotificationsUseCase {
  ScheduleNotificationsUseCase(this._localNotificationsService);

  final LocalNotificationsService _localNotificationsService;

  Future<void> call(Iterable<PlannedNotification> notifications) {
    return _localNotificationsService.scheduleNotifications(notifications);
  }
}
