import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import '../../core/app_config.dart';
import '../../services/local_database.dart';
import '../../services/shared_preferences_services.dart';
import '../geo_fencing/geofencing.dart';
import '../geo_fencing/models/geofence_region.dart';
import '../geo_fencing/models/geofence_status.dart';
import 'extensions.dart';
import 'location_database_helper.dart';
import 'location_service.dart';
import 'models.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

@pragma('vm:entry-point')
Future<bool> sendLocationUpdatesToServer(dynamic identifier) async {
  if (!await checkConnectivity()) return false;
  final locationData = await LocationDatabaseHelper.i.getLocations(
    1,
    100,
    synced: false,
    ascending: true,
    identifier: identifier,
  );
  if (locationData.isEmpty) return false;
  final data = {
    "params": {"data": locationData.map((e) => e.toApi()).toList()},
  };
  log(jsonEncode(data));
  // final result =
  //     await DataRepository.i.addUserLocation(locationData).then((value) async {
  //   for (var element in locationData) {
  //     element.serverSynced = "true";
  //   }
  //   await LocationDatabaseHelper.i.updateLocations(locationData);
  //   return Future.value(true);
  // }).onError((error, stackTrace) {
  //   log((error.toString()));
  //   return Future.error(false);
  // });
  return true;
}

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    stopActivityStream();
    geofencing.stop();
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    if (latestPostition == null) {
      await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    }
    batteryLevel = await battery.batteryLevel;
    // sendLocationUpdatesToServer(employee!.employeeId.toString());
    FlutterForegroundTask.updateService(
      notificationTitle: "Your activity is being tracked",
      notificationText: "${wrappedLocation.toMap()}",
    );
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    appConfig = await FlutterForegroundTask.getData<int>(key: "env")
        .then((value) => ENV.fromValue(value).appConfig);
    await SharedPreferencesService.i.initialize();
    await LocationDatabaseHelper.i.database;
    await LocalDatabaseHelper.i.database;
    // batteryLevel = await battery.batteryLevel;
    // employee = await FlutterForegroundTask.getData<String>(
    //         key: currentEmployeeKey)
    //     .then((value) => EmployeeModel.fromForgroundTask(jsonDecode(value!)));
    // latestPostition =
    //     await Geolocator.getCurrentPosition(locationSettings: locationSettings);

    // Set<GeofenceRegion> geofenceRegions = {};
    // if (employee!.autoCheckout && employee!.geofenceRegion != null) {
    //   geofenceRegions.add(
    //     employee!.geofenceRegion!.updateWith(
    //       status: GeofenceStatus.enter,
    //     ),
    //   );
    //   log("geofence region added!");
    // }
    // await geofencing.start(regions: geofenceRegions);
    // geofencing.addLocationChangedListener(locationChangeListener);
    // geofencing.addGeofenceStatusChangedListener(geofenceStatusChangedListener);
    // startActivityStream();
    // logError("started");
  }

  Geofencing geofencing = Geofencing.instance;

  // EmployeeModel? employee;

  Future<void> onActivityPositionUpdate() async {
    // if (employee == null) return;
    // final wrappedLocationData = LocationDataWrapper(
    //   activityPosition: wrappedLocation,
    //   timestamp: wrappedLocation.position.timestamp,
    //   identifier: employee!.employeeId.toString(),
    // );
    // FlutterForegroundTask.sendDataToMain({
    //   "position": wrappedLocationData.toMap(),
    // });
    // LocationDatabaseHelper.i.saveActivityLocations([wrappedLocationData]).then((
    //   _,
    // ) {
    //   log("activity location saved");
    // });
  }

  Future<void> startActivityStream() async {
    if (kDebugMode) {
      await Future.delayed(Duration(
        minutes: 2,
      ));
      latestActivity = Activity(ActivityType.WALKING, ActivityConfidence.HIGH);
      onActivityPositionUpdate();
      await Future.delayed(Duration(
        minutes: 2,
      ));
      latestActivity = Activity(ActivityType.RUNNING, ActivityConfidence.HIGH);
      onActivityPositionUpdate();

      await Future.delayed(Duration(
        minutes: 2,
      ));
      latestActivity =
          Activity(ActivityType.ON_BICYCLE, ActivityConfidence.HIGH);
      onActivityPositionUpdate();

      await Future.delayed(Duration(
        minutes: 2,
      ));
      latestActivity =
          Activity(ActivityType.IN_VEHICLE, ActivityConfidence.HIGH);
      onActivityPositionUpdate();

      await Future.delayed(Duration(
        minutes: 2,
      ));
      latestActivity =
          Activity(ActivityType.IN_VEHICLE, ActivityConfidence.HIGH);
      onActivityPositionUpdate();
      return;
    } else {
      activityStreamSubscription =
          FlutterActivityRecognition.instance.activityStream.listen((event) {
        log(jsonEncode(event));
        if (event.confidence != ActivityConfidence.HIGH) return;
        if (event.type == latestActivity.type) return;
        latestActivity = event;
        onActivityPositionUpdate();
      });
    }
  }

  void stopActivityStream() {
    if (activityStreamSubscription == null) return;
    activityStreamSubscription?.cancel().then((value) {
      activityStreamSubscription = null;
    });
  }

  Battery battery = Battery();

  int batteryLevel = 50;
  StreamSubscription<Activity>? activityStreamSubscription;

  LocationWrapper get wrappedLocation => LocationWrapper(
        position: latestPostition!,
        activity: latestActivity,
        battery: batteryLevel,
      );

  Position? latestPostition;
  Activity latestActivity = Activity(
    ActivityType.STILL,
    ActivityConfidence.HIGH,
  );

  void locationChangeListener(Position location) {
    latestPostition = location;
    onActivityPositionUpdate();
  }

  Future geofenceStatusChangedListener(GeofenceRegion geofenceRegion,
      GeofenceStatus geofenceStatus, Position location) async {
    log(geofenceStatus.toString());
    if (geofenceStatus != GeofenceStatus.exit) return;
    // LocalDatabaseHelper.i.logAttendance([
    //   AttendanceModel(
    //     employeeId: employee!.employeeId!,
    //     timestamp: location.timestamp,
    //     type: LogType.checkout,
    //     latitude: location.latitude,
    //     longitude: location.longitude,
    //   ),
    // ]).then(
    //   (value) {
    //     FCMService().showNotification(
    //       title: geofenceRegion.data.toString(),
    //       body: "You crossed the authorized area.",
    //     );
    //     FlutterForegroundTask.sendDataToMain({
    //       "event": LogType.checkout.event.index,
    //     });
    //     FlutterForegroundTask.stopService();
    //   },
    // );
  }
}
