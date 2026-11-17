import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/ai_assistant/presentation/assistant_routes.dart';
import '../features/ai_assistant/presentation/screens/assistant_hub_screen.dart';
import '../features/auth/presentation/auth_routes.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/profile/presentation/profile_routes.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import 'not_found_screen.dart';
import 'routes.dart';
import 'shell/main_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// App router. Members add their own tab lines below.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash,
    errorBuilder: (_, state) => NotFoundScreen(location: state.uri.path),
    routes: [
      ...authRoutes,
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
            ],
          ),
          // My Resumes: Pasha (Task 1.2).
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.resumes,
                builder: (_, _) => const TabPlaceholderScreen(
                  title: 'My Resumes',
                  task: 'Task 1.2',
                  icon: Icons.description_outlined,
                ),
              ),
            ],
          ),
          // AI Career Assistant: Hananeh (Task 1.3).
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.assistant,
                builder: (_, _) => const AssistantHubScreen(),
                routes: assistantRoutes,
              ),
            ],
          ),
          // Jobs: Fatemeh (Task 1.4).
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.jobs,
                builder: (_, _) => const TabPlaceholderScreen(
                  title: 'Jobs',
                  task: 'Task 1.4',
                  icon: Icons.work_outline_rounded,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const ProfileScreen(),
                routes: profileRoutes,
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
