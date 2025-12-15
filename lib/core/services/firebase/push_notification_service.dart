import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  PushNotificationService();

  final _messaging = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();
  final _firestore = FirebaseFirestore.instance;

  Future<void> initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _local.initialize(settings);

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'default_channel',
      'General Notifications',
      description: 'Default notification channel',
      importance: Importance.high,
    );

    final androidPlugin = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(androidChannel);
  }

  Future<void> requestPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<String?> getToken() => _messaging.getToken();

  Future<void> sendPushToToken({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Store notification in Firestore for backend to process
      await _firestore.collection('notifications').add({
        'targetToken': token,
        'title': title,
        'body': body,
        'data': data ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
      });
      debugPrint('📣 Notification queued for backend FCM delivery');
    } catch (e) {
      debugPrint('Error queueing notification: $e');
      rethrow;
    }
  }

  // Removed: Firestore listener caused duplicate notifications
  // FCM handles delivery directly via listenForeground()

  void listenForeground() {
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        _local.show(
          notification.hashCode,
          notification.title ?? 'Notification',
          notification.body ?? '',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'General Notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  // This is called by background handler in main.dart
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Background message: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    // FCM automatically shows notification in system tray when app is in background
  }

  // Removed: Pending notifications are handled by FCM
}
