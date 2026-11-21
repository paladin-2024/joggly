import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/sign_in_screen.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_prefs.dart';
import 'features/onboarding/onboarding_screen.dart';

class JogglyApp extends ConsumerWidget {
  const JogglyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'Joggly',
      theme: buildAppTheme(),
      home: auth.loading
          ? Scaffold(
              backgroundColor: AppColors.ground,
              body: const Center(
                child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2.5),
              ),
            )
          : (auth.user != null ? const _AuthenticatedGate() : const SignInScreen()),
    );
  }
}

/// Decides between the one-time onboarding flow and the home screen, once signed in.
class _AuthenticatedGate extends ConsumerStatefulWidget {
  const _AuthenticatedGate();

  @override
  ConsumerState<_AuthenticatedGate> createState() => _AuthenticatedGateState();
}

class _AuthenticatedGateState extends ConsumerState<_AuthenticatedGate> {
  bool? _hasSeenOnboarding;

  @override
  void initState() {
    super.initState();
    ref.read(onboardingPrefsProvider).hasSeenOnboarding().then((seen) {
      if (mounted) setState(() => _hasSeenOnboarding = seen);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSeenOnboarding == null) {
      return Scaffold(
        backgroundColor: AppColors.ground,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2.5),
        ),
      );
    }
    if (_hasSeenOnboarding == false) {
      return OnboardingScreen(onDone: () => setState(() => _hasSeenOnboarding = true));
    }
    return const HomeScreen();
  }
}
