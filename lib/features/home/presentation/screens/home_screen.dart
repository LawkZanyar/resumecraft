import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/labels.dart';
import '../../../../core/widgets/phase_label.dart';
import '../../../profile/presentation/profile_providers.dart';
import '../widgets/home_widgets.dart';

/// Dashboard: welcome, resume status, quick actions, activity and AI tips.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(currentProfileProvider).value?.fullName ?? '';
    final first = name.split(' ').first;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.page,
          children: [
            WelcomeHeader(firstName: first),
            AppSpacing.gapLg,
            const Row(
              children: [
                Expanded(
                  child: ProgressCard(
                    title: 'Resume completion',
                    value: null,
                    icon: Icons.task_alt_rounded,
                    footer: PhaseLabel(2),
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: ProgressCard(
                    title: 'Resume score',
                    value: null,
                    icon: Icons.insights_rounded,
                    footer: PhaseLabel(2),
                  ),
                ),
              ],
            ),
            const SectionHeader('Quick actions'),
            QuickActionsGrid(
              actions: [
                QuickAction(
                  Icons.note_add_outlined,
                  'Create resume',
                  () => context.push(Routes.resumeNew),
                ),
                // The scanner arrives in Phase 3 (Task 3.2).
                QuickAction(
                  Icons.document_scanner_outlined,
                  'Scan resume',
                  () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Scanning a paper resume is available in Phase 3.'),
                    ),
                  ),
                ),
                QuickAction(
                  Icons.mic_none_rounded,
                  'Voice to resume',
                  () => context.push(Routes.voice),
                ),
                QuickAction(
                  Icons.travel_explore_rounded,
                  'Find jobs',
                  () => context.go(Routes.jobs),
                ),
              ],
            ),
            AppSpacing.gapSm,
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Scan resume'), AppSpacing.gapSm, PhaseLabel(3)],
            ),
            AppSpacing.gapLg,
            InterviewEntryCard(onTap: () => context.push(Routes.interview)),
            const SectionHeader('Recent activity', trailing: SampleBadge()),
            const AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ActivityTile(
                    icon: Icons.edit_note_rounded,
                    title: 'Edited "Product Designer" resume',
                    time: '2 h ago',
                  ),
                  ActivityTile(
                    icon: Icons.bookmark_add_outlined,
                    title: 'Saved a sample job: UX Designer at Northwind Studio',
                    time: 'Yesterday',
                  ),
                  ActivityTile(
                    icon: Icons.record_voice_over_outlined,
                    title: 'Practiced a general interview',
                    time: '3 days ago',
                  ),
                ],
              ),
            ),
            const SectionHeader('AI recommendations', trailing: SampleBadge()),
            const AiTipCard(
              tip: 'Add measurable results you achieved to your latest role, '
                  'using numbers you can confirm.',
            ),
            AppSpacing.gapMd,
            const AiTipCard(
              tip: 'Your skills section lists tools only. Consider adding the '
                  'soft skills your experience shows.',
            ),
          ],
        ),
      ),
    );
  }
}
