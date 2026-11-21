import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/widgets/illustration.dart';
import '../../core/widgets/staggered_fade_in.dart';
import 'activity_detail_screen.dart';
import 'activity_repository.dart';
import 'live_tracking_screen.dart';
import 'models/activity.dart';

class TrackScreen extends ConsumerStatefulWidget {
  const TrackScreen({super.key});

  @override
  ConsumerState<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends ConsumerState<TrackScreen> {
  List<ActivitySummary> _activities = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final activities = await ref.read(activityRepositoryProvider).mine();
    setState(() {
      _activities = activities;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.accent,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Material(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LiveTrackingScreen()));
                _load();
              },
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    const HugeIcon(icon: HugeIcons.strokeRoundedRunningShoes, color: Colors.white, size: 28),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start a run',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.white),
                          ),
                          const Text(
                            'Track your route, pace, and steps live',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Recent activities', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
            )
          else if (_activities.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Column(
                  children: [
                    const Illustration(IllustrationAsset.personRunning, size: 96),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No runs tracked yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.inkSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_activities.length, (index) {
              final activity = _activities[index];
              return StaggeredFadeIn(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ActivityDetailScreen(activityId: activity.id)),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.accentTint,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedRoute01,
                                  color: AppColors.accent,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${activity.distanceKm.toStringAsFixed(2)} km',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    '${formatDateTime(activity.startTime)} · ${formatElapsed(activity.durationSeconds)}',
                                    style: const TextStyle(color: AppColors.inkSecondary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowRight01,
                              color: AppColors.inkSecondary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
