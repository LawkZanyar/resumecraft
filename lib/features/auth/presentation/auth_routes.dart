import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/register_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/splash_screen.dart';

final authRoutes = <RouteBase>[
  GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
  GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingScreen()),
  GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
  GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
  GoRoute(
    path: Routes.resetPassword,
    builder: (_, _) => const ResetPasswordScreen(),
  ),
];
