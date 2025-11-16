// ignore_for_file: public_member_api_docs, sort_constructors_first, depend_on_referenced_packages
import 'dart:async';
import 'dart:ui' as ui;
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:geocoding/geocoding.dart' hide Location;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/app_route.dart';
import '../../exporter.dart';
import '../../main.dart';
import '../geo_fencing/geofencing.dart';
import '../geo_fencing/models/geofence_region.dart';

import 'location_enable_guide.dart';
import 'location_restriction_bottom_sheet.dart';

@pragma('vm:entry-point')
LocationSettings get locationSettings {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return AndroidSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);
  } else if (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    return AppleSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);
  } else if (kIsWeb) {
    return WebSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);
  } else {
    return LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
  }
}

class LocationService extends ChangeNotifier {
  static final LocationService _instance = LocationService._internal();

  static LocationService get i => _instance;
  LocationService._internal();
  static LatLngBounds getBounds(List<Position> positions) {
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (var position in positions) {
      if (position.latitude < minLat) minLat = position.latitude;
      if (position.latitude > maxLat) maxLat = position.latitude;
      if (position.longitude < minLng) minLng = position.longitude;
      if (position.longitude > maxLng) maxLng = position.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  String get displayLocation =>
      [null, ""].contains(placemarks.firstOrNull?.name)
      ? "Unknown".tr
      : placemarks.first.name!;

  String get displayLocationName =>
      [null, ""].contains(placemarks.firstOrNull?.locality)
      ? "Unknown".tr
      : placemarks.first.locality!;

  static void adjustCameraView(
    GoogleMapController controller,
    LatLngBounds bounds,
  ) {
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  static Future<BitmapDescriptor> createCustomMarker(
    Uint8List imageData,
    Color borderColor,
  ) async {
    try {
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);
      final double size = 1.sw * .5;
      final double borderSize = 10.0;

      // Draw border
      final Paint borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size / 2, size / 2), (size / 2), borderPaint);

      // Draw Image inside the border
      final double imageRadius = (size / 2) - borderSize;
      final ui.Image image = await decodeImageFromList(imageData);

      canvas.clipPath(
        Path()..addOval(
          Rect.fromCircle(
            center: Offset(size / 2, size / 2),
            radius: imageRadius,
          ),
        ),
      );
      paintImage(
        canvas: canvas,
        rect: Rect.fromCircle(
          center: Offset(size / 2, size / 2),
          radius: imageRadius,
        ),
        image: image,
        fit: BoxFit.cover,
      );

      // Convert canvas to Image
      final ui.Image finalImage = await pictureRecorder.endRecording().toImage(
        size.toInt(),
        size.toInt(),
      );
      final ByteData? byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List markerImage = byteData!.buffer.asUint8List();

      return BitmapDescriptor.bytes(
        width: paddingXL * 1.8.h,
        height: paddingXL * 1.8.h,
        markerImage,
      );
    } catch (e) {
      throw Exception('Error creating marker image: $e');
    }
  }

  // setupGeoTracking(LogType type) async {
  // if (!Platform.isAndroid) return;
  // // need to start only if autocheckout or livetracking is required
  // if (!(CommonController.i.profileDetails!.employee.autoCheckout == true ||
  //     CommonController.i.profileDetails!.employee.liveTracking == true)) {
  //   return;
  // }

  // if (type == LogType.checkout) {
  //   await FlutterForegroundTask.stopService();
  // } else {
  //   await FlutterForgroundTaskHelper.startService();
  // }
  // }

  bool checkWithinRadius(GeofenceRegion geofenceRegion) {
    if (position == null) return false;

    final isWithin = Geofencing.checkWitinTheRegion(position!, geofenceRegion);
    // Check if the distance is within the radius
    if (!isWithin) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: navigatorKey.currentContext!,
        builder: (context) => LocationRestrictionBottomSheet(
          geofenceRegion: geofenceRegion as GeofenceCircularRegion,
        ),
      );
    }
    return isWithin;
  }

  Future<bool> _handlePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    LocationPermission neededPermission = LocationPermission.whileInUse;
    if (permission != LocationPermission.always &&
            permission != neededPermission &&
            navigatorKey.currentContext != null ||
        !serviceEnabled) {
      navigate(
        navigatorKey.currentContext!,
        LocationEnableGuide.path,
        duplicate: false,
        arguments: neededPermission,
      );
      return false;
    }
    return true;
  }

  Position? position;
  List<Placemark> placemarks = [];
  CountryCode countryCode = CountryCode.fromCountryCode("IN");

  Future<void> setCountryCode() async {
    if (placemarks.isEmpty) return;

    countryCode = CountryCode.fromCountryCode(
      placemarks.first.isoCountryCode ?? "IN",
    );
    notifyListeners();
  }

  Future<void> setPlaceMarks() async {
    if (position == null) return;
    placemarks = await placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );
    setCountryCode();
  }

  Future<Position?> getCurrentPosition({bool direct = false}) async {
    if (direct) {
      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
    }
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return null;
    }
    position =
        await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        ).onError((error, stackTrace) {
          logError(error);
          return Future.error(error!);
        });
    setPlaceMarks();
    return position;
  }

  bool isWithinRadius(
    double centerLat,
    double centerLng,
    double checkLat,
    double checkLng,
    double radius,
  ) {
    final distance = Geolocator.distanceBetween(
      centerLat,
      centerLng,
      checkLat,
      checkLng,
    );

    return distance <= radius;
  }

  String locationName(Placemark data) {
    final text = "${data.street}, ${data.subLocality}, ${data.locality}";
    return text;
  }
}
