import 'package:flutter/services.dart';
import 'package:subctrl/domain/entities/notification_permission_status.dart';

class NotificationPermissionService {
  NotificationPermissionService();

  static const _channel =
      MethodChannel('subctrl/notification_permissions');

  Future<NotificationPermissionStatus> checkStatus() async {
    final raw = await _invoke('checkPermission');
    return _fromRawStatus(raw);
  }

  Future<NotificationPermissionStatus> requestPermission() async {
    final raw = await _invoke('requestPermission');
    return _fromRawStatus(raw);
  }

  Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod<void>('openSettings');
    } on PlatformException {
      // Ignore failures opening settings.
    }
    on MissingPluginException {
      // Channel may not be registered on other platforms, ignore.
    }
  }

  Future<String?> _invoke(String method) async {
    try {
      return await _channel.invokeMethod<String?>(method);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  NotificationPermissionStatus _fromRawStatus(String? rawStatus) {
    if (rawStatus == null) return NotificationPermissionStatus.denied;
    return NotificationPermissionStatus.values.firstWhere(
      (status) => status.name == rawStatus,
      orElse: () => NotificationPermissionStatus.denied,
    );
  }
}
