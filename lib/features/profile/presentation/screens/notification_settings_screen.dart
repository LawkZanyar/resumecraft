import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/phase_label.dart';
import '../profile_providers.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);
    final controller = ref.read(notificationPrefsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          const SectionHeader('Reminders', trailing: PhaseLabel(4)),
          Text(
            'Your choices are saved now. Reminders start being scheduled in Phase 4.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          AppSpacing.gapMd,
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Interview reminders'),
                  subtitle: const Text('Before a scheduled interview'),
                  value: prefs.interviewReminders,
                  onChanged: (v) =>
                      controller.update(prefs.copyWith(interviewReminders: v)),
                ),
                SwitchListTile(
                  title: const Text('Follow-up reminders'),
                  subtitle: const Text('When it is time to follow up'),
                  value: prefs.followUpReminders,
                  onChanged: (v) =>
                      controller.update(prefs.copyWith(followUpReminders: v)),
                ),
                SwitchListTile(
                  title: const Text('Deadline reminders'),
                  value: prefs.deadlineReminders,
                  onChanged: (v) =>
                      controller.update(prefs.copyWith(deadlineReminders: v)),
                ),
              ],
            ),
          ),
          const SectionHeader('Interview reminder timing'),
          AppCard(
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1 h')),
                ButtonSegment(value: 3, label: Text('3 h')),
                ButtonSegment(value: 24, label: Text('1 day')),
              ],
              selected: {prefs.reminderLeadHours},
              onSelectionChanged: (s) =>
                  controller.update(prefs.copyWith(reminderLeadHours: s.first)),
            ),
          ),
        ],
      ),
    );
  }
}
