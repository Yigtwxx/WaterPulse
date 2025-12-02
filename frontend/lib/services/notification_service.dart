import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {},
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        // Handle notification tap
      },
    );
  }

  Future<void> schedulePeriodicNotification() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Hydration Time! 💧',
      'You are close to your daily goal! Keep drinking water.',
      _nextInstanceOfTwoHours(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'waterpulse_channel',
          'WaterPulse Notifications',
          channelDescription: 'Reminders to drink water',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('water_drop'),
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'water_drop.mp3',
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTwoHours() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    // Schedule for 2 hours from now
    // For testing purposes, you might want to change this to seconds or minutes
    return now.add(const Duration(hours: 2));
  }
  
  // Helper to cancel notifications
  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
