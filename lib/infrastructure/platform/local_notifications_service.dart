import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:subctrl/domain/entities/planned_notification.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationsService {
  LocalNotificationsService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await _configureTimeZones();
    const darwinSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(iOS: darwinSettings);
    await _plugin.initialize(settings);
    _initialized = true;
    _log('Initialized local notifications');
  }

  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    await initialize();
    final pending = await _plugin.pendingNotificationRequests();
    _log('Loaded pending notifications: ${pending.length}');
    return pending;
  }

  Future<void> cancelNotifications(Iterable<int> ids) async {
    await initialize();
    final idList = ids.toList(growable: false);
    if (idList.isEmpty) return;
    for (final id in idList) {
      await _plugin.cancel(id);
    }
    _log('Canceled notifications: ${idList.length}');
  }

  Future<void> scheduleNotifications(
    Iterable<PlannedNotification> notifications,
  ) async {
    await initialize();
    final details = _notificationDetails();
    var scheduled = 0;
    for (final notification in notifications) {
      final scheduledDate = tz.TZDateTime.from(
        notification.scheduledDate,
        tz.local,
      );
      await _plugin.zonedSchedule(
        notification.id,
        notification.title,
        notification.body,
        scheduledDate,
        details,
        payload: notification.payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
      );
      scheduled += 1;
    }
    if (scheduled > 0) {
      _log('Scheduled notifications: $scheduled');
    }
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(iOS: DarwinNotificationDetails());
  }

  Future<void> _configureTimeZones() async {
    tz.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone));
      _log('Configured timezone: $timezone');
    } catch (error, stackTrace) {
      _log(
        'Failed to configure timezone',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode) return;
    debugPrint('[LocalNotificationsService] $message');
    developer.log(
      message,
      name: 'LocalNotificationsService',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
