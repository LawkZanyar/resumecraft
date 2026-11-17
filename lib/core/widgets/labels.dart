import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Small pill used for all status labels.
class Pill extends StatelessWidget {
  const Pill({super.key, required this.text, required this.color, this.icon});

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

/// Marks data that is sample (made-up) content, as required by the brief.
class SampleBadge extends StatelessWidget {
  const SampleBadge({super.key, this.text = 'Sample'});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Sample data',
      child: Pill(text: text, color: AppColors.warning, icon: Icons.science_outlined),
    );
  }
}
