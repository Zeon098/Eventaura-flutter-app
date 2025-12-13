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
      // Store notification in Firestore
      // Will be delivered when recipient app is open or comes back online
      await _firestore.collection('notifications').add({
        'targetToken': token,
        'title': title,
        'body': body,
        'data': data ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
      debugPrint('📣 Notification queued in Firestore');
      debugPrint(
        'ℹ️ Note: Background notifications (app killed) require Cloud Functions or backend server',
      );
    } catch (e) {
      debugPrint('Error sending notification: $e');
      rethrow;
    }
  }

  void listenForNotifications(String userId) {
    _messaging.getToken().then((token) {
      if (token == null) return;

      _firestore
          .collection('notifications')
          .where('targetToken', isEqualTo: token)
          .where('read', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
            for (final doc in snapshot.docChanges) {
              if (doc.type == DocumentChangeType.added) {
                final data = doc.doc.data();
                if (data != null) {
                  _showLocalNotification(
                    data['title'] ?? 'Notification',
                    data['body'] ?? '',
                  );
                  // Mark as read
                  doc.doc.reference.update({'read': true});
                }
              }
            }
          });
    });
  }

  void _showLocalNotification(String title, String body) {
    _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
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

  // Check for pending notifications when app opens
  Future<void> checkPendingNotifications() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      final snapshot = await _firestore
          .collection('notifications')
          .where('targetToken', isEqualTo: token)
          .where('read', isEqualTo: false)
          .limit(10)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        _showLocalNotification(
          data['title'] ?? 'Notification',
          data['body'] ?? '',
        );
        doc.reference.update({'read': true});
      }
    } catch (e) {
      debugPrint('Error checking pending notifications: $e');
    }
  }
}
