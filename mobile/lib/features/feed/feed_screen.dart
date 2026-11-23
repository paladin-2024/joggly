import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/widgets/illustration.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../tracking/activity_detail_screen.dart';
import '../tracking/activity_repository.dart';
import 'feed_repository.dart';
import 'models/feed_item.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  List<FeedItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await ref.read(feedRepositoryProvider).feed();
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _toggleKudos(FeedItem item, int index) async {
    try {
      final activity = await ref.read(activityRepositoryProvider).toggleKudos(item.activityId);
      setState(() {
        _items[index] = FeedItem(
          activityId: item.activityId,
          ownerId: item.ownerId,
          ownerDisplayName: item.ownerDisplayName,
          ownerAvatarUrl: item.ownerAvatarUrl,
          startTime: item.startTime,
          durationSeconds: item.durationSeconds,
          distanceKm: item.distanceKm,
          averagePaceMinPerKm: item.averagePaceMinPerKm,
          stepCount: item.stepCount,
          kudosCount: activity.kudosCount,
          kudosGivenByMe: activity.kudosGivenByMe,
          commentCount: item.commentCount,
        );
      });
    } catch (_) {
      // best-effort
    }
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
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppColors.accentTint, borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                        child: HugeIcon(icon: HugeIcons.strokeRoundedTrophy, color: AppColors.accent, size: 20),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('This week\'s leaderboard', style: Theme.of(context).textTheme.titleMedium),
                          const Text('See how you stack up', style: TextStyle(color: AppColors.inkSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                    const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: AppColors.inkSecondary, size: 18),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
            )
          else if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const Illustration(IllustrationAsset.peopleHugging, size: 96),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Connect with runners to see their runs here',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.inkSecondary),
                  ),
                ],
              ),
            )
          else
            ...List.generate(_items.length, (index) {
              final item = _items[index];
              return StaggeredFadeIn(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _FeedCard(
                    item: item,
                    onTap: () async {
                      await Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => ActivityDetailScreen(activityId: item.activityId)));
                      _load();
                    },
                    onKudos: () => _toggleKudos(item, index),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback onTap;
  final VoidCallback onKudos;

  const _FeedCard({required this.item, required this.onTap, required this.onKudos});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.accentTint,
                    backgroundImage: item.ownerAvatarUrl != null ? NetworkImage(item.ownerAvatarUrl!) : null,
                    child: item.ownerAvatarUrl == null
                        ? const HugeIcon(icon: HugeIcons.strokeRoundedUser, color: AppColors.accent, size: 18)
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.ownerDisplayName, style: Theme.of(context).textTheme.titleMedium),
                        Text(formatDateTime(item.startTime), style: const TextStyle(color: AppColors.inkSecondary, fontSize: 12.5)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _MiniStat(value: item.distanceKm.toStringAsFixed(2), unit: 'km'),
                  _MiniStat(value: formatElapsed(item.durationSeconds), unit: 'time'),
                  _MiniStat(value: formatPace(distanceKm: item.distanceKm, durationSeconds: item.durationSeconds), unit: 'min/km'),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  InkWell(
                    onTap: onKudos,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: item.kudosGivenByMe ? HugeIcons.strokeRoundedFavourite : HugeIcons.strokeRoundedThumbsUp,
                            color: item.kudosGivenByMe ? AppColors.danger : AppColors.inkSecondary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text('${item.kudosCount}', style: const TextStyle(color: AppColors.inkSecondary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  const HugeIcon(icon: HugeIcons.strokeRoundedMessage01, color: AppColors.inkSecondary, size: 18),
                  const SizedBox(width: 6),
                  Text('${item.commentCount}', style: const TextStyle(color: AppColors.inkSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String unit;

  const _MiniStat({required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          Text(unit, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
