import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/widgets/staggered_fade_in.dart';
import '../../models/run_event.dart';
import 'run_detail_screen.dart';
import 'run_repository.dart';

class MyRunsScreen extends ConsumerStatefulWidget {
  const MyRunsScreen({super.key});

  @override
  ConsumerState<MyRunsScreen> createState() => _MyRunsScreenState();
}

class _MyRunsScreenState extends ConsumerState<MyRunsScreen> {
  List<RunEvent> _runs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final runs = await ref.read(runRepositoryProvider).mine();
    setState(() {
      _runs = runs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    if (_runs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HugeIcon(icon: HugeIcons.strokeRoundedRunningShoes, color: AppColors.inkSecondary, size: 32),
              const SizedBox(height: AppSpacing.md),
              Text(
                "You haven't hosted any runs yet",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.inkSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.accent,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _runs.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final run = _runs[index];
          return StaggeredFadeIn(
            index: index,
            child: _RunRow(
              run: run,
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => RunDetailScreen(runId: run.id)));
                _load();
              },
            ),
          );
        },
      ),
    );
  }
}

class _RunRow extends StatelessWidget {
  final RunEvent run;
  final VoidCallback onTap;

  const _RunRow({required this.run, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
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
                decoration: BoxDecoration(color: AppColors.accentTint, borderRadius: BorderRadius.circular(12)),
                child: const Center(
                  child: HugeIcon(icon: HugeIcons.strokeRoundedRunningShoes, color: AppColors.accent, size: 20),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(run.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${formatDateTime(run.startTime)} · ${run.joinedCount}/${run.maxParticipants} joined',
                      style: const TextStyle(color: AppColors.inkSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: AppColors.inkSecondary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
