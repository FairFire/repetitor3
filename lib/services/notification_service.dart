import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  final BehaviorSubject<String> _notificationStream = BehaviorSubject();

  Stream<String> get notificationStream => _notificationStream.stream;

  Future<void> init() async {
    tz_data.initializeTimeZones();
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          'ic_notification',
        ); // или '@mipmap/ic_launcher'

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        _notificationStream.add(details.payload ?? '');
      },
    );
  }

  Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // Отменяем, если уже запланировано (защита от дублей)
    await _notificationsPlugin.cancel(id);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'lesson_channel',
          'Уроки',
          channelDescription: 'Уведомления о занятиях',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'Напоминание об уроке',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.zonedSchedule(
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformChannelSpecifics,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
