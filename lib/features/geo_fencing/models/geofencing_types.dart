import 'package:geolocator/geolocator.dart';

import 'geofence_region.dart';
import 'geofence_status.dart';

typedef GeofenceStatusChanged = Future<void> Function(
  GeofenceRegion geofenceRegion,
  GeofenceStatus geofenceStatus,
  Position location,
);

typedef GeofenceErrorCallback = void Function(
  Object error,
  StackTrace stackTrace,
);

typedef LocationChanged = void Function(Position location);

typedef LocationServicesStatusChanged = void Function(ServiceStatus status);
