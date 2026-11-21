import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/widgets/stat_block.dart';
import 'activity_repository.dart';
import 'models/activity.dart';

class ActivityDetailScreen extends ConsumerStatefulWidget {
  final String activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  ConsumerState<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> {
  Activity? _activity;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final activity = await ref.read(activityRepositoryProvider).get(widget.activityId);
      setState(() {
        _activity = activity;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  LatLngBounds _bounds(Activity activity) {
    var minLat = activity.route.first.lat, maxLat = activity.route.first.lat;
    var minLng = activity.route.first.lng, maxLng = activity.route.first.lng;
    for (final p in activity.route) {
      minLat = p.lat < minLat ? p.lat : minLat;
      maxLat = p.lat > maxLat ? p.lat : maxLat;
      minLng = p.lng < minLng ? p.lng : minLng;
      maxLng = p.lng > maxLng ? p.lng : maxLng;
    }
    return LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.accent)));
    }
    if (_error != null || _activity == null) {
      return Scaffold(body: Center(child: Text('Could not load run: $_error')));
    }

    final activity = _activity!;

    return Scaffold(
      appBar: AppBar(title: Text(formatDateTime(activity.startTime))),
      body: ListView(
        children: [
          SizedBox(
            height: 220,
            child: activity.route.length > 1
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(target: LatLng(activity.route.first.lat, activity.route.first.lng)),
                    onMapCreated: (controller) {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        controller.animateCamera(CameraUpdate.newLatLngBounds(_bounds(activity), 40));
                      });
                    },
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId('route'),
                        color: AppColors.accent,
                        width: 5,
                        points: activity.route.map((p) => LatLng(p.lat, p.lng)).toList(),
                      ),
                    },
                  )
                : const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatBlock(
                      icon: HugeIcons.strokeRoundedRoute01,
                      value: activity.distanceKm.toStringAsFixed(2),
                      unit: 'km',
                    ),
                    StatBlock(
                      icon: HugeIcons.strokeRoundedClock01,
                      value: formatElapsed(activity.durationSeconds),
                      unit: 'time',
                    ),
                    StatBlock(
                      icon: HugeIcons.strokeRoundedTimer01,
                      value: formatPaceValue(activity.averagePaceMinPerKm),
                      unit: 'min/km',
                    ),
                    if (activity.stepCount != null)
                      StatBlock(
                        icon: HugeIcons.strokeRoundedFootprints,
                        value: '${activity.stepCount}',
                        unit: 'steps',
                      ),
                  ],
                ),
                if (activity.splits.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text('Splits', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.sm),
                  ...activity.splits.map((split) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text('${split.splitNumber}', style: Theme.of(context).textTheme.bodyMedium),
                            ),
                            Expanded(
                              child: Text(
                                '${split.distanceKm.toStringAsFixed(2)} km',
                                style: const TextStyle(color: AppColors.inkSecondary),
                              ),
                            ),
                            Text(formatPaceValue(split.paceMinPerKm), style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(width: 4),
                            const Text('min/km', style: TextStyle(color: AppColors.inkSecondary, fontSize: 12)),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
