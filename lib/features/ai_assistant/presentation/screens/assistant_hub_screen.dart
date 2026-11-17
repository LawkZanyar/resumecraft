import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

class _Tool {
  const _Tool(this.icon, this.title, this.subtitle, this.route);
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
}

const _tools = [
  _Tool(
    Icons.auto_fix_high_rounded,
    'Improve resume',
    'Rewrite, fix grammar and generate descriptions',
    Routes.improveResume,
  ),
  _Tool(
    Icons.insights_rounded,
    'Resume analysis',
    'Score out of 100 with recommendations',
    Routes.analysis,
  ),
  _Tool(
    Icons.psychology_alt_outlined,
    'Skill recommendations',
    'Skills your experience already supports',
    Routes.skills,
  ),
  _Tool(
    Icons.mic_none_rounded,
    'Voice to resume',
    'Describe your background out loud',
    Routes.voice,
  ),
];

/// AI Career Assistant tab.
class AssistantHubScreen extends StatelessWidget {
  const AssistantHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('AI Career Assistant')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          Text(
            'AI only improves what you write. It never adds jobs, degrees, dates or '
            'results you did not give it, and you review every change.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          AppSpacing.gapLg,
          for (final t in _tools)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                onTap: () => context.push(t.route),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: scheme.secondaryContainer,
                      child: Icon(t.icon, color: scheme.secondary),
                    ),
                    AppSpacing.gapLg,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.title, style: Theme.of(context).textTheme.titleMedium),
                          Text(t.subtitle, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          AppCard(
            key: const Key('assistant_interview_entry'),
            color: scheme.primary,
            onTap: () => context.push(Routes.interview),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: scheme.tertiary,
                  child: Icon(Icons.record_voice_over_rounded, color: scheme.onTertiary),
                ),
                AppSpacing.gapLg,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Interview Simulator',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: scheme.onPrimary),
                      ),
                      Text(
                        'Practice questions and get scored feedback',
                        style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: scheme.onPrimary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
