import 'package:geolocator/geolocator.dart';

class LocationUnavailableException implements Exception {
  final String message;
  LocationUnavailableException(this.message);

  @override
  String toString() => message;
}

class LocationService {
  Future<void> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationUnavailableException('Location services are turned off.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw LocationUnavailableException('Location permission was denied.');
    }
  }

  Future<Position> currentPosition() async {
    await _ensurePermission();
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// Continuous GPS updates for live run tracking. Caller must have already
  /// succeeded once via [currentPosition] or call this inside a try/catch.
  Stream<Position> positionStream() async* {
    await _ensurePermission();
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 5),
    );
  }
}
