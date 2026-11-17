import 'package:go_router/go_router.dart';

import '../../vault/presentation/screens/vault_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/settings_screen.dart';

/// Sub-routes of the Profile tab (`/profile/...`).
final profileRoutes = <RouteBase>[
  GoRoute(path: 'edit', builder: (_, _) => const EditProfileScreen()),
  GoRoute(path: 'settings', builder: (_, _) => const SettingsScreen()),
  GoRoute(
    path: 'notifications',
    builder: (_, _) => const NotificationSettingsScreen(),
  ),
  GoRoute(path: 'vault', builder: (_, _) => const VaultScreen()),
];
