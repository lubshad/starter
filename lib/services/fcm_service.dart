import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/repository.dart';
import '../exporter.dart';
import '../mixins/event_listener.dart';
import 'shared_preferences_services.dart';

final StreamController<NotificationResponse>
onDidReceiveNotificationResponseStream =
    StreamController<NotificationResponse>.broadcast();

const MethodChannel platform = MethodChannel(
  'dexterx.dev/flutter_local_notifications_example',
);

const String portName = 'notification_send_port';

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

int id = 0;

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  // ignore: avoid_print
  print("Handling a background message: ${message.notification?.toMap()}");
}

@pragma('vm:entry-point')
void notificationTapBackground(
  NotificationResponse notificationResponse,
) async {
  // ignore: avoid_print
  print(
    'notification(${notificationResponse.id}) action tapped: '
    '${notificationResponse.actionId} with'
    ' payload: ${notificationResponse.payload}',
  );
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
      'notification action tapped with input: ${notificationResponse.input}',
    );
  }
  final payload = notificationResponse.payload;
  if (payload == null) return;
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesService.i.initialize();
  await SharedPreferencesService.i.setValue(
    key: notificationDataKey,
    value: payload,
  );
}

class FCMService {
  static Future<String?> get token async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      return "";
    }
  }

  requestPermission() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_launcher');

    final List<DarwinNotificationCategory> darwinNotificationCategories =
        <DarwinNotificationCategory>[
          DarwinNotificationCategory(
            darwinNotificationCategoryText,
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.text(
                'text_1',
                'Action 1',
                buttonTitle: 'Send',
                placeholder: 'Placeholder',
              ),
            ],
          ),
          DarwinNotificationCategory(
            darwinNotificationCategoryPlain,
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.plain('id_1', 'Action 1'),
              DarwinNotificationAction.plain(
                'id_2',
                'Action 2 (destructive)',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.destructive,
                },
              ),
              DarwinNotificationAction.plain(
                navigationActionId,
                'Action 3 (foreground)',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.foreground,
                },
              ),
              DarwinNotificationAction.plain(
                'id_4',
                'Action 4 (auth required)',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.authenticationRequired,
                },
              ),
            ],
            options: <DarwinNotificationCategoryOption>{
              DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
            },
          ),
        ];
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          notificationCategories: darwinNotificationCategories,
        );

    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
          defaultActionName: 'Open notification',
          defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
          linux: initializationSettingsLinux,
          // windows: windows.initSettings,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          onDidReceiveNotificationResponseStream.add,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        !kIsWeb && Platform.isLinux
            ? null
            : await flutterLocalNotificationsPlugin
                .getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      logInfo(notificationAppLaunchDetails!.notificationResponse?.payload);
    }
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
          alert: true,
          announcement: true,
          badge: true,
          carPlay: true,
          criticalAlert: true,
          provisional: true,
          sound: true,
        );
    logInfo(
      'User granted permission For Firebase: ${settings.authorizationStatus}',
    );
    await requestPermissions();
    await isAndroidPermissionGranted();
  }

  Future<String> setupNotification() async {
    await requestPermission();
    FirebaseMessaging.onMessage.listen(onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    onDidReceiveNotificationResponseStream.stream.listen(
      onDidReceiveNotificationOpen,
    );
    return await token ?? "";
  }

  static onMessage(RemoteMessage event) {
    logInfo(event.toMap());
    FCMService().showNotification(
      title: event.notification?.title,
      body: event.notification?.body,
      payload: event.data["url"],
    );
    EventListener.i.sendEvent(Event(eventType: EventType.notification));
  }

  static onMessageOpenedApp(RemoteMessage event) async {
    // ignore: avoid_print
    print(event.toMap());
    if (event.data["url"] == null) return;
    handleHrefLink(event.data["url"]);
  }

  static void handleNotificationData() async {
    String? data = SharedPreferencesService.i.getValue(
      key: notificationDataKey,
    );
    if (data.isEmpty) {
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      data = initialMessage?.data["url"];
    }
    if (data == null || data.isEmpty) return;
    await handleHrefLink(data);
    SharedPreferencesService.i.setValue(key: notificationDataKey, value: "");
  }

  Future<void> isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted =
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.areNotificationsEnabled() ??
          false;

      logInfo(granted);
    }
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      logInfo(grantedNotificationPermission);
    }
  }

  Future<void> showNotification({
    String? title,
    String? body,
    dynamic payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      id++,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  void onDidReceiveNotificationOpen(NotificationResponse event) {
    if (event.payload == null) return;
    handleHrefLink(event.payload);
  }

  static handleHrefLink(link) {
    logInfo(link);
    Uri? uri = Uri.tryParse(link);
    if (uri == null) return;
    logInfo(uri.path);
    logInfo(uri.queryParameters);
    logInfo(uri);
    // if (uri.queryParameters.containsKey("model")) {
    //   final id = uri.queryParameters["id"] as int;
    //   switch (AppModule.fromValue(uri.queryParameters["model"])) {
    //     case AppModule.employee:
    //       navigate(navigatorKey.currentContext!, EmployeeListingScreen.path);
    //     case AppModule.timesheet:
    //       navigate(navigatorKey.currentContext!, TimesheetListingScreen.path);
    //     case AppModule.timeoff:
    //       navigate(navigatorKey.currentContext!, TimeoffDetailsScreen.path,
    //           arguments: id);

    //     case AppModule.salaryAdvance:
    //       navigate(navigatorKey.currentContext!, SalaryAdvanceDetails.path,
    //           arguments: id);

    //     case AppModule.expense:
    //       navigate(
    //           navigatorKey.currentContext!, ExpenseReportDetailsScreen.path,
    //           arguments: id);

    //     case AppModule.pettycashAdvance:
    //       navigate(navigatorKey.currentContext!, PettyCashAdvanceDetail.path,
    //           arguments: id);

    //     case AppModule.project:
    //     case AppModule.task:
    //     case AppModule.lognote:
    //     case AppModule.delivery:
    //       throw UnimplementedError();
    //   }
    // }
    launchUrl(uri);
  }

  void initialize() async {
    await setupNotification().then((value) async {
      await DataRepository.i.updateToken(token: value);
      FirebaseMessaging.instance.onTokenRefresh.listen((event) async {
        await DataRepository.i.updateToken(token: event);
      });
      handleNotificationData();
    });
  }
}
