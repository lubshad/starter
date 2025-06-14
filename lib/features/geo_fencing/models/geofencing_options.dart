import 'package:geolocator/geolocator.dart';

/// This class represents options that can be set by the geofencing service.
class GeofencingOptions {
  GeofencingOptions({
    this.interval = 5000,
    this.accuracy = LocationAccuracy.high,
    this.statusChangeDelay = 10000,
    this.allowsMockLocation = false,
    this.printsDebugLog = true,
  }) : assert(interval >= 1000);

  /// The millisecond interval at which to update the geofence status.
  ///
  /// This value may be delayed by device platform limitations.
  ///
  /// The default is `5000`.
  final int interval;

  /// The accuracy of the geofencing service in meters.
  ///
  /// The default is `100`.
  final LocationAccuracy accuracy;

  /// The status change delay in milliseconds.
  ///
  /// [GeofenceStatus.enter] and [GeofenceStatus.exit] events may be called
  /// frequently when the location is near the boundary of the geofence.
  ///
  /// If the option value is too large, real-time geofencing is not possible,
  /// so use it carefully.
  ///
  /// The default is `10000`.
  final int statusChangeDelay;

  /// Whether to allow mock location.
  ///
  /// The default is `false`.
  final bool allowsMockLocation;

  /// Whether to print debug logs in plugin.
  ///
  /// The default is `true`.
  final bool printsDebugLog;

  /// Creates a copy of [GeofencingOptions].
  GeofencingOptions copyWith({
    int? interval,
    LocationAccuracy? accuracy,
    int? statusChangeDelay,
    bool? allowsMockLocation,
    bool? printsDebugLog,
  }) =>
      GeofencingOptions(
        interval: interval ?? this.interval,
        accuracy: accuracy ?? this.accuracy,
        statusChangeDelay: statusChangeDelay ?? this.statusChangeDelay,
        allowsMockLocation: allowsMockLocation ?? this.allowsMockLocation,
        printsDebugLog: printsDebugLog ?? this.printsDebugLog,
      );
}
