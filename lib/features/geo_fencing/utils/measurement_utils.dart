import 'package:geolocator/geolocator.dart';

import '../models/geofence_region.dart';
import '../models/geofence_status.dart';
import '../models/lat_lng.dart';

class MeasurementUtils {
  /// Calculates the remaining distance in meters from [location] to [region].
  static double calculateRemainingDistance(
    Position location,
    GeofenceRegion region,
  ) {
    final double lat1 = location.latitude;
    final double lon1 = location.longitude;

    if (region is GeofenceCircularRegion) {
      final double lat2 = region.center.latitude;
      final double lon2 = region.center.longitude;

      final double dist = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
      final double distToBoundary = dist - region.radius;
      if (distToBoundary < 0) {
        // GeofenceStatus.enter
        return 0;
      }

      return distToBoundary;
    } else if (region is GeofencePolygonRegion) {
      final List<LatLng> polygon = region.polygon;
      double distA;
      double distB;
      polygon.sort((a, b) {
        distA = Geolocator.distanceBetween(lat1, lon1, a.latitude, a.longitude);
        distB = Geolocator.distanceBetween(lat1, lon1, b.latitude, b.longitude);
        return (distA < distB) ? -1 : 1;
      });

      final LatLng nearLatLng = polygon[0];
      final double lat2 = nearLatLng.latitude;
      final double lon2 = nearLatLng.longitude;
      final double dist = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
      if (region.status == GeofenceStatus.enter ||
          region.status == GeofenceStatus.dwell) {
        return 0;
      }

      // location.heading + distance to farLatLng => line(location, lineEnd)
      // getIntersections(line, polygon)

      return dist;
    }

    return -1;
  }
}
