import 'package:subctrl/infrastructure/platform/local_notifications_service.dart';

class CancelNotificationsUseCase {
  CancelNotificationsUseCase(this._localNotificationsService);

  final LocalNotificationsService _localNotificationsService;

  Future<void> call(Iterable<int> ids) {
    return _localNotificationsService.cancelNotifications(ids);
  }
}
