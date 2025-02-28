import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

import 'task_handler.dart';

class FlutterForgroundTaskHelper {
  static Future<ServiceRequestResult> startService({
    String notificationTitle = 'Your activity is being tracked',
    String notificationText = 'Tap to return to the app',
  }) async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        notificationTitle: notificationTitle,
        notificationText: notificationText,
        callback: startCallback,
        notificationIcon: NotificationIcon(
          metaDataName: "com.vz.vface.ForgroundNotificationIcon",
          backgroundColor: Colors.white,
        ),
      );
    }
  }

  static Future<bool> requestPermissions() async {
    ActivityPermission activityPermission =
        await FlutterActivityRecognition.instance.checkPermission();

    if (activityPermission == ActivityPermission.PERMANENTLY_DENIED) {
      // permission has been permanently denied.
      log("activityPermission $activityPermission");
      return false;
    } else if (activityPermission == ActivityPermission.DENIED) {
      activityPermission =
          await FlutterActivityRecognition.instance.requestPermission();
      if (activityPermission != ActivityPermission.GRANTED) {
        log("activityPermission $activityPermission");
        // permission is denied.
        return false;
      }
    }
    // Android 13+, you need to allow notification permission to display foreground service notification.
    //
    // iOS: If you need notification, ask for permission.
    NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      notificationPermission =
          await FlutterForegroundTask.requestNotificationPermission();

      if (notificationPermission != NotificationPermission.granted) {
        log(notificationPermission.toString());
        return false;
      }
    }
    if (Platform.isAndroid) {
      // Android 12+, there are restrictions on starting a foreground service.
      //
      // To restart the service on device reboot or unexpected problem, you need to allow below permission.
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
        final isIgnoringBatteryOptimizations =
            await FlutterForegroundTask.requestIgnoreBatteryOptimization();
        if (!isIgnoringBatteryOptimizations) {
          log(
            "isIgnoringBatteryOptimizations $isIgnoringBatteryOptimizations",
          );
          return false;
        }
      }

      // Use this utility only if you provide services that require long-term survival,
      // such as exact alarm service, healthcare service, or Bluetooth communication.
      //
      // This utility requires the "android.permission.SCHEDULE_EXACT_ALARM" permission.
      // Using this permission may make app distribution difficult due to Google policy.
      if (!await FlutterForegroundTask.canScheduleExactAlarms) {
        // When you call this function, will be gone to the settings page.
        // So you need to explain to the user why set it.
        final canScheduleExactAlarms =
            await FlutterForegroundTask.openAlarmsAndRemindersSettings();
        if (!canScheduleExactAlarms) {
          log("canScheduleExactAlarms $canScheduleExactAlarms");
          return false;
        }
      }

      /// Geting geolocation permissions.
      final geoServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!geoServiceEnabled) {
        log("geoServiceEnabled $geoServiceEnabled");
        return false;
      }

      var locationPermission = await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.deniedForever) {
        log("locationPermission $locationPermission");
        return false;
      }

      locationPermission = await Geolocator.requestPermission();

      if (locationPermission != LocationPermission.whileInUse) {
        log("locationPermission $locationPermission");
        return false;
      }
    }
    return true;
  }
}
