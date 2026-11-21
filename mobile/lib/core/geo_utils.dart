import 'dart:math';

const _earthRadiusKm = 6371.0;

/// Mirrors the backend's GeoUtils.distanceKm, used here for live distance
/// accumulation while tracking a run.
double distanceKm(double lat1, double lng1, double lat2, double lng2) {
  final dLat = _toRadians(lat2 - lat1);
  final dLng = _toRadians(lng2 - lng1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLng / 2) * sin(dLng / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return _earthRadiusKm * c;
}

double _toRadians(double degrees) => degrees * pi / 180;
