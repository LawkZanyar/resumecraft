import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/providers/core_providers.dart';
import 'splash_screen.dart';

class _Page {
  const _Page(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

const _pages = [
  _Page(
    Icons.description_outlined,
    'Build a standout resume',
    'Create, customize and export professional resumes, then let AI polish '
        'the wording of what you wrote.',
  ),
  _Page(
    Icons.document_scanner_outlined,
    'Scan or speak your experience',
    'Turn a paper resume into editable sections with your camera, or describe '
        'your background out loud.',
  ),
  _Page(
    Icons.work_outline_rounded,
    'Find jobs and track applications',
    'Discover nearby opportunities, check how well you match, and get '
        'reminders for interviews and follow-ups.',
  ),
  _Page(
    Icons.record_voice_over_outlined,
    'Practice interviews with AI',
    'Answer realistic questions and get scored feedback that only uses your '
        'real background.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(sharedPreferencesProvider).setBool(onboardingSeenKey, true);
    if (mounted) context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final last = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _finish, child: const Text('Skip')),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 64,
                          backgroundColor: scheme.secondaryContainer,
                          child: Icon(page.icon, size: 60, color: scheme.secondary),
                        ),
                        AppSpacing.gapXl,
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        AppSpacing.gapMd,
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: AppSpacing.animFast,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: i == _index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: i == _index ? scheme.secondary : scheme.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: last
                      ? _finish
                      : () => _controller.nextPage(
                            duration: AppSpacing.animMedium,
                            curve: Curves.easeOut,
                          ),
                  child: Text(last ? 'Get started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
