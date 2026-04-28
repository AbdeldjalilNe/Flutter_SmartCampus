import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_constants.dart';
import '../utils/logger.dart';

class NotificationService {
  NotificationService(this._notificationsPlugin);
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    // Android initialization settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    final iosSettings = DarwinInitializationSettings(
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Create notification channels for Android
    await _createNotificationChannels();

    AppLogger.info('Notification service initialized');
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Reminder channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          AppConstants.reminderChannelId,
          AppConstants.reminderChannelName,
          description: AppConstants.reminderChannelDesc,
          importance: Importance.high,
        ),
      );

      // Alert channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          AppConstants.alertChannelId,
          AppConstants.alertChannelName,
          description: AppConstants.alertChannelDesc,
          importance: Importance.max,
        ),
      );
    }
  }

  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    AppLogger.info('Received local notification: $title');
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    AppLogger.info('Notification tapped: ${response.payload}');

    if (response.payload != null) {
      try {
        final payload = jsonDecode(response.payload!) as Map<String, dynamic>;
        final type = payload['type'] as String?;
        final id = payload['id'] as String?;

        // Handle deep linking based on notification type
        _handleNotificationTap(type, id, payload);
      } catch (e) {
        AppLogger.error('Error parsing notification payload', e);
      }
    }
  }

  void _handleNotificationTap(
      String? type, String? id, Map<String, dynamic> payload,) {
    // This will be handled by the navigation system
    // The payload can contain route information for deep linking
    AppLogger.info('Handling notification tap - Type: $type, ID: $id');
  }

  Future<bool> requestPermissions() async {
    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted =
          await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = AppConstants.reminderChannelId,
    String channelName = AppConstants.reminderChannelName,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: importance,
      priority: priority,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );

    AppLogger.info('Notification shown: $title');
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = AppConstants.reminderChannelId,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      AppConstants.reminderChannelName,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    AppLogger.info('Notification scheduled for: $scheduledDate');
  }

  Future<void> scheduleClassReminder({
    required String classId,
    required String courseName,
    required String room,
    required DateTime classTime,
    int reminderMinutesBefore = 10,
  }) async {
    final reminderTime =
        classTime.subtract(Duration(minutes: reminderMinutesBefore));

    if (reminderTime.isBefore(DateTime.now())) {
      AppLogger.warning('Reminder time is in the past, skipping');
      return;
    }

    final payload = jsonEncode({
      'type': 'class_reminder',
      'id': classId,
      'courseName': courseName,
    });

    await scheduleNotification(
      id: classId.hashCode,
      title: 'Upcoming Class: $courseName',
      body: 'Your class starts in $reminderMinutesBefore minutes at $room',
      scheduledDate: reminderTime,
      payload: payload,
    );

    AppLogger.info('Class reminder scheduled for $courseName at $reminderTime');
  }

  Future<void> showAnnouncementNotification({
    required String announcementId,
    required String title,
    required String content,
    required String category,
    bool isUrgent = false,
  }) async {
    final payload = jsonEncode({
      'type': 'announcement',
      'id': announcementId,
      'category': category,
    });

    await showNotification(
      id: announcementId.hashCode,
      title: isUrgent ? 'URGENT: $title' : title,
      body: content.length > 100 ? '${content.substring(0, 100)}...' : content,
      payload: payload,
      channelId: isUrgent
          ? AppConstants.alertChannelId
          : AppConstants.reminderChannelId,
      channelName: isUrgent
          ? AppConstants.alertChannelName
          : AppConstants.reminderChannelName,
      importance: isUrgent ? Importance.max : Importance.high,
      priority: isUrgent ? Priority.max : Priority.high,
    );
  }

  Future<void> showEventReminder({
    required String eventId,
    required String eventTitle,
    required String location,
    required DateTime eventTime,
  }) async {
    final payload = jsonEncode({
      'type': 'event',
      'id': eventId,
    });

    await showNotification(
      id: eventId.hashCode,
      title: 'Event Starting Soon: $eventTitle',
      body:
          'Starting at ${eventTime.hour}:${eventTime.minute.toString().padLeft(2, '0')} - $location',
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    AppLogger.info('Notification cancelled: $id');
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    AppLogger.info('All notifications cancelled');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async =>
      _notificationsPlugin.pendingNotificationRequests();

  Future<void> showOngoingNotification({
    required int id,
    required String title,
    required String body,
    required int progress,
    int maxProgress = 100,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'ongoing_channel',
      'Ongoing Tasks',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
      onlyAlertOnce: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      details,
    );
  }
}
