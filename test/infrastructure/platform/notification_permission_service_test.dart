import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subctrl/domain/entities/notification_permission_status.dart';
import 'package:subctrl/infrastructure/platform/notification_permission_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('subctrl/notification_permissions');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('checkStatus maps known status', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'checkPermission');
          return 'authorized';
        });

    final service = NotificationPermissionService();
    final status = await service.checkStatus();

    expect(status, NotificationPermissionStatus.authorized);
  });

  test('checkStatus falls back to denied on unknown status', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => 'mystery');

    final service = NotificationPermissionService();
    final status = await service.checkStatus();

    expect(status, NotificationPermissionStatus.denied);
  });

  test('requestPermission returns denied on platform failure', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'failed');
        });

    final service = NotificationPermissionService();
    final status = await service.requestPermission();

    expect(status, NotificationPermissionStatus.denied);
  });

  test('openAppSettings ignores platform exceptions', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'failed');
        });

    final service = NotificationPermissionService();

    await expectLater(service.openAppSettings(), completes);
  });

  test('openAppSettings ignores missing plugin', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          throw MissingPluginException();
        });

    final service = NotificationPermissionService();

    await expectLater(service.openAppSettings(), completes);
  });
}
