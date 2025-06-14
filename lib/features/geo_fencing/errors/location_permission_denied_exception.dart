/// An exception that occurs when location permission are denied.
class LocationPermissionDeniedException implements Exception {
  LocationPermissionDeniedException(
      [this.message = 'Location permission are denied.']);

  final String message;

  @override
  String toString() => 'LocationPermissionDeniedException: $message';
}
