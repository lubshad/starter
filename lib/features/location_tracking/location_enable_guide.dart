import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';

import '../../exporter.dart';
import '../../mixins/event_listener.dart';
import '../../widgets/loading_button.dart';

class LocationEnableGuide extends StatefulWidget {
  static const String path = "/location-enable-guide";

  const LocationEnableGuide(
      {super.key,
      required,
      this.allowedPermission = LocationPermission.whileInUse});

  final LocationPermission allowedPermission;

  @override
  LocationEnableGuideState createState() => LocationEnableGuideState();
}

class LocationEnableGuideState extends State<LocationEnableGuide>
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
      if (!serviceEnabled) {
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SvgPicture.asset(
                    Assets.svgs.locationMarker,
                    height: 200,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Enable Location Services',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: paddingXL,
                    ),
                    child: LoadingButton(
                      onPressed: () async {
                        await Geolocator.openAppSettings();
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
                            await Geolocator.openLocationSettings();
                            return;
                          }
                          currentPermission =
                              await Geolocator.requestPermission();
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
        ),
      ),
    );
  }
}
