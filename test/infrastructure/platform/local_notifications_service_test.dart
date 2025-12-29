import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:subctrl/domain/entities/planned_notification.dart';
import 'package:subctrl/infrastructure/platform/local_notifications_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class _MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const timezoneChannel = MethodChannel('flutter_timezone');

  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    registerFallbackValue(tz.TZDateTime.from(DateTime(2024, 1, 1), tz.local));
    registerFallbackValue(
      const InitializationSettings(iOS: DarwinInitializationSettings()),
    );
    registerFallbackValue(
      const NotificationDetails(iOS: DarwinNotificationDetails()),
    );
  });

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timezoneChannel, (call) async => 'UTC');
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timezoneChannel, null);
  });

  test('initialize is idempotent', () async {
    final plugin = _MockFlutterLocalNotificationsPlugin();
    when(() => plugin.initialize(any())).thenAnswer((_) async => true);

    final service = LocalNotificationsService(plugin: plugin);

    await service.initialize();
    await service.initialize();

    verify(() => plugin.initialize(any())).called(1);
  });

  test('pendingNotificationRequests returns plugin values', () async {
    final plugin = _MockFlutterLocalNotificationsPlugin();
    when(() => plugin.initialize(any())).thenAnswer((_) async => true);
    when(() => plugin.pendingNotificationRequests()).thenAnswer(
      (_) async => [
        const PendingNotificationRequest(1, 'Title', 'Body', 'payload'),
      ],
    );

    final service = LocalNotificationsService(plugin: plugin);

    final pending = await service.pendingNotificationRequests();

    expect(pending, hasLength(1));
    verify(() => plugin.pendingNotificationRequests()).called(1);
  });

  test('cancelNotifications skips empty list', () async {
    final plugin = _MockFlutterLocalNotificationsPlugin();
    when(() => plugin.initialize(any())).thenAnswer((_) async => true);

    final service = LocalNotificationsService(plugin: plugin);

    await service.cancelNotifications(const []);

    verifyNever(() => plugin.cancel(any()));
  });

  test('cancelNotifications cancels each id', () async {
    final plugin = _MockFlutterLocalNotificationsPlugin();
    when(() => plugin.initialize(any())).thenAnswer((_) async => true);
    when(() => plugin.cancel(any())).thenAnswer((_) async {});

    final service = LocalNotificationsService(plugin: plugin);

    await service.cancelNotifications(const [11, 12]);

    verify(() => plugin.cancel(11)).called(1);
    verify(() => plugin.cancel(12)).called(1);
  });

  test('scheduleNotifications uses zonedSchedule for each item', () async {
    final plugin = _MockFlutterLocalNotificationsPlugin();
    when(() => plugin.initialize(any())).thenAnswer((_) async => true);
    when(
      () => plugin.zonedSchedule(
        any(),
        any(),
        any(),
        any(),
        any(),
        payload: any(named: 'payload'),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null,
      ),
    ).thenAnswer((_) async {});

    final service = LocalNotificationsService(plugin: plugin);

    await service.scheduleNotifications([
      PlannedNotification(
        id: 1,
        title: 'Title 1',
        body: 'Body 1',
        scheduledDate: DateTime(2024, 1, 2),
        payload: 'p1',
      ),
      PlannedNotification(
        id: 2,
        title: 'Title 2',
        body: 'Body 2',
        scheduledDate: DateTime(2024, 1, 3),
      ),
    ]);

    verify(
      () => plugin.zonedSchedule(
        1,
        'Title 1',
        'Body 1',
        any(),
        any(),
        payload: 'p1',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null,
      ),
    ).called(1);
    verify(
      () => plugin.zonedSchedule(
        2,
        'Title 2',
        'Body 2',
        any(),
        any(),
        payload: null,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null,
      ),
    ).called(1);
  });
}
