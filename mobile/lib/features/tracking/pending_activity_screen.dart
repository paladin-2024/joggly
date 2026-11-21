import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/widgets/illustration.dart';
import '../../core/widgets/stat_block.dart';
import 'activity_detail_screen.dart';
import 'activity_repository.dart';
import 'models/route_point.dart';

/// Shown right after stopping a live run: lets the user confirm (Save) or
/// throw away (Discard) the recording before it's ever sent to the backend.
class PendingActivityScreen extends ConsumerStatefulWidget {
  final DateTime startTime;
  final int durationSeconds;
  final double distanceKm;
  final int? stepCount;
  final List<RoutePoint> route;

  const PendingActivityScreen({
    super.key,
    required this.startTime,
    required this.durationSeconds,
    required this.distanceKm,
    this.stepCount,
    required this.route,
  });

  @override
  ConsumerState<PendingActivityScreen> createState() => _PendingActivityScreenState();
}

class _PendingActivityScreenState extends ConsumerState<PendingActivityScreen> {
  bool _saving = false;

  LatLngBounds _bounds() {
    var minLat = widget.route.first.lat, maxLat = widget.route.first.lat;
    var minLng = widget.route.first.lng, maxLng = widget.route.first.lng;
    for (final p in widget.route) {
      minLat = p.lat < minLat ? p.lat : minLat;
      maxLat = p.lat > maxLat ? p.lat : maxLat;
      minLng = p.lng < minLng ? p.lng : minLng;
      maxLng = p.lng > maxLng ? p.lng : maxLng;
    }
    return LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
  }

  Future<void> _discard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard this run?'),
        content: const Text("It won't be saved to your history."),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Keep it')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) Navigator.of(context).pop();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final activity = await ref.read(activityRepositoryProvider).create(
            startTime: widget.startTime,
            durationSeconds: widget.durationSeconds,
            distanceKm: widget.distanceKm,
            stepCount: widget.stepCount,
            route: widget.route,
          );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ActivityDetailScreen(activityId: activity.id)),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save run: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Run complete')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.accentTint,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                const Illustration(IllustrationAsset.partyPopper, size: 40),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Nice run! Save it to keep it in your history.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(widget.route.first.lat, widget.route.first.lng)),
              onMapCreated: (controller) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  controller.animateCamera(CameraUpdate.newLatLngBounds(_bounds(), 48));
                });
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  color: AppColors.accent,
                  width: 5,
                  points: widget.route.map((p) => LatLng(p.lat, p.lng)).toList(),
                ),
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      StatBlock(
                        icon: HugeIcons.strokeRoundedRoute01,
                        value: widget.distanceKm.toStringAsFixed(2),
                        unit: 'km',
                      ),
                      StatBlock(icon: HugeIcons.strokeRoundedClock01, value: formatElapsed(widget.durationSeconds), unit: 'time'),
                      StatBlock(
                        icon: HugeIcons.strokeRoundedTimer01,
                        value: formatPace(distanceKm: widget.distanceKm, durationSeconds: widget.durationSeconds),
                        unit: 'min/km',
                      ),
                      if (widget.stepCount != null)
                        StatBlock(icon: HugeIcons.strokeRoundedFootprints, value: '${widget.stepCount}', unit: 'steps'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving ? null : _discard,
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                          child: const Text('Discard'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FilledButton(
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Save run'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
