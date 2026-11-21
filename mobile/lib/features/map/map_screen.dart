import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/location_service.dart';
import '../../core/theme.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../../models/nearby_runner.dart';
import '../../models/run_event.dart';
import '../connections/connection_repository.dart';
import '../profile/profile_repository.dart';
import '../runs/create_run_screen.dart';
import '../runs/run_detail_screen.dart';
import '../runs/run_repository.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _locationService = LocationService();

  LatLng? _myLocation;
  List<NearbyRunner> _runners = [];
  List<NearbyRunEvent> _runs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final position = await _locationService.currentPosition();
      final location = LatLng(position.latitude, position.longitude);

      await ref.read(profileRepositoryProvider).updateLocation(location.latitude, location.longitude);

      final runners = await ref
          .read(profileRepositoryProvider)
          .nearby(lat: location.latitude, lng: location.longitude);
      final runs = await ref.read(runRepositoryProvider).nearby(lat: location.latitude, lng: location.longitude);

      setState(() {
        _myLocation = location;
        _runners = runners;
        _runs = runs;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _connectWith(NearbyRunner runner) async {
    try {
      await ref.read(connectionRepositoryProvider).request(runner.userId);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Run request sent to ${runner.displayName}')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  void _showRunner(NearbyRunner runner) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.accentTint,
                  backgroundImage: runner.avatarUrl != null ? NetworkImage(runner.avatarUrl!) : null,
                  child: runner.avatarUrl == null
                      ? const HugeIcon(icon: HugeIcons.strokeRoundedUser, color: AppColors.accent)
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(runner.displayName, style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        '${runner.distanceKm.toStringAsFixed(1)} km away'
                        '${runner.paceMinPerKm != null ? " · ${runner.paceMinPerKm!.toStringAsFixed(1)} min/km" : ""}',
                        style: const TextStyle(color: AppColors.inkSecondary, fontSize: 13.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (runner.bio != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(runner.bio!, style: const TextStyle(color: AppColors.ink, height: 1.4)),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedUserAdd01, color: Colors.white, size: 20),
              label: const Text('Ask to run together'),
              onPressed: () {
                Navigator.of(context).pop();
                _connectWith(runner);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createRun() async {
    final location = _myLocation;
    if (location == null) return;
    final created = await Navigator.of(context).push<RunEvent?>(
      MaterialPageRoute(builder: (_) => CreateRunScreen(initialLocation: location)),
    );
    if (created != null) _load();
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    for (final runner in _runners) {
      markers.add(Marker(
        markerId: MarkerId('runner-${runner.userId}'),
        position: LatLng(runner.approxLatitude, runner.approxLongitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(title: runner.displayName),
        onTap: () => _showRunner(runner),
      ));
    }
    for (final run in _runs) {
      markers.add(Marker(
        markerId: MarkerId('run-${run.id}'),
        position: LatLng(run.startLatitude, run.startLongitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: InfoWindow(title: run.title, snippet: '${run.joinedCount}/${run.maxParticipants} joined'),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => RunDetailScreen(runId: run.id)));
        },
      ));
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }
    if (_error != null || _myLocation == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HugeIcon(icon: HugeIcons.strokeRoundedLocation01, color: AppColors.inkSecondary, size: 32),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Could not get your location\n$_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.inkSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _myLocation!, zoom: 14),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          markers: _buildMarkers(),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
            child: StaggeredFadeIn(index: 0, child: _SummaryPill(runnerCount: _runners.length, runCount: _runs.length)),
          ),
        ),
        Positioned(
          right: AppSpacing.md,
          bottom: AppSpacing.md,
          child: FloatingActionButton.extended(
            onPressed: _createRun,
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, color: Colors.white, size: 20),
            label: const Text('Plan a run'),
          ),
        ),
      ],
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final int runnerCount;
  final int runCount;

  const _SummaryPill({required this.runnerCount, required this.runCount});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          boxShadow: const [
            BoxShadow(color: Color(0x1A16181D), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HugeIcon(icon: HugeIcons.strokeRoundedUserGroup, color: AppColors.accent, size: 16),
            const SizedBox(width: 6),
            Text('$runnerCount nearby', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(width: AppSpacing.sm),
            Container(width: 1, height: 12, color: AppColors.divider),
            const SizedBox(width: AppSpacing.sm),
            const HugeIcon(icon: HugeIcons.strokeRoundedRunningShoes, color: AppColors.accent, size: 16),
            const SizedBox(width: 6),
            Text('$runCount runs', style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}
