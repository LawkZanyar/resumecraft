import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/providers/core_providers.dart';
import '../auth_providers.dart';
import '../widgets/auth_scaffold.dart';

const onboardingSeenKey = 'onboarding_seen';

/// Shows the brand while the session is restored, then routes the user.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  void _route(AsyncValue<Object?> auth) {
    if (_navigated || auth.isLoading) return;
    _navigated = true;
    final seen =
        ref.read(sharedPreferencesProvider).getBool(onboardingSeenKey) ?? false;
    final signedIn = ref.read(currentUserProvider) != null;
    final target = signedIn
        ? Routes.home
        : (seen ? Routes.login : Routes.onboarding);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(target);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    _route(auth);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 84),
            AppSpacing.gapLg,
            Text(
              AppConfig.appName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimary,
                  ),
            ),
            AppSpacing.gapSm,
            Text(
              'Your AI career assistant',
              style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.75)),
            ),
          ],
        ),
      ),
    );
  }
}
