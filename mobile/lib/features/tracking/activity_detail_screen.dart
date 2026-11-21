import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/widgets/stat_block.dart';
import 'activity_repository.dart';
import 'models/activity.dart';
import 'models/comment.dart';

class ActivityDetailScreen extends ConsumerStatefulWidget {
  final String activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  ConsumerState<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> {
  Activity? _activity;
  List<Comment> _comments = [];
  bool _loading = true;
  bool _kudosInFlight = false;
  bool _postingComment = false;
  String? _error;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(activityRepositoryProvider);
      final results = await Future.wait([repo.get(widget.activityId), repo.comments(widget.activityId)]);
      setState(() {
        _activity = results[0] as Activity;
        _comments = results[1] as List<Comment>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _toggleKudos() async {
    if (_kudosInFlight) return;
    setState(() => _kudosInFlight = true);
    try {
      final activity = await ref.read(activityRepositoryProvider).toggleKudos(widget.activityId);
      setState(() => _activity = activity);
    } catch (_) {
      // best-effort; leave the UI as-is on failure
    } finally {
      if (mounted) setState(() => _kudosInFlight = false);
    }
  }

  Future<void> _postComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty || _postingComment) return;
    setState(() => _postingComment = true);
    try {
      final comment = await ref.read(activityRepositoryProvider).addComment(widget.activityId, body);
      setState(() {
        _comments = [..._comments, comment];
        _commentController.clear();
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _postingComment = false);
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.accentTint,
                        backgroundImage:
                            activity.ownerAvatarUrl != null ? NetworkImage(activity.ownerAvatarUrl!) : null,
                        child: activity.ownerAvatarUrl == null
                            ? const HugeIcon(icon: HugeIcons.strokeRoundedUser, color: AppColors.accent, size: 18)
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(activity.ownerDisplayName, style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: activity.route.length > 1
                      ? GoogleMap(
                          initialCameraPosition:
                              CameraPosition(target: LatLng(activity.route.first.lat, activity.route.first.lng)),
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
                      const SizedBox(height: AppSpacing.lg),
                      const Divider(),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          _KudosButton(
                            given: activity.kudosGivenByMe,
                            count: activity.kudosCount,
                            loading: _kudosInFlight,
                            onTap: _toggleKudos,
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          HugeIcon(icon: HugeIcons.strokeRoundedMessage01, color: AppColors.inkSecondary, size: 18),
                          const SizedBox(width: 6),
                          Text('${_comments.length}', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      if (_comments.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        ..._comments.map((c) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppColors.accentTint,
                                    backgroundImage:
                                        c.authorAvatarUrl != null ? NetworkImage(c.authorAvatarUrl!) : null,
                                    child: c.authorAvatarUrl == null
                                        ? const HugeIcon(
                                            icon: HugeIcons.strokeRoundedUser, color: AppColors.accent, size: 14)
                                        : null,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c.authorDisplayName, style: Theme.of(context).textTheme.labelMedium),
                                        Text(c.body, style: Theme.of(context).textTheme.bodyMedium),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(hintText: 'Add a comment…'),
                      onSubmitted: (_) => _postComment(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _postingComment
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : IconButton(
                          onPressed: _postComment,
                          icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: AppColors.accent),
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

class _KudosButton extends StatelessWidget {
  final bool given;
  final int count;
  final bool loading;
  final VoidCallback onTap;

  const _KudosButton({required this.given, required this.count, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = given ? AppColors.danger : AppColors.inkSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: loading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: given ? 1.15 : 1.0,
                duration: AppMotion.fast,
                curve: AppMotion.curve,
                child: HugeIcon(
                  icon: given ? HugeIcons.strokeRoundedFavourite : HugeIcons.strokeRoundedThumbsUp,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 6),
              Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
