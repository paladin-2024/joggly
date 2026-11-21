import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/format.dart';
import '../../core/geo_utils.dart' as geo;
import '../../core/location_service.dart';
import '../../core/theme.dart';
import 'models/route_point.dart';
import 'pending_activity_screen.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final _locationService = LocationService();

  StreamSubscription<Position>? _positionSub;
  StreamSubscription<StepCount>? _stepSub;
  Timer? _ticker;

  bool _tracking = false;
  bool _starting = false;
  String? _error;

  DateTime? _startTime;
  final List<RoutePoint> _route = [];
  double _distanceKm = 0;
  int _elapsedSeconds = 0;
  int? _stepCount;
  int? _baselineSteps;
  LatLng? _lastLatLng;

  @override
  void dispose() {
    _positionSub?.cancel();
    _stepSub?.cancel();
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      final position = await _locationService.currentPosition();
      await Permission.activityRecognition.request();

      setState(() {
        _tracking = true;
        _starting = false;
        _startTime = DateTime.now();
        _route.clear();
        _distanceKm = 0;
        _elapsedSeconds = 0;
        _stepCount = null;
        _baselineSteps = null;
        _lastLatLng = LatLng(position.latitude, position.longitude);
        _route.add(RoutePoint(lat: position.latitude, lng: position.longitude, elapsedSeconds: 0));
      });

      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_startTime != null) {
          setState(() => _elapsedSeconds = DateTime.now().difference(_startTime!).inSeconds);
        }
      });

      _positionSub = _locationService.positionStream().listen(_onPosition, onError: (_) {});

      _stepSub = Pedometer.stepCountStream.listen(_onStepCount, onError: (_) {});
    } catch (e) {
      setState(() {
        _starting = false;
        _error = '$e';
      });
    }
  }

  void _onPosition(Position position) {
    final current = LatLng(position.latitude, position.longitude);
    final previous = _lastLatLng;
    if (previous != null) {
      _distanceKm += geo.distanceKm(previous.latitude, previous.longitude, current.latitude, current.longitude);
    }
    setState(() {
      _lastLatLng = current;
      _route.add(RoutePoint(
        lat: current.latitude,
        lng: current.longitude,
        elapsedSeconds: _startTime == null ? 0 : DateTime.now().difference(_startTime!).inSeconds.toDouble(),
      ));
    });
  }

  void _onStepCount(StepCount event) {
    _baselineSteps ??= event.steps;
    setState(() => _stepCount = event.steps - _baselineSteps!);
  }

  Future<void> _stop() async {
    _positionSub?.cancel();
    _stepSub?.cancel();
    _ticker?.cancel();

    final startTime = _startTime;
    if (startTime == null || _route.length < 2) {
      setState(() => _tracking = false);
      return;
    }

    final route = List<RoutePoint>.of(_route);
    final distanceKm = _distanceKm;
    final elapsedSeconds = _elapsedSeconds;
    final stepCount = _stepCount;

    setState(() => _tracking = false);

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PendingActivityScreen(
          startTime: startTime,
          durationSeconds: elapsedSeconds,
          distanceKm: distanceKm,
          stepCount: stepCount,
          route: route,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _lastLatLng ?? const LatLng(0, 0),
              zoom: 16,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            polylines: {
              if (_route.length > 1)
                Polyline(
                  polylineId: const PolylineId('live-route'),
                  color: AppColors.accent,
                  width: 5,
                  points: _route.map((p) => LatLng(p.lat, p.lng)).toList(),
                ),
            },
          ),
          if (!_tracking)
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.lg,
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.dangerTint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                        ),
                      ),
                    FilledButton.icon(
                      onPressed: _starting ? null : _start,
                      icon: _starting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const HugeIcon(icon: HugeIcons.strokeRoundedRunningShoes, color: Colors.white, size: 20),
                      label: const Text('Start run'),
                    ),
                  ],
                ),
              ),
            ),
          if (_tracking)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(color: Color(0x1A16181D), blurRadius: 16, offset: Offset(0, 6)),
                    ],
                  ),
                  child: Row(
                    children: [
                      _LiveStat(label: 'TIME', value: formatElapsed(_elapsedSeconds)),
                      _LiveStat(label: 'KM', value: _distanceKm.toStringAsFixed(2)),
                      _LiveStat(
                        label: 'PACE',
                        value: formatPace(distanceKm: _distanceKm, durationSeconds: _elapsedSeconds),
                      ),
                      if (_stepCount != null) _LiveStat(label: 'STEPS', value: '$_stepCount'),
                    ],
                  ),
                ),
              ),
            ),
          if (_tracking)
            Positioned(
              bottom: AppSpacing.lg,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Center(
                  child: Material(
                    color: AppColors.danger,
                    shape: const CircleBorder(),
                    elevation: 4,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _stop,
                      child: const Padding(
                        padding: EdgeInsets.all(22),
                        child: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LiveStat extends StatelessWidget {
  final String label;
  final String value;

  const _LiveStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.4),
          ),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
