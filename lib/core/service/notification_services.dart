import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  static final NotificationServices _instance =
      NotificationServices._internal();
  factory NotificationServices() => _instance;
  NotificationServices._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Make sure this matches your launcher icon

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap when app is in foreground
      },
    );

    _isInitialized = true;
  }

  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Ensure service is initialized
    await init();

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'otp_channel', // Same channel ID as in your details
      'OTP Verification',
      channelDescription: 'Channel for OTP verification notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      showWhen: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
