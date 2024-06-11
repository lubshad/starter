import 'package:firebase_messaging/firebase_messaging.dart';

import '../exporter.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  logInfo("Handling a background message: ${message.notification?.title}");
}

mixin FCMService {
  static Future<String?> get token async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      return "";
    }
  }

  static requestPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    logInfo('User granted permission: ${settings.authorizationStatus}');
  }

  static void setupNotification() async {
    await requestPermission();
    FirebaseMessaging.onMessage.listen((event) => onMessage(event));
    FirebaseMessaging.onMessageOpenedApp
        .listen((event) => onMessageOpenedApp(event));
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  }

  static onMessage(RemoteMessage event) {
    logInfo("Received message: ${event.notification?.title}");
  }

  static onMessageOpenedApp(RemoteMessage event) {
    logInfo("App opened by notification: ${event.notification?.title}");
  }
}
