import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../core/widgets/stat_block.dart';
import '../../models/run_event.dart';
import 'run_repository.dart';

class RunDetailScreen extends ConsumerStatefulWidget {
  final String runId;

  const RunDetailScreen({super.key, required this.runId});

  @override
  ConsumerState<RunDetailScreen> createState() => _RunDetailScreenState();
}

class _RunDetailScreenState extends ConsumerState<RunDetailScreen> {
  RunEvent? _run;
  bool _loading = true;
  bool _actionInFlight = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final run = await ref.read(runRepositoryProvider).get(widget.runId);
      setState(() {
        _run = run;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleJoin() async {
    final run = _run;
    if (run == null) return;
    setState(() => _actionInFlight = true);
    try {
      final updated = run.currentUserJoined
          ? await ref.read(runRepositoryProvider).leave(run.id)
          : await ref.read(runRepositoryProvider).join(run.id);
      setState(() => _run = updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _actionInFlight = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.accent)));
    }
    if (_error != null || _run == null) {
      return Scaffold(body: Center(child: Text('Could not load run: $_error')));
    }

    final run = _run!;
    final full = run.joinedCount >= run.maxParticipants;

    return Scaffold(
      appBar: AppBar(title: Text(run.title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.accentTint,
                child: HugeIcon(icon: HugeIcons.strokeRoundedUser, color: AppColors.accent, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hosted by ${run.hostDisplayName}', style: Theme.of(context).textTheme.titleMedium),
                    Row(
                      children: [
                        const HugeIcon(icon: HugeIcons.strokeRoundedCalendar02, color: AppColors.inkSecondary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          formatDateTime(run.startTime),
                          style: const TextStyle(color: AppColors.inkSecondary, fontSize: 13.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (run.startAddress != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const HugeIcon(icon: HugeIcons.strokeRoundedMapPin, color: AppColors.inkSecondary, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(run.startAddress!, style: const TextStyle(color: AppColors.inkSecondary, fontSize: 13.5)),
                ),
              ],
            ),
          ],
          if (run.description != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(run.description!, style: const TextStyle(height: 1.5)),
          ],
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                if (run.distanceKm != null)
                  StatBlock(
                    icon: HugeIcons.strokeRoundedRoute01,
                    value: '${run.distanceKm}',
                    unit: 'km',
                  ),
                if (run.paceMinPerKm != null)
                  StatBlock(
                    icon: HugeIcons.strokeRoundedTimer01,
                    value: '${run.paceMinPerKm}',
                    unit: 'min/km',
                  ),
                StatBlock(
                  icon: HugeIcons.strokeRoundedUserGroup,
                  value: '${run.joinedCount}',
                  unit: 'of ${run.maxParticipants} joined',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedSwitcher(
            duration: AppMotion.standard,
            switchInCurve: AppMotion.curve,
            switchOutCurve: AppMotion.curve,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child)),
            child: run.currentUserJoined
                ? OutlinedButton.icon(
                    key: const ValueKey('leave'),
                    onPressed: _actionInFlight ? null : _toggleJoin,
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedTick02, color: AppColors.success, size: 18),
                    label: _actionInFlight
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("You're in · tap to leave"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.success),
                    ),
                  )
                : FilledButton(
                    key: const ValueKey('join'),
                    onPressed: (_actionInFlight || full) ? null : _toggleJoin,
                    child: _actionInFlight
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(full ? 'Run is full' : 'Join run'),
                  ),
          ),
        ],
      ),
    );
  }
}
