/// An exception that occurs when the device location settings are turned off.
class LocationServicesDisabledException implements Exception {
  LocationServicesDisabledException(
      [this.message = 'Location services are disabled.']);

  final String message;

  @override
  String toString() => 'LocationServicesDisabledException: $message';
}
