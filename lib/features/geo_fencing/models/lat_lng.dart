class LatLng {
  const LatLng(this.latitude, this.longitude);

  final double latitude;

  final double longitude;

  factory LatLng.fromJson(Map<String, dynamic> json) =>
      LatLng(json['latitude'], json['longitude']);

  Map<String, dynamic> toJson() =>
      {'latitude': latitude, 'longitude': longitude};

  @override
  bool operator ==(Object other) =>
      other is LatLng &&
      runtimeType == other.runtimeType &&
      latitude == other.latitude &&
      longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
