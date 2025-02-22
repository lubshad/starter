// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../exporter.dart';
import '../mixins/event_listener.dart';
import '../widgets/common_sheet.dart';
import '../widgets/loading_button.dart';

class GeoRestriction {
  final double latitude;
  final double longitude;
  final double radius;
  final String message;
  GeoRestriction({
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'message': message,
    };
  }

  factory GeoRestriction.fromMap(Map<String, dynamic> map) {
    return GeoRestriction(
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      radius: (map['radius'] as num).toDouble(),
      message: map['message'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GeoRestriction.fromJson(String source) =>
      GeoRestriction.fromMap(json.decode(source) as Map<String, dynamic>);
}

class LocationService extends ChangeNotifier {
  LocationService._private() {
    setupLocationSettings();
  }

  late LocationSettings locationSettings;

  setupLocationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),

        //(Optional) Set foreground notification config to keep the app alive
        //when going to the background
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:
              "The app will continue to receive your location even when you aren't using it. You will be checked out automatically if you cross the allowed area or you closed the app",
          notificationTitle: "Location is observed",
          enableWakeLock: true,
          enableWifiLock: true,
          setOngoing: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.otherNavigation,
        distanceFilter: 10,
        pauseLocationUpdatesAutomatically: false,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: true,
      );
    } else if (kIsWeb) {
      locationSettings = WebSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        maximumAge: const Duration(seconds: 10),
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }
  }

  StreamSubscription<Position>? positionStream;

  CountryCode countryCode = CountryCode.fromCountryCode("IN");

  static LocationService? _instance;

  Position? position;

  fetchCurrentPosition() async {
    position = await _getCurrentPosition();
    notifyListeners();
  }

  static LocationService get i {
    _instance ??= LocationService._private();
    return _instance!;
  }

  Future<void> setCountryCode() async {
    if (placemarks.isEmpty) return;
    countryCode =
        CountryCode.fromCountryCode(placemarks.first.isoCountryCode ?? "IN");
    notifyListeners();
  }

  List<Placemark> placemarks = [];

  bool initialized = false;

  Future<bool> _handlePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    logInfo(serviceEnabled);
    logInfo(serviceEnabled);
    LocationPermission permission = await Geolocator.checkPermission();
    logInfo(permission);
    // LocationPermission neededPermission =
    //     CommonController.i.profileDetails!.employee.autocheckout
    //         ? LocationPermission.always
    //         : LocationPermission.whileInUse;
    // if (permission != LocationPermission.always &&
    //         permission != neededPermission &&
    //         navigatorKey.currentContext != null ||
    //     !serviceEnabled) {
    //   navigate(
    //     navigatorKey.currentContext!,
    //     LocationEnableGuide.path,
    //     duplicate: false,
    //     arguments: neededPermission,
    //   );
    //   return false;
    // }
    return true;
  }

  setPlaceMarks() async {
    if (position == null) return;
    placemarks =
        await placemarkFromCoordinates(position!.latitude, position!.longitude);
    setCountryCode();
  }

  Future<Position?> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return null;
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
    setPlaceMarks();
    return position;
  }

  // bool checkWithinRadius(GeoRestriction geoRestriction) {
  //   if (position == null) return false;
  // double distance = Geolocator.distanceBetween(
  //   geoRestriction.latitude,
  //   geoRestriction.longitude,
  //   position!.latitude,
  //   position!.longitude,
  // );

  //   // Check if the distance is within the radius
  //   final isWithin = distance <= geoRestriction.radius;
  //   if (!isWithin) {
  //     showModalBottomSheet(
  //       isScrollControlled: true,
  //       context: navigatorKey.currentContext!,
  //       builder: (context) => LocationRestrictionBottomSheet(
  //         geoRestriction: geoRestriction,
  //       ),
  //     );
  //   }
  //   return isWithin;
  // }
}

class LocationRestrictionBottomSheet extends StatefulWidget {
  const LocationRestrictionBottomSheet({
    super.key,
    required this.geoRestriction,
  });
  final GeoRestriction geoRestriction;

