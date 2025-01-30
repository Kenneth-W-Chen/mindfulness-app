import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class notifications{
  static FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  static const InitializationSettings settings = InitializationSettings(android: AndroidInitializationSettings('default_icon'), iOS: DarwinInitializationSettings());
  static late Location timezone;
  notifications_(){}


  /// Initializes the notification system. Additionally, initializes the timezone database for usage with scheduled notifications.
  static Future<void> init() async{
    initializeTimeZones();
    timezone = getLocation(await FlutterTimezone.getLocalTimezone());
    setLocalLocation(timezone);
    await plugin.initialize(settings);
  }

  /// Schedules a notification for the future.
  /// [id] - the notification's unique identifier. This can be used to cancel or update a specific scheduled notification.
  /// [channelId] - Android-specific argument. ID of the notification's settings group. Each application can have multiple notification channels.
  /// [channelName] - Android-specific argument. Name of the notification's settings group.
  /// [matchDateTimeComponents] - If the notification should be recurring, use this to schedule it.
  static Future<void> schedule(int id, String title, String body, TZDateTime scheduledDate, {String channelId = 'calm_quest_channel_0', String channelName = 'Calm Quest Notifications', DateTimeComponents? matchDateTimeComponents}) async{
    await plugin.zonedSchedule(id, title, body, scheduledDate, NotificationDetails(
      android: AndroidNotificationDetails(channelId, channelName),
      iOS: const DarwinNotificationDetails(presentBadge: false,presentBanner: false,presentList: false)
    ), androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, matchDateTimeComponents: matchDateTimeComponents);
  }
}