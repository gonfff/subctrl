import 'package:subctrl/domain/entities/notification_permission_status.dart';
import 'package:subctrl/infrastructure/platform/notification_permission_service.dart';

class RequestNotificationPermissionUseCase {
  RequestNotificationPermissionUseCase(this._notificationPermissionService);

  final NotificationPermissionService _notificationPermissionService;

  Future<NotificationPermissionStatus> call() {
    return _notificationPermissionService.requestPermission();
  }
}
