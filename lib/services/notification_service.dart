import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const _reminderEnabledKey = 'reminderEnabled';
  static const _reminderHourKey = 'reminderHour';
  static const _reminderMinuteKey = 'reminderMinute';

  final FlutterLocalNotificationsPlugin _flutterLocal =
  FlutterLocalNotificationsPlugin();

  NotificationService() {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    _flutterLocal.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
  }

  Future<bool> loadRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reminderEnabledKey) ?? true;
  }

  Future<TimeOfDay> loadReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_reminderHourKey) ?? 9;
    final minute = prefs.getInt(_reminderMinuteKey) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Schedules (or re‐schedules) a daily notification at the given TimeOfDay.
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _flutterLocal.zonedSchedule(
      0,
      'Daily Check-in',
      "Don't forget to log your daily check-in!",
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminder',
          channelDescription: 'Your daily check-in reminder',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllReminders() async {
    await _flutterLocal.cancelAll();
  }
}
