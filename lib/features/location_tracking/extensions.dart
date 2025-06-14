import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/models/activity_type.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;

Future<bool> checkConnectivity() async {
  final positiveResult = [
    ConnectivityResult.mobile,
    ConnectivityResult.wifi,
    ConnectivityResult.ethernet
  ];
  final result = await Connectivity().checkConnectivity();
  if (!result.any((element) => positiveResult.contains(element))) {
    return false;
  }
  return true;
}

extension ActivityTypeExtension on ActivityType {
  Color get color {
    switch (this) {
      case ActivityType.IN_VEHICLE:
        return Colors.blue;
      case ActivityType.ON_BICYCLE:
        return Colors.blue;
      case ActivityType.RUNNING:
        return Colors.blue;
      case ActivityType.STILL:
        return Colors.amber;
      case ActivityType.WALKING:
        return Colors.blue;
      case ActivityType.UNKNOWN:
        return Colors.amber;
    }
  }
}

extension DurationExtension on List<Position> {
  Duration get totalDuration {
    if (length < 2) return Duration.zero;
    return last.timestamp.difference(first.timestamp);
  }

  double get totalDistance {
    if (length < 2) return 0;
    double distance = 0;
    for (int i = 0; i < length - 1; i++) {
      distance += Geolocator.distanceBetween(this[i].latitude,
          this[i].longitude, this[i + 1].latitude, this[i + 1].longitude);
    }
    return distance;
  }
}