  @override
  State<LocationRestrictionBottomSheet> createState() =>
      _LocationRestrictionBottomSheetState();
}

class _LocationRestrictionBottomSheetState
    extends State<LocationRestrictionBottomSheet> {
  GoogleMapController? mapController;

  double get zoomLevel {
    switch (widget.geoRestriction.radius) {
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
                      widget.geoRestriction.latitude,
                      widget.geoRestriction.longitude,
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
                        widget.geoRestriction.latitude,
                        widget.geoRestriction.longitude,
                      ),
                      radius: widget.geoRestriction
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
              widget.geoRestriction.message,
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

class LocationEnableGuide extends StatefulWidget {
  static const String path = "/location-enable-guide";

  const LocationEnableGuide(
      {super.key,
      required,
      this.allowedPermission = LocationPermission.whileInUse});

  final LocationPermission allowedPermission;

  @override
  _LocationEnableGuideState createState() => _LocationEnableGuideState();
}

class _LocationEnableGuideState extends State<LocationEnableGuide>
    with EventListenerMixin {
  bool serviceEnabled = true;
  @override
  void initState() {
    super.initState();
    allowedEvents = [EventType.resumed];
    listenForEvents((event) async {
      if (!allowedEvents.contains(event.eventType)) return;
      if (!mounted) return;
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled == false) {
        setState(() {});
        return;
      }
      currentPermission = await Geolocator.checkPermission();
      if (currentPermission != LocationPermission.always &&
          currentPermission != widget.allowedPermission) {
        return;
      }

      if (!mounted) return;
      if (!Navigator.canPop(context)) return;
      Navigator.pop(context, true);
    });
  }

  @override
  void dispose() {
    disposeEventListener();
    super.dispose();
  }

  LocationPermission? currentPermission;

  bool get requestPermissionVissible {
    if (Platform.isAndroid) {
      return ![LocationPermission.deniedForever].contains(currentPermission);
    } else {
      return ![LocationPermission.deniedForever, LocationPermission.whileInUse]
          .contains(currentPermission);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String message =
        "This app requires access to your location for attendance tracking. We use your location only to track check-ins/check-outs and ensure you are within the authorized area."
        "\n\nYou need to give ${widget.allowedPermission} permission to access your location to continue using the app.";

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SvgPicture.asset(
                Assets.svgs.locationMarker,
                height: 200,
              ),
              const SizedBox(height: 32),
              const Text(
                'Enable Location Services',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: paddingXL,
                ),
                child: LoadingButton(
                  onPressed: () {
                    Geolocator.openAppSettings();
                  },
                  buttonLoading: false,
                  text: 'Settings',
                ),
              ),
              Visibility(
                visible: requestPermissionVissible,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: paddingLarge,
                  ),
                  child: LoadingButton(
                    onPressed: () async {
                      if (!serviceEnabled) {
                        serviceEnabled =
                            await Geolocator.openLocationSettings();
                        return;
                      }
                      currentPermission = await Geolocator.requestPermission();
                      logInfo(currentPermission);
                      setState(() {});
                      if ([
                        LocationPermission.denied,
                        LocationPermission.deniedForever,
                      ].contains(currentPermission)) {
                        return;
                      }
                      if (currentPermission == LocationPermission.always ||
                          widget.allowedPermission == currentPermission) {
                        // ignore: use_build_context_synchronously
                        if (!Navigator.canPop(context)) return;
                        // ignore: use_build_context_synchronously
                        if (mounted) Navigator.pop(context, true);
                        return;
                      }
                      if (Platform.isIOS) return;
                      final result = await Permission.locationAlways.request();
                      if (result != PermissionStatus.granted) return;
                      // ignore: use_build_context_synchronously
                      if (!Navigator.canPop(context)) return;
                      if (!mounted) return;
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context, true);
                    },
                    buttonLoading: false,
                    text: 'Request Permission',
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
