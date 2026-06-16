import 'dart:io';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// Singleton service that manages all local push notifications.
/// Call [initialize] once in main() before runApp.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    // tz.local defaults to UTC; without this, "09:00" would fire at 09:00 UTC
    // (12:00 in Turkey). Pin to the user's local zone so reminders fire on time.
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions on Android 13+ (notifications) and 12+ (exact alarms).
    // exactAllowWhileIdle scheduling silently fails without the exact-alarm grant.
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Future: navigate to the specific habit detail screen
    // using a GlobalKey<NavigatorState> or similar navigation pattern.
  }

  /// Schedule a daily repeating notification for a habit.
  Future<void> scheduleDailyNotification({
    required String id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    bool isAlarm = false,
  }) async {
    final notificationId = id.hashCode.abs() % 100000;

    final androidDetails = AndroidNotificationDetails(
      isAlarm ? 'habit_alarms' : 'habit_reminders',
      isAlarm ? 'Habit Alarms' : 'Habit Reminders',
      channelDescription: isAlarm ? 'Daily alarms for your habits' : 'Daily reminders for your habits',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF00E5C3),
      fullScreenIntent: isAlarm,
      category: isAlarm ? AndroidNotificationCategory.alarm : AndroidNotificationCategory.reminder,
      audioAttributesUsage: isAlarm ? AudioAttributesUsage.alarm : AudioAttributesUsage.notification,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Show an immediate test notification (no scheduling) to verify that the
  /// notification pipeline (channel + permission + receivers) works end-to-end.
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Daily reminders for your habits',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      id: 999999,
      title: 'Test 🔔',
      body: 'Notifications are working!',
      notificationDetails: details,
    );
  }

  /// Cancel a scheduled notification by habit id.
  Future<void> cancelNotification(String habitId) async {
    await _plugin.cancel(id: habitId.hashCode.abs() % 100000);
  }

  /// Cancel ALL scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
