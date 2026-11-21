import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets/illustration.dart';
import 'onboarding_prefs.dart';

class _OnboardingPage {
  final IllustrationAsset asset;
  final String title;
  final String body;

  const _OnboardingPage({required this.asset, required this.title, required this.body});
}

const _pages = [
  _OnboardingPage(
    asset: IllustrationAsset.compass,
    title: 'Find runners nearby',
    body: 'Browse runners around you by pace and distance, and ask to run together.',
  ),
  _OnboardingPage(
    asset: IllustrationAsset.personRunning,
    title: 'Track every run',
    body: 'Live GPS route, pace, splits, and steps — saved to your own history.',
  ),
  _OnboardingPage(
    asset: IllustrationAsset.trophy,
    title: 'Celebrate the miles',
    body: 'Host or join group runs, and watch your stats add up on your profile.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onDone;

  const OnboardingScreen({super.key, required this.onDone});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  Future<void> _finish() async {
    await ref.read(onboardingPrefsProvider).markSeen();
    widget.onDone();
  }

  void _next() {
    if (_page == _pages.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(duration: AppMotion.standard, curve: AppMotion.curve);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextButton(
                  onPressed: isLast ? null : _finish,
                  child: Text(
                    'Skip',
                    style: TextStyle(color: isLast ? Colors.transparent : AppColors.inkSecondary),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Illustration(page.asset, size: 160),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: AppColors.inkSecondary),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: AppMotion.fast,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _page ? AppColors.accent : AppColors.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(isLast ? 'Get started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
