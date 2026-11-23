import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme.dart';
import '../../core/widgets/staggered_fade_in.dart';
import 'leaderboard_repository.dart';
import 'models/leaderboard_entry.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  List<LeaderboardEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final entries = await ref.read(leaderboardRepositoryProvider).weekly();
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFD4A017);
      case 2:
        return const Color(0xFF9AA3AD);
      case 3:
        return const Color(0xFFB4722A);
      default:
        return AppColors.inkSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('This week')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.accent,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return StaggeredFadeIn(
                    index: index,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: entry.isMe ? AppColors.accentTint : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: entry.isMe ? AppColors.accent : AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              '${entry.rank}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: _rankColor(entry.rank), fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.accentTint,
                            backgroundImage: entry.avatarUrl != null ? NetworkImage(entry.avatarUrl!) : null,
                            child: entry.avatarUrl == null
                                ? const HugeIcon(icon: HugeIcons.strokeRoundedUser, color: AppColors.accent, size: 18)
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.isMe ? '${entry.displayName} (you)' : entry.displayName,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '${entry.totalActivities} run${entry.totalActivities == 1 ? '' : 's'}',
                                  style: const TextStyle(color: AppColors.inkSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${entry.totalDistanceKm.toStringAsFixed(1)} km',
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
