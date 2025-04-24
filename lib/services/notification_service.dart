// lib/services/notification_service.dart
import 'package:flutter/material.dart'; // Needed for TimeOfDay
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz; // Timezone database
import 'package:timezone/timezone.dart' as tz;      // Timezone functions

// Handles scheduling and displaying local notifications
class NotificationService {
  // Singleton pattern: Ensures only one instance of this service exists
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Instance of the notifications plugin
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize the notification service
  Future<void> initialize() async {
    // Android settings: uses the default app icon (@mipmap/ic_launcher)
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings: request necessary permissions on initialization
    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // Callback for when a notification is received while app is in foreground (iOS < 10)
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    // Combine platform settings
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      // linux: null, // Add Linux settings if needed
      // macOS: null, // Add macOS settings if needed
    );

    // Initialize timezone data needed for scheduling
    tz.initializeTimeZones();
    // Set the local timezone (important for correct scheduling)
    // tz.setLocalLocation(tz.getLocation('America/New_York')); // Example: Replace with appropriate timezone if needed, or rely on device's local

    // Initialize the plugin with the settings
    await _notificationsPlugin.initialize(
      initializationSettings,
      // Callback for when a notification response is received (user taps notification)
      // This callback runs when the app is in foreground, background, or terminated
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      // Callback for background notification taps (requires specific setup)
      // onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
    );

    // Explicitly request notification permissions on Android 13+
    await _requestAndroidPermissions();
  }

  // Request notification permission specifically for Android 13 (API 33) and above
  Future<void> _requestAndroidPermissions() async {
    // Resolve the Android specific implementation
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    // Request permission to post notifications
    await androidImplementation?.requestNotificationsPermission();
    // Optional: Request permission for exact alarms if high precision is critical
    // await androidImplementation?.requestExactAlarmsPermission();
  }

  // Request notification permissions explicitly for iOS (if not done on init)
  Future<void> _requestIOSPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }


  // --- Public Methods ---

  // Schedule the daily check-in reminder notification
  Future<void> scheduleDailyReminder(TimeOfDay time, {int id = 0}) async {
    // Cancel any existing notification with the same ID before scheduling a new one
    await _notificationsPlugin.cancel(id);

    // Calculate the next date/time this reminder should fire
    final tz.TZDateTime scheduledDateTime = _nextInstanceOfTime(time);

    // Android specific notification details (channel setup)
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'clarity_break_daily_reminder_channel', // Unique channel ID
      'Daily Check-in Reminder',             // Channel Name (visible in device settings)
      channelDescription: 'Reminds you to check in during your Clarity Break.', // Channel Description
      importance: Importance.low, // Lower importance = less intrusive notification
      priority: Priority.low,
      // icon: '@drawable/notification_icon', // Optional: Use custom icon
    );

    // iOS specific notification details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      // sound: 'reminder_sound.caf', // Optional: Custom sound file
      // badgeNumber: 1, // Optional: Set badge number
    );

    // Combine platform details
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule the notification to repeat daily at the specified time
    await _notificationsPlugin.zonedSchedule(
      id,                                   // Notification ID (use 0 for the daily reminder)
      'Clarity Break Check-in',             // Notification Title
      "How are you feeling today? Tap to add a Journal entry.", // Notification Body
      scheduledDateTime,                    // Calculated next trigger time
      platformDetails,                      // Platform specific details
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Allow precise scheduling even in low power modes
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime, // Interpret time as absolute wall clock time
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily based on time component
      payload: 'journal_checkin', // Optional data to pass when notification is tapped
    );
    debugPrint("Scheduled daily reminder ID $id for $time at $scheduledDateTime");
  }

  // Cancel all scheduled notifications (e.g., when break ends)
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint("Cancelled all scheduled notifications.");
  }

  // --- Helper Functions ---

  // Calculate the next time instance based on the device's local timezone
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local); // Get current time in local timezone
    // Create a schedule date for today using the specified time
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    // If that time has already passed today, schedule it for tomorrow instead
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // --- Notification Interaction Handlers ---

  // Callback when notification is tapped (app foreground, background, or terminated)
  static void onDidReceiveNotificationResponse(NotificationResponse response) {
    debugPrint('Notification Tapped:');
    debugPrint('  ID: ${response.id}');
    debugPrint('  Action ID: ${response.actionId}'); // ID if action buttons were used
    debugPrint('  Payload: ${response.payload}');    // Custom data payload
    debugPrint('  Input: ${response.input}');      // User input from notification (if any)

    // Example: Navigate or perform action based on payload
    // if (response.payload == 'journal_checkin') {
    //   // Maybe use a global key navigator or state management to trigger navigation
    //   // to the Journal screen when the app opens/resumes.
    //   print("Navigate to Journal Screen requested");
    // }
  }

  // Callback for foreground notifications on older iOS versions (<10)
  static void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    // Typically, you wouldn't show an alert if the app is already open.
    // You might update a badge count or silently handle it.
    debugPrint('Foreground notification received on legacy iOS: $id / $title');
  }

// Placeholder for background tap handler (requires top-level function setup)
// @pragma('vm:entry-point')
// static void notificationTapBackground(NotificationResponse notificationResponse) {
//   print("Background notification tapped: ${notificationResponse.payload}");
//   // handle action
// }
}