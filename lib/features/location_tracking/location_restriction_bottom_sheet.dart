import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../exporter.dart';
import '../../widgets/common_sheet.dart';
import '../../widgets/loading_button.dart';
import '../geo_fencing/models/geofence_region.dart';

class LocationRestrictionBottomSheet extends StatefulWidget {
  const LocationRestrictionBottomSheet({
    super.key,
    required this.geofenceRegion,
  });
  final GeofenceRegion geofenceRegion;

  @override
  State<LocationRestrictionBottomSheet> createState() =>
      _LocationRestrictionBottomSheetState();
}

class _LocationRestrictionBottomSheetState
    extends State<LocationRestrictionBottomSheet> {
  GoogleMapController? mapController;

  double get zoomLevel {
    switch ((widget.geofenceRegion as GeofenceCircularRegion).radius) {
      case <= 10:
        return 20;
      case <= 50:
        return 18;
      case <= 100:
        return 17;
      case <= 500:
        return 14;
      case <= 1000:
        return 13;
      case <= 2000:
        return 12;
      case <= 5000:
        return 11;
      default:
        return 14;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonBottomSheet(
        title: "Unauthorized Location",
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      (widget.geofenceRegion as GeofenceCircularRegion)
                          .center
                          .latitude,
                      (widget.geofenceRegion as GeofenceCircularRegion)
                          .center
                          .longitude,
                    ),
                    zoom: zoomLevel,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  circles: {
                    Circle(
                      circleId: CircleId('restrictedZone'),
                      center: LatLng(
                        (widget.geofenceRegion as GeofenceCircularRegion)
                            .center
                            .latitude,
                        (widget.geofenceRegion as GeofenceCircularRegion)
                            .center
                            .longitude,
                      ),
                      radius: (widget.geofenceRegion as GeofenceCircularRegion)
                          .radius, // widget.geoRestriction.radius meters radius
                      fillColor: Colors.green.withAlpha(
                        100,
                      ),
                      strokeColor: Colors.green,
                      strokeWidth: 2,
                    ),
                  }),
            ),
            gapXL,
            Text(
              (widget.geofenceRegion as GeofenceCircularRegion).data.toString(),
              textAlign: TextAlign.center,
            ),
            gapXL,
            LoadingButton(
                buttonLoading: false,
                text: "OK",
                onPressed: () => Navigator.pop(
                      context,
                      true,
                    )),
          ],
        ));
  }
}
