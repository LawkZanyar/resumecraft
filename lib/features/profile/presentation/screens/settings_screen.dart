import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/widgets/app_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          const SectionHeader('Theme'),
          AppCard(
            padding: EdgeInsets.zero,
            child: RadioGroup<ThemeMode>(
              groupValue: mode,
              onChanged: (m) {
                if (m != null) ref.read(themeModeProvider.notifier).setMode(m);
              },
              child: const Column(
                children: [
                  RadioListTile(
                    value: ThemeMode.system,
                    title: Text('Use device setting'),
                  ),
                  RadioListTile(value: ThemeMode.light, title: Text('Light')),
                  RadioListTile(value: ThemeMode.dark, title: Text('Dark')),
                ],
              ),
            ),
          ),
          const SectionHeader('About'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppConfig.appName, style: Theme.of(context).textTheme.titleMedium),
                AppSpacing.gapXs,
                Text(
                  AppConfig.useFakes
                      ? 'Running with sample data (development mode).'
                      : 'Connected to live services.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
