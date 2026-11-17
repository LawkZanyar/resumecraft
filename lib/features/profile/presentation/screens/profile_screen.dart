import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/phase_label.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../profile_providers.dart';
import '../widgets/profile_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authRepositoryProvider).signOut();
    if (context.mounted) context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: AsyncValueView(
        value: profile,
        onRetry: () => ref.invalidate(currentProfileProvider),
        data: (p) => ListView(
          padding: AppSpacing.page,
          children: [
            AppCard(
              onTap: () => context.push(Routes.editProfile),
              child: Row(
                children: [
                  ProfileAvatar(name: p?.fullName ?? ''),
                  AppSpacing.gapLg,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (p?.fullName.isNotEmpty ?? false) ? p!.fullName : 'Your name',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(p?.email ?? '', style: Theme.of(context).textTheme.bodySmall),
                        if (p?.location != null)
                          Text(p!.location!, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_outlined),
                ],
              ),
            ),
            const SectionHeader('Security'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded),
                    title: const Text('Secure resume vault'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(Routes.vault),
                  ),
                  const PhaseLockedTile(
                    phase: 3,
                    icon: Icons.fingerprint_rounded,
                    title: 'Biometric settings',
                  ),
                ],
              ),
            ),
            const SectionHeader('Preferences'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('Appearance'),
                    subtitle: const Text('Light, dark or system theme'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(Routes.settings),
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Notifications'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(Routes.notificationSettings),
                  ),
                ],
              ),
            ),
            const SectionHeader('Privacy'),
            const AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  PhaseLockedTile(
                    phase: 2,
                    icon: Icons.privacy_tip_outlined,
                    title: 'AI data consent',
                  ),
                  PhaseLockedTile(
                    phase: 2,
                    icon: Icons.delete_forever_outlined,
                    title: 'Delete account and data',
                  ),
                ],
              ),
            ),
            AppSpacing.gapXl,
            OutlinedButton.icon(
              key: const Key('sign_out'),
              onPressed: () => _signOut(context, ref),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
