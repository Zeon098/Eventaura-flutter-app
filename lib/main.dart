import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'core/services/firebase/firebase_initializer.dart';
import 'core/services/firebase/push_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/global_binding.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebaseInitializer.init();
  await PushNotificationService.handleBackgroundMessage(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
  } catch (_) {
    // ignore missing env file in development
  }
  await FirebaseInitializer.init();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final push = Get.put<PushNotificationService>(
    PushNotificationService(),
    permanent: true,
  );
  await push.initLocalNotifications();
  await push.requestPermission();
  push.listenForeground();
  runApp(const EventauraApp());
}

class EventauraApp extends StatelessWidget {
  const EventauraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Eventaura',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.initial,
      initialBinding: GlobalBinding(),
      getPages: AppPages.routes,
    );
  }
}
