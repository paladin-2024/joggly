import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme.dart';
import '../../core/widgets/staggered_fade_in.dart';
import 'connection_models.dart';
import 'connection_repository.dart';

class ConnectionsScreen extends ConsumerStatefulWidget {
  final String currentUserId;

  const ConnectionsScreen({super.key, required this.currentUserId});

  @override
  ConsumerState<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends ConsumerState<ConnectionsScreen> {
  List<Connection> _connections = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final connections = await ref.read(connectionRepositoryProvider).list();
    setState(() {
      _connections = connections;
      _loading = false;
    });
  }

  Future<void> _respond(Connection connection, bool accept) async {
    final repo = ref.read(connectionRepositoryProvider);
    accept ? await repo.accept(connection.id) : await repo.decline(connection.id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    if (_connections.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HugeIcon(icon: HugeIcons.strokeRoundedUserGroup, color: AppColors.inkSecondary, size: 32),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No running buddies yet — meet people on the map',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.inkSecondary),
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
        itemCount: _connections.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final c = _connections[index];
          final isIncoming = c.recipientId == widget.currentUserId;
          final otherName = isIncoming ? c.requesterDisplayName : c.recipientDisplayName;
          final canRespond = isIncoming && c.status == 'PENDING';

          return StaggeredFadeIn(
            index: index,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.accentTint,
                    child: HugeIcon(icon: HugeIcons.strokeRoundedUser, color: AppColors.accent, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(otherName, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        _StatusPill(status: c.status),
                      ],
                    ),
                  ),
                  if (canRespond) ...[
                    _RoundIconButton(
                      icon: HugeIcons.strokeRoundedTick02,
                      color: AppColors.success,
                      background: AppColors.successTint,
                      onTap: () => _respond(c, true),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _RoundIconButton(
                      icon: HugeIcons.strokeRoundedCancel01,
                      color: AppColors.danger,
                      background: AppColors.dangerTint,
                      onTap: () => _respond(c, false),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, tint) = switch (status) {
      'ACCEPTED' => ('Running together', AppColors.success, AppColors.successTint),
      'DECLINED' => ('Declined', AppColors.danger, AppColors.dangerTint),
      _ => ('Pending', AppColors.inkSecondary, AppColors.ground),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final List<List<dynamic>> icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: HugeIcon(icon: icon, color: color, size: 18),
        ),
      ),
    );
  }
}
