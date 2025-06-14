/// This class represents the geofence type.
enum GeofenceType {
  /// A geofence with a circular shape.
  circular,

  /// A geofence with a polygon shape.
  polygon;

  factory GeofenceType.fromName(String name) =>
      GeofenceType.values.firstWhere((e) => e.name == name);
}
