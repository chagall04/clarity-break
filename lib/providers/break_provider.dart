import 'package:flutter/material.dart';
import '../services/break_service.dart';
import '../models/break_details.dart';
import '../services/notification_service.dart'; // <-- we renamed
import 'package:shared_preferences/shared_preferences.dart';


class BreakProvider with ChangeNotifier {
  final BreakService _breakService = BreakService();
  final NotificationService _notificationService = NotificationService();

  BreakDetails _currentBreak = BreakDetails.none;
  bool _isLoading = true;
  bool _remindersEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  static const String _reminderEnabledKey = 'reminderEnabled';
  static const String _reminderHourKey = 'reminderHour';
  static const String _reminderMinuteKey = 'reminderMinute';

  BreakDetails get currentBreak => _currentBreak;
  bool get isLoading => _isLoading;
  bool get remindersEnabled => _remindersEnabled;
  TimeOfDay get reminderTime => _reminderTime;

  BreakProvider() {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    _isLoading = true;
    if (hasListeners) notifyListeners();

    _currentBreak = await _breakService.getCurrentBreakDetails();
    await _loadReminderSettings();

    _isLoading = false;
    if (hasListeners) notifyListeners();

    await _updateScheduledNotification();
  }

  Future<void> _loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _remindersEnabled = prefs.getBool(_reminderEnabledKey) ?? true;
    final hour = prefs.getInt(_reminderHourKey) ?? 9;
    final minute = prefs.getInt(_reminderMinuteKey) ?? 0;
    _reminderTime = TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> startNewBreak(String userWhy, int duration) async {
    if (_currentBreak.isActive) return;
    await _breakService.startBreak(userWhy, duration);
    await _loadInitialState();
  }

  Future<void> endCurrentBreak() async {
    if (!_currentBreak.isActive) return;
    await _breakService.endBreak();
    // **Here’s the one change**: renamed cancelAllNotifications → cancelAllReminders
    await _notificationService.cancelAllReminders();
    await _loadInitialState();
  }

  Future<void> setRemindersEnabled(bool enabled) async {
    if (_remindersEnabled == enabled) return;
    _remindersEnabled = enabled;
    await _saveReminderSettings();
    await _updateScheduledNotification();
    if (hasListeners) notifyListeners();
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    if (_reminderTime == time) return;
    _reminderTime = time;
    await _saveReminderSettings();
    await _updateScheduledNotification();
    if (hasListeners) notifyListeners();
  }

  Future<void> reloadAllState() async => _loadInitialState();

  Future<void> _saveReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, _remindersEnabled);
    await prefs.setInt(_reminderHourKey, _reminderTime.hour);
    await prefs.setInt(_reminderMinuteKey, _reminderTime.minute);
  }

  Future<void> _updateScheduledNotification() async {
    if (_currentBreak.isActive && _remindersEnabled) {
      await _notificationService.scheduleDailyReminder(_reminderTime);
    } else {
      // **And here too**
      await _notificationService.cancelAllReminders();
    }
  }
}
