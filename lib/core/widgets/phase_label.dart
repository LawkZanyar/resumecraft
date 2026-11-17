import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'labels.dart';
import 'state_views.dart';

/// "Available in Phase N" label for controls waiting for later work.
/// Every use must be removed by the end of Phase 4.
class PhaseLabel extends StatelessWidget {
  const PhaseLabel(this.phase, {super.key});

  final int phase;

  @override
  Widget build(BuildContext context) {
    return Pill(
      text: 'Available in Phase $phase',
      color: AppColors.secondary,
      icon: Icons.schedule_rounded,
    );
  }
}

/// A visibly labeled control that explains why it is not active yet,
/// so no button silently does nothing.
class PhaseLockedTile extends StatelessWidget {
  const PhaseLockedTile({
    super.key,
    required this.phase,
    required this.title,
    required this.icon,
    this.subtitle,
  });

  final int phase;
  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: PhaseLabel(phase),
      onTap: () => showAppSnackBar(
        context,
        '$title is available in Phase $phase.',
      ),
    );
  }
}

/// Outlined button version of a locked control.
class PhaseLockedButton extends StatelessWidget {
  const PhaseLockedButton({
    super.key,
    required this.phase,
    required this.label,
    required this.icon,
  });

  final int phase;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                showAppSnackBar(context, '$label is available in Phase $phase.'),
            icon: Icon(icon),
            label: Text(label),
          ),
        ),
        const SizedBox(height: 6),
        PhaseLabel(phase),
      ],
    );
  }
}
