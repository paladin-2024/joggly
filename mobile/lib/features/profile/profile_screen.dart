import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme.dart';
import '../../core/widgets/stat_block.dart';
import '../../models/profile.dart';
import '../auth/auth_controller.dart';
import '../tracking/activity_repository.dart';
import '../tracking/models/profile_stats.dart';
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
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      ref.read(profileRepositoryProvider).me(),
      ref.read(activityRepositoryProvider).stats(),
    ]);
    final profile = results[0] as Profile;
    setState(() {
      _profile = profile;
      _stats = results[1] as ProfileStats;
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
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

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.accentTint,
            backgroundImage: _profile!.avatarUrl != null ? NetworkImage(_profile!.avatarUrl!) : null,
            child: _profile!.avatarUrl == null
                ? const HugeIcon(icon: HugeIcons.strokeRoundedUser, color: AppColors.accent, size: 36)
                : null,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(child: Text(_profile!.displayName, style: Theme.of(context).textTheme.titleLarge)),
        const SizedBox(height: AppSpacing.lg),
        if (_stats != null)
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                StatBlock(
                  icon: HugeIcons.strokeRoundedRunningShoes,
                  value: '${_stats!.totalActivities}',
                  unit: 'runs tracked',
                ),
                StatBlock(
                  icon: HugeIcons.strokeRoundedRoute01,
                  value: _stats!.totalDistanceKm.toStringAsFixed(1),
                  unit: 'total km',
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
        Text('About you', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        TextField(controller: _bioController, decoration: const InputDecoration(labelText: 'Bio'), maxLines: 3),
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
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
        const SizedBox(height: AppSpacing.lg),
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
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedLogout01, color: AppColors.danger, size: 18),
          label: const Text('Sign out'),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
        ),
      ],
    );
  }
}
