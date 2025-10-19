import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_picker_google/place_picker_google.dart';
import 'package:starter/core/app_config.dart';

import '../../../core/app_route.dart';
import '../../../exporter.dart';
import '../../../main.dart';
import '../../../mixins/event_listener.dart';
import '../../../widgets/custom_appbar.dart';
import '../../location_tracking/location_service.dart';
import '../../notification/notification_listing_screen.dart';
import '../../profile_screen/common_controller.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(
        ScreenUtil().screenWidth,
        ScreenUtil().screenWidth * .3,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: middlePadding,
        ).copyWith(top: paddingXXL, bottom: 0),
        child: Row(
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              height: 48.h,
              width: 48.h,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xffF0F3F8)),
                shape: BoxShape.circle,
              ),
              child: InkWell(
                customBorder: OvalBorder(),
                onTap: changeLocation,
                child: Center(
                  child: SvgPicture.asset(
                    Assets.svgs.locationPinHome,
                    width: 24.h,
                    height: 24.h,
                  ),
                ),
              ),
            ),
            gap,
            Expanded(
              child: AnimatedBuilder(
                animation: LocationService.i,
                builder: (context, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        [null, ""].contains(
                              LocationService.i.placemarks.firstOrNull?.name,
                            )
                            ? "Unknown".tr
                            : LocationService.i.placemarks.first.name!,
                        style: context.kanit30013.copyWith(
                          color: Color(0xff9996B5),
                        ),
                      ),
                      Text(
                        [null, ""].contains(
                              LocationService
                                  .i
                                  .placemarks
                                  .firstOrNull
                                  ?.locality,
                            )
                            ? "Unknown".tr
                            : LocationService.i.placemarks.first.locality!,
                        style: context.kanit30016.copyWith(
                          color: Color(0xff15203E),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Stack(
              children: [
                IconButton(
                  onPressed: () async {
                    await navigate(context, NotificationListingScreen.path);
                    CommonController.i.fetchProfileDetails();
                  },
                  icon: Icon(Icons.notifications, color: Color(0xff3C3F4E)),
                ),
                NotificationIndication(),
              ],
            ),
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(Icons.menu),
            ),
          ],
        ),
      ),
    );
  }

  void changeLocation() async {
    final result = await Navigator.push<LocationResult>(
      navigatorKey.currentContext!,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: CustomAppBar(title: "Location".tr),
              body: PlacePicker(
                myLocationFABConfig: MyLocationFABConfig(
                  bottom: padding,
                  left: padding,
                  right: ScreenUtil().screenWidth - 60.h,
                  mini: true,
                ),

                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                localizationConfig: LocalizationConfig(
                  languageCode: Get.locale?.languageCode ?? "en",
                  findingPlace: "Finding Place".tr,
                  noResultsFound: "No Result Found".tr,
                  unnamedLocation: "Unnamed Location".tr,
                  selectActionLocation: "Confirm Location".tr,
                  nearBy: "Near By Places".tr,
                ),

                initialLocation:
                    LocationService.i.position == null
                        ? null
                        : LatLng(
                          LocationService.i.position!.latitude,
                          LocationService.i.position!.longitude,
                        ),

                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                searchInputConfig: SearchInputConfig(
                  padding: EdgeInsets.symmetric(
                    horizontal: paddingLarge,
                    vertical: paddingLarge,
                  ),
                ),

                apiKey: appConfig.googleMapsApiKey,
                onPlacePicked: (place) {
                  Navigator.pop(context, place);
                },
              ),
            ),
      ),
    );
    if (result == null) return;
    LocationService.i.position = Position(
      longitude: result.latLng?.longitude ?? 0,
      latitude: result.latLng?.latitude ?? 0,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 1,
      altitudeAccuracy: 1,
      heading: 1,
      headingAccuracy: 1,
      speed: 1,
      speedAccuracy: 1,
    );
    LocationService.i.placemarks = [
      Placemark(
        name: result.name,
        locality: result.locality?.shortName,
        subLocality: result.formattedAddress,
      ),
    ];
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    LocationService.i.notifyListeners();
    EventListener.i.sendEvent(Event(eventType: EventType.locationUpdate));
  }
}

class NotificationIndication extends StatelessWidget {
  const NotificationIndication({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: padding,
      top: padding,
      child: AnimatedBuilder(
        animation: CommonController.i,
        builder: (context, child) {
          return AnimatedContainer(
            width: 8.h,
            height: 8.h,
            decoration: BoxDecoration(
              // color:
              //     CommonController.i.profileDetails?.notification == true
              //         ? Color(0xffFF3B30)
              //         : Colors.transparent,
              shape: BoxShape.circle,
            ),
            duration: animationDuration,
          );
        },
      ),
    );
  }
}
