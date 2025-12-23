import 'package:subctrl/infrastructure/platform/notification_permission_service.dart';

class OpenNotificationSettingsUseCase {
  OpenNotificationSettingsUseCase(this._notificationPermissionService);

  final NotificationPermissionService _notificationPermissionService;

  Future<void> call() {
    return _notificationPermissionService.openAppSettings();
  }
}
