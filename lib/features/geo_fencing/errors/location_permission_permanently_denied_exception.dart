/// An exception that occurs when location permission are permanently denied.
class LocationPermissionPermanentlyDeniedException implements Exception {
  LocationPermissionPermanentlyDeniedException(
      [this.message = 'Location permission are permanently denied.']);

  final String message;

  @override
  String toString() => 'LocationPermissionPermanentlyDeniedException: $message';
}
