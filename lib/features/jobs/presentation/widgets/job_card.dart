import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/labels.dart';
import '../../../../shared/domain/domain.dart';

/// Shows where a job came from: "Sample" or the live API name.
class JobSourceLabel extends StatelessWidget {
  const JobSourceLabel({super.key, required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) => job.isSample
      ? const SampleBadge()
      : Pill(
          text: 'via ${job.source.label}',
          color: Theme.of(context).colorScheme.secondary,
          icon: Icons.public_rounded,
        );
}

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job, this.distanceKm, this.trailing});

  final Job job;
  final double? distanceKm;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: () => context.push(Routes.jobDetails(job.jobId)),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: scheme.secondaryContainer,
            child: Text(
              Formatters.initials(job.company),
              style: TextStyle(color: scheme.secondary, fontWeight: FontWeight.w700),
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.title, style: text.titleSmall),
                Text(job.company, style: text.bodyMedium),
                AppSpacing.gapXs,
                Text(
                  [
                    job.location,
                    if (distanceKm != null) Formatters.distanceKm(distanceKm!),
                    if (job.employmentType.isNotEmpty) job.employmentType,
                  ].join(' · '),
                  style: text.bodySmall,
                ),
                AppSpacing.gapSm,
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    JobSourceLabel(job: job),
                    if (job.category.isNotEmpty)
                      Pill(text: job.category, color: scheme.onSurfaceVariant),
                  ],
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
