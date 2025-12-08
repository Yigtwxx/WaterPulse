
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final fln.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      fln.FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    const fln.DarwinInitializationSettings initializationSettingsIOS =
        fln.DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final fln.LinuxInitializationSettings initializationSettingsLinux =
        fln.LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );
    
    const fln.WindowsInitializationSettings initializationSettingsWindows =
        fln.WindowsInitializationSettings(
      appName: 'WaterPulse',
      appUserModelId: 'com.waterpulse.app',
      guid: '81a5501e-7975-4cf5-9002-4c5496732070',
    );

    final fln.InitializationSettings initializationSettings = fln.InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsIOS, 
      linux: initializationSettingsLinux,
      windows: initializationSettingsWindows, // Explicitly pass Windows settings
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            fln.IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleReminders({
    required int intervalMinutes,
    required int startHour,
    required int endHour,
  }) async {
    await cancelAll();

    if (intervalMinutes <= 0) return;

    final now = DateTime.now();
    int id = 0;
    
    DateTime cursor = DateTime(now.year, now.month, now.day, startHour);
    if (cursor.isBefore(now)) {
        while(cursor.isBefore(now)) {
            cursor = cursor.add(Duration(minutes: intervalMinutes));
        }
    }
    
    for(int i=0; i<20; i++) {
        if (cursor.hour >= endHour) {
            cursor = DateTime(cursor.year, cursor.month, cursor.day + 1, startHour);
            continue;
        }
        
        await _scheduleOne(id++, cursor);
        cursor = cursor.add(Duration(minutes: intervalMinutes));
    }
  }
  
  Future<void> _scheduleOne(int id, DateTime time) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Drink Water',
        'Time to hydrate! 💧',
        tz.TZDateTime.from(time, tz.local),
        const fln.NotificationDetails(
            android: fln.AndroidNotificationDetails(
                'water_reminders', 'Water Reminders',
                channelDescription: 'Reminders to drink water',
                importance: fln.Importance.max,
                priority: fln.Priority.high,
            ),
            iOS: fln.DarwinNotificationDetails(),
        ),
        androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
        // uiLocalNotificationDateInterpretation:
        //     fln.UILocalNotificationDateInterpretation.absoluteTime
     );
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
