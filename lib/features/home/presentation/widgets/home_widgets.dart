import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

String greeting([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  if (h < 12) return 'Good morning';
  if (h < 18) return 'Good afternoon';
  return 'Good evening';
}

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key, required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          firstName.isEmpty ? greeting() : '${greeting()}, $firstName',
          style: text.headlineSmall,
        ),
        AppSpacing.gapXs,
        Text(
          'Let us move your career forward today.',
          style: text.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Circular percentage card. A null [value] shows a dash.
class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.footer,
    this.onTap,
  });

  final String title;
  final int? value;
  final IconData icon;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final v = value;
    final color = v == null ? scheme.outline : AppColors.scoreColor(v);
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: scheme.secondary),
              AppSpacing.gapSm,
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          Center(
            child: SizedBox(
              height: 72,
              width: 72,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: (v ?? 0) / 100),
                    duration: AppSpacing.animMedium,
                    builder: (context, t, _) => CircularProgressIndicator(
                      value: t,
                      strokeWidth: 7,
                      backgroundColor: scheme.surfaceContainerHighest,
                      color: color,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Center(
                    child: Text(
                      v == null ? '—' : '$v',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (footer != null) ...[AppSpacing.gapMd, Center(child: footer)],
        ],
      ),
    );
  }
}

class QuickAction {
  const QuickAction(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (final a in actions)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AppCard(
                onTap: a.onTap,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: scheme.secondaryContainer,
                      child: Icon(a.icon, color: scheme.secondary, size: 20),
                    ),
                    AppSpacing.gapSm,
                    Text(
                      a.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class InterviewEntryCard extends StatelessWidget {
  const InterviewEntryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      key: const Key('home_interview_entry'),
      onTap: onTap,
      color: scheme.primary,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onPrimary,
                      ),
                ),
                Text(
                  'Practice with questions based on your resume',
                  style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_rounded, color: scheme.onPrimary),
        ],
      ),
    );
  }
}

class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.icon,
    required this.title,
    required this.time,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String time;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Text(time, style: Theme.of(context).textTheme.bodySmall),
      onTap: onTap,
    );
  }
}

class AiTipCard extends StatelessWidget {
  const AiTipCard({super.key, required this.tip, this.onTap});

  final String tip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: scheme.tertiary),
          AppSpacing.gapMd,
          Expanded(child: Text(tip)),
        ],
      ),
    );
  }
}
