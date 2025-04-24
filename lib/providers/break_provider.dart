// lib/providers/break_provider.dart
import 'package:flutter/material.dart';
import '../services/break_service.dart';      // Data storage service
import '../models/break_details.dart';       // Break state model
import '../services/notification_service.dart'; // Notification service
import 'package:shared_preferences/shared_preferences.dart'; // For saving settings

// Manages break state and reminder settings
class BreakProvider with ChangeNotifier {
  final BreakService _breakService = BreakService();
  final NotificationService _notificationService = NotificationService(); // Instantiate service
  BreakDetails _currentBreak = BreakDetails.none; // Current break status

  BreakDetails get currentBreak => _currentBreak;

  bool _isLoading = true; // Loading state flag
  bool get isLoading => _isLoading;

  // Reminder Settings state
  bool _remindersEnabled = true; // Default: reminders on
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0); // Default: 9:00 AM
  bool get remindersEnabled => _remindersEnabled;
  TimeOfDay get reminderTime => _reminderTime;

  // Keys for storing settings in SharedPreferences
  static const String _reminderEnabledKey = 'reminderEnabled';
  static const String _reminderHourKey = 'reminderHour';
  static const String _reminderMinuteKey = 'reminderMinute';

  // Constructor: Load initial state when provider is created
  BreakProvider() {
    _loadInitialState();
  }

  // Load break details AND reminder settings from storage
  Future<void> _loadInitialState() async {
    _isLoading = true;
    notifyListeners(); // Notify UI about loading start

    _currentBreak = await _breakService.getCurrentBreakDetails(); // Load break status
    await _loadReminderSettings(); // Load reminder preferences

    _isLoading = false;
    notifyListeners(); // Notify UI about loading end

    // Schedule notification if needed based on loaded state
    await _updateScheduledNotification();
  }

  // Load reminder preferences from SharedPreferences
  Future<void> _loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _remindersEnabled = prefs.getBool(_reminderEnabledKey) ?? true; // Default true if not set
    final hour = prefs.getInt(_reminderHourKey) ?? 9; // Default 9 AM hour
    final minute = prefs.getInt(_reminderMinuteKey) ?? 0; // Default 00 minute
    _reminderTime = TimeOfDay(hour: hour, minute: minute);
  }

  // Save current reminder preferences to SharedPreferences
  Future<void> _saveReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, _remindersEnabled);
    await prefs.setInt(_reminderHourKey, _reminderTime.hour);
    await prefs.setInt(_reminderMinuteKey, _reminderTime.minute);
  }

  // Update the reminder enabled status
  Future<void> setRemindersEnabled(bool enabled) async {
    if (_remindersEnabled == enabled) return; // Avoid unnecessary work if no change
    _remindersEnabled = enabled;
    await _saveReminderSettings(); // Save the new setting
    await _updateScheduledNotification(); // Schedule or cancel based on new setting
    notifyListeners(); // Update UI reflecting the change
  }

  // Update the reminder time
  Future<void> setReminderTime(TimeOfDay time) async {
    if (_reminderTime.hour == time.hour && _reminderTime.minute == time.minute) return; // Check for actual change
    _reminderTime = time;
    await _saveReminderSettings(); // Save the new time
    await _updateScheduledNotification(); // Re-schedule with the new time (if enabled)
    notifyListeners(); // Update UI reflecting the change
  }


  // Start a new break
  Future<void> startNewBreak(String userWhy) async {
    if (_currentBreak.isActive) return; // Prevent starting if already active

    await _breakService.startBreak(userWhy);
    await _loadInitialState(); // Reload state (this will also schedule notification)
  }

  // End the current break
  Future<void> endCurrentBreak() async {
    if (!_currentBreak.isActive) return; // Prevent ending if not active

    await _breakService.endBreak();
    // *** Crucial: Cancel notifications when break ends ***
    await _notificationService.cancelAllNotifications();
    await _loadInitialState(); // Reload state
  }

  // Helper to schedule or cancel notification based on current state
  Future<void> _updateScheduledNotification() async {
    if (_currentBreak.isActive && _remindersEnabled) {
      // If break active and reminders enabled, schedule it
      await _notificationService.scheduleDailyReminder(_reminderTime);
    } else {
      // Otherwise (break inactive OR reminders disabled), cancel all
      await _notificationService.cancelAllNotifications();
    }
  }

  // Method to reload state (e.g., after resetting data)
  Future<void> reloadAllState() async {
    await _loadInitialState();
  }
}