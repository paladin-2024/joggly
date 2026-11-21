import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme.dart';
import '../auth/auth_controller.dart';
import '../connections/connections_screen.dart';
import '../map/map_screen.dart';
import '../profile/profile_screen.dart';
import '../runs/my_runs_screen.dart';
import '../tracking/track_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user!;

    final titles = ['Nearby', 'Track', 'My runs', 'Connections', 'Profile'];
    final pages = [
      const MapScreen(),
      const TrackScreen(),
      const MyRunsScreen(),
      ConnectionsScreen(currentUserId: user.id),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: _tabIndex == 0 ? null : AppBar(title: Text(titles[_tabIndex])),
      body: SafeArea(top: _tabIndex == 0, child: pages[_tabIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedMap, size: 22),
            selectedIcon: HugeIcon(icon: HugeIcons.strokeRoundedMap, size: 22, color: AppColors.accent),
            label: 'Nearby',
          ),
          NavigationDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedRunningShoes, size: 22),
            selectedIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedRunningShoes,
              size: 22,
              color: AppColors.accent,
            ),
            label: 'Track',
          ),
          NavigationDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedCalendar02, size: 22),
            selectedIcon: HugeIcon(icon: HugeIcons.strokeRoundedCalendar02, size: 22, color: AppColors.accent),
            label: 'My runs',
          ),
          NavigationDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedUserGroup, size: 22),
            selectedIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedUserGroup,
              size: 22,
              color: AppColors.accent,
            ),
            label: 'Connections',
          ),
          NavigationDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedUser, size: 22),
            selectedIcon: HugeIcon(icon: HugeIcons.strokeRoundedUser, size: 22, color: AppColors.accent),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
