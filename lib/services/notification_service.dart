import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidInitSettings);

    await _notificationsPlugin.initialize(settings);
    tz.initializeTimeZones();
  }

  static Future<void> scheduleDailyNotification() async {
    await _notificationsPlugin.zonedSchedule(
      0,
      'Expense Reminder 📢',
      'Don’t forget to log your expenses for today!',
      // _nextInstanceOfTime(09, 00), // 9:00 PM daily
      tz.TZDateTime.now(tz.local).add(Duration(seconds: 10)), // Trigger after 10 seconds
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'expense_reminder_channel',
          'Daily Expense Reminder',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }
}
