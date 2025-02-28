/// An exception that occurs when the geofencing service has already started.
class GeofencingAlreadyStartedException implements Exception {
  GeofencingAlreadyStartedException(
      [this.message = 'The geofencing service has already started.']);

  final String message;

  @override
  String toString() => 'GeofencingAlreadyStartedException: $message';
}
