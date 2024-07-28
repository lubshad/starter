import 'package:country_code_picker/country_code_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._private() {
    init();
  }

  CountryCode countryCode = CountryCode.fromCountryCode("IN");

  static LocationService? _instance;

  static LocationService get i {
    _instance ??= LocationService._private();
    return _instance!;
  }

  Future<void> getCountryCode() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition();

    // Get the address from the coordinates
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);


    if (placemarks.isNotEmpty) {
      countryCode =
          CountryCode.fromCountryCode(placemarks.first.isoCountryCode ?? "IN");
    }
  }

  bool initialized = false;

  void init() {
    if (initialized) return;
    getCountryCode();
    initialized = true;
  }
}
