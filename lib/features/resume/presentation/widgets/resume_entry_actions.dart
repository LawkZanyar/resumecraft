import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/phase_label.dart';

/// Create / scan / templates shortcuts at the top of My Resumes.
class ResumeEntryActions extends StatelessWidget {
  const ResumeEntryActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Action(
            icon: Icons.note_add_outlined,
            label: 'Create',
            onTap: () => context.push(Routes.resumeNew),
          ),
        ),
        AppSpacing.gapMd,
        const Expanded(
          child: _Action(
            icon: Icons.document_scanner_outlined,
            label: 'Scan paper resume',
            footer: PhaseLabel(3),
          ),
        ),
        AppSpacing.gapMd,
        Expanded(
          child: _Action(
            icon: Icons.dashboard_customize_outlined,
            label: 'Templates',
            onTap: () => context.push(Routes.templates),
          ),
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, this.onTap, this.footer});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      onTap: onTap ??
          () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label is available in Phase 3.')),
              ),
      child: Column(
        children: [
          Icon(icon, color: scheme.secondary),
          AppSpacing.gapSm,
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          if (footer != null) ...[
            AppSpacing.gapXs,
            FittedBox(child: footer),
          ],
        ],
      ),
    );
  }
}
