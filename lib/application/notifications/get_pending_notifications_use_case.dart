import 'package:subctrl/domain/entities/pending_notification.dart';
import 'package:subctrl/infrastructure/platform/local_notifications_service.dart';

class GetPendingNotificationsUseCase {
  GetPendingNotificationsUseCase(this._localNotificationsService);

  final LocalNotificationsService _localNotificationsService;

  Future<List<PendingNotification>> call() {
    return _localNotificationsService.pendingNotificationRequests();
  }
}
