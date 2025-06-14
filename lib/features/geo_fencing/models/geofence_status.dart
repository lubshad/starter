/// This class represents the geofence state.
enum GeofenceStatus {
  /// The device has entered the geofence area.
  enter,

  /// The device has exited the geofence area.
  exit,

  /// The device stayed in the geofence area longer than the loiteringDelay.
  dwell;

  factory GeofenceStatus.fromName(String name) =>
      GeofenceStatus.values.firstWhere((e) => e.name == name);
}
