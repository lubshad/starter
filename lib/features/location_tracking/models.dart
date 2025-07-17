// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;

extension ActivityTypExtension on ActivityType {
  static ActivityType fromValue(dynamic value) {
    return ActivityType.values.firstWhere(
      (element) => element.name == value,
    );
  }
}

class LocationDataWrapper {
  final int? id;
  final LocationWrapper activityPosition;
  final DateTime timestamp;
  String? serverSynced;
  final String identifier;
  LocationDataWrapper({
    this.id,
    required this.activityPosition,
    required this.timestamp,
    this.serverSynced = "false",
    required this.identifier,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'activity_position': jsonEncode(activityPosition.toMap()),
      'timestamp': timestamp.toUtc().toIso8601String(),
      'server_synced': serverSynced,
      'identifier': identifier,
    };
  }

  Map<String, dynamic> toApi() {
    return <String, dynamic>{
      'activity_position': activityPosition.toMap(),
      'timestamp': timestamp.toUtc().toIso8601String(),
      'identifier': identifier,
    };
  }

  factory LocationDataWrapper.fromApi(Map<String, dynamic> map) {
    final timestamp = DateTime.parse(map['timestamp']).toLocal();
    map["activity_position"]["position"]["timestamp"] =
        timestamp.toUtc().millisecondsSinceEpoch;
    return LocationDataWrapper(
      activityPosition: LocationWrapper.fromMap(
        (map['activity_position'] as Map<String, dynamic>),
      ),
      timestamp: timestamp,
      identifier: map['identifier'].toString(),
      serverSynced: "true",
    );
  }

  factory LocationDataWrapper.fromMap(Map<String, dynamic> map) {
    return LocationDataWrapper(
      id: map['id'] != null ? map['id'] as int : null,
      activityPosition: LocationWrapper.fromMap(
        jsonDecode(map['activity_position']),
      ),
      timestamp: DateTime.parse(map['timestamp']).toLocal(),
      serverSynced: map['server_synced'] as String,
      identifier: map['identifier'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory LocationDataWrapper.fromJson(String source) =>
      LocationDataWrapper.fromMap(json.decode(source) as Map<String, dynamic>);
}

class LocationWrapper {
  final Position position;
  final Activity activity;
  final int battery;
  LocationWrapper({
    required this.position,
    required this.activity,
    required this.battery,
  });

  @override
  String toString() =>
      'position: $position, activity: $activity, battery: $battery';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'position': position.toJson(),
      'activity': activity.toJson(),
      'battery': battery,
    };
  }

  factory LocationWrapper.fromMap(Map<String, dynamic> map) {
    return LocationWrapper(
      position: Position.fromMap(map['position'] as Map<String, dynamic>),
      activity: Activity.fromJson(map['activity'] as Map<String, dynamic>),
      battery: ((map['battery'] ?? 0) as num).toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory LocationWrapper.fromJson(String source) =>
      LocationWrapper.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Sprint {
  String startLocation;
  String endLocation;
  List<LocationWrapper> locations;
  ActivityType activityType;

  double averageSpeed;
  double maxSpeed;
  double displacement;

  Sprint? previousSprint;
  Sprint? nextSprint;
  bool isTraffic;
  DateTime get startTime => locations.first.position.timestamp;
  DateTime get endTime => locations.last.position.timestamp;
  // Duration get duration =>
  //     locations.map((e) => e.position).toList().totalDuration;
  // double get distance =>
  //     locations.map((e) => e.position).toList().totalDistance;
  Map<String, dynamic>? trafficData;

  Sprint({
    this.isTraffic = false,
    this.displacement = 0,
    this.nextSprint,
    this.previousSprint,
    this.averageSpeed = 0,
    this.maxSpeed = 0,
    required this.startLocation,
    required this.endLocation,
    required this.locations,
    this.activityType = ActivityType.UNKNOWN,
    this.trafficData,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'start_location': startLocation,
      'end_location': endLocation,
      'locations': locations.map((x) => x.toJson()).toList(),
      'average_speed': averageSpeed,
      'max_speed': maxSpeed,
      'displacement': displacement,
      'is_traffic': isTraffic,
    };
  }

  factory Sprint.fromMap(Map<String, dynamic> map) {
    return Sprint(
      trafficData: map["traffic_data"],
      isTraffic: map["is_traffic"] == true,
      activityType: ActivityType.fromString(map["activity_type"]),
      startLocation: map['start_location'] as String,
      endLocation: map['end_location'] as String,
      locations: List<LocationWrapper>.from(
        (map['locations'] as List).map<LocationWrapper>(
          (x) {
            return LocationWrapper.fromMap(x as Map<String, dynamic>);
          },
        ),
      ),
      averageSpeed: map['average_speed'] as double,
      maxSpeed: map['max_speed'] as double,
      displacement: map['displacement'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory Sprint.fromJson(String source) =>
      Sprint.fromMap(json.decode(source) as Map<String, dynamic>);
}
