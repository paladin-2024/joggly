import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/sign_in_screen.dart';
import 'features/home/home_screen.dart';

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
          : (auth.user != null ? const HomeScreen() : const SignInScreen()),
    );
  }
}
