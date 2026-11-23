import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme.dart';
import '../../core/widgets/stat_block.dart';
import '../../models/profile.dart';
import '../auth/auth_controller.dart';
import '../runs/my_runs_screen.dart';
import '../tracking/activity_repository.dart';
import '../tracking/models/achievement.dart';
import '../tracking/models/calendar_day.dart';
import '../tracking/models/profile_stats.dart';
import '../tracking/widgets/contribution_calendar.dart';
import 'profile_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _bioController = TextEditingController();
  final _paceController = TextEditingController();
  final _distanceController = TextEditingController();
  bool _discoverable = true;
  Profile? _profile;
  ProfileStats? _stats;
  ActivityCalendar? _calendar;
  List<Achievement> _achievements = [];
  bool _loading = true;
  bool _saving = false;
  bool _editingProfile = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final activityRepo = ref.read(activityRepositoryProvider);
    final results = await Future.wait([
      ref.read(profileRepositoryProvider).me(),
      activityRepo.stats(),
      activityRepo.calendar(weeks: 12),
      activityRepo.achievements(),
    ]);
    final profile = results[0] as Profile;
    setState(() {
      _profile = profile;
      _stats = results[1] as ProfileStats;
      _calendar = results[2] as ActivityCalendar;
      _achievements = results[3] as List<Achievement>;
      _bioController.text = profile.bio ?? '';
      _paceController.text = profile.paceMinPerKm?.toString() ?? '';
      _distanceController.text = profile.preferredDistanceKm?.toString() ?? '';
      _discoverable = profile.discoverable;
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).updateProfile(
            bio: _bioController.text.trim(),
            paceMinPerKm: double.tryParse(_paceController.text),
            preferredDistanceKm: double.tryParse(_distanceController.text),
            discoverable: _discoverable,
          );
      if (mounted) {
        setState(() => _editingProfile = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _profile == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    final profile = _profile!;
    final stats = _stats!;
    final calendar = _calendar!;

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.accent,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.xl),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white,
                  backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
                  child: profile.avatarUrl == null
                      ? const HugeIcon(icon: HugeIcons.strokeRoundedUser, color: AppColors.accent, size: 40)
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  profile.displayName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(profile.bio!, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -28),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [BoxShadow(color: Color(0x1A16181D), blurRadius: 16, offset: Offset(0, 6))],
                ),
                child: Row(
                  children: [
                    StatBlock(
                      icon: HugeIcons.strokeRoundedRunningShoes,
                      value: '${stats.totalActivities}',
                      unit: 'runs',
                    ),
                    StatBlock(
                      icon: HugeIcons.strokeRoundedRoute01,
                      value: stats.totalDistanceKm.toStringAsFixed(1),
                      unit: 'total km',
                    ),
                    StatBlock(
                      icon: HugeIcons.strokeRoundedFire,
                      value: '${calendar.currentStreakDays}',
                      unit: 'day streak',
                      color: AppColors.flame,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Activity', style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      'Longest streak: ${calendar.longestStreakDays}d',
                      style: const TextStyle(color: AppColors.inkSecondary, fontSize: 12.5),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ContributionCalendar(days: calendar.days),
                const SizedBox(height: AppSpacing.lg),
                Text('Achievements', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  children: _achievements.map((a) => _AchievementTile(achievement: a)).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionLink(
                  icon: HugeIcons.strokeRoundedCalendar02,
                  label: 'Runs I\'m hosting',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyRunsScreen())),
                ),
                const SizedBox(height: AppSpacing.sm),
                _SectionLink(
                  icon: HugeIcons.strokeRoundedEdit02,
                  label: 'Edit profile',
                  onTap: () => setState(() => _editingProfile = !_editingProfile),
                ),
                if (_editingProfile) ...[
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _bioController,
                    decoration: const InputDecoration(labelText: 'Bio'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _paceController,
                          decoration: const InputDecoration(labelText: 'Pace (min/km)'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _distanceController,
                          decoration: const InputDecoration(labelText: 'Distance (km)'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.ground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Discoverable to nearby runners'),
                      value: _discoverable,
                      onChanged: (v) => setState(() => _discoverable = v),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save'),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton.icon(
                  onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedLogout01, color: AppColors.danger, size: 18),
                  label: const Text('Sign out'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;

  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final color = achievement.unlocked ? AppColors.accent : AppColors.divider;
    final iconColor = achievement.unlocked ? Colors.white : AppColors.inkSecondary;
    return Tooltip(
      message: '${achievement.title}: ${achievement.description}',
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
            child: Center(
              child: HugeIcon(icon: HugeIcons.strokeRoundedMedal01, color: iconColor, size: 22),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              color: achievement.unlocked ? AppColors.ink : AppColors.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLink extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback onTap;

  const _SectionLink({required this.icon, required this.label, required this.onTap});

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
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
          child: Row(
            children: [
              HugeIcon(icon: icon, color: AppColors.accent, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
              const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: AppColors.inkSecondary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
