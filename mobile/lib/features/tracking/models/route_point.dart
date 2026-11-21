class RoutePoint {
  final double lat;
  final double lng;
  final double elapsedSeconds;

  RoutePoint({required this.lat, required this.lng, required this.elapsedSeconds});

  factory RoutePoint.fromJson(Map<String, dynamic> json) => RoutePoint(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        elapsedSeconds: (json['elapsedSeconds'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng, 'elapsedSeconds': elapsedSeconds};
}
