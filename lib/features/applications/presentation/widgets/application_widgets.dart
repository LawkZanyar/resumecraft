import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/labels.dart';
import '../../../../shared/domain/domain.dart';
import '../../../jobs/presentation/widgets/job_card.dart';
import '../application_providers.dart';

Color statusColor(ApplicationStatus s) => switch (s) {
  ApplicationStatus.interested => AppColors.textSecondary,
  ApplicationStatus.applied => AppColors.secondary,
  ApplicationStatus.underReview => AppColors.warning,
  ApplicationStatus.interviewScheduled => const Color(0xFF7A4CD9),
  ApplicationStatus.accepted => AppColors.success,
  ApplicationStatus.rejected => AppColors.error,
};

class StatusPill extends StatelessWidget {
  const StatusPill(this.status, {super.key});

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) => Pill(text: status.label, color: statusColor(status));
}

class ApplicationCard extends StatelessWidget {
  const ApplicationCard({super.key, required this.application});

  final JobApplication application;

  @override
  Widget build(BuildContext context) {
    final a = application;
    final text = Theme.of(context).textTheme;
    final next = [
      if (a.interviewDate != null) 'Interview ${Formatters.dateTime(a.interviewDate)}',
      if (a.followUpDate != null) 'Follow up ${Formatters.date(a.followUpDate)}',
    ];
    return AppCard(
      onTap: () => context.push(Routes.applicationDetails(a.applicationId)),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(a.jobSnapshot.title, style: text.titleSmall)),
              StatusPill(a.status),
            ],
          ),
          Text(a.jobSnapshot.company, style: text.bodyMedium),
          AppSpacing.gapXs,
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              JobSourceLabel(job: a.jobSnapshot),
              if (a.applicationDate != null)
                Text('Applied ${Formatters.date(a.applicationDate)}', style: text.bodySmall),
            ],
          ),
          if (next.isNotEmpty) ...[
            AppSpacing.gapXs,
            Text(next.join(' · '), style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}

class UpcomingEventTile extends StatelessWidget {
  const UpcomingEventTile({super.key, required this.event});

  final UpcomingEvent event;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        event.isInterview ? Icons.event_available_rounded : Icons.mark_email_unread_outlined,
      ),
      title: Text('${event.label}: ${event.application.jobSnapshot.title}'),
      subtitle: Text(
        '${event.application.jobSnapshot.company} · ${Formatters.dateTime(event.date)}',
      ),
      trailing: Text(Formatters.relative(event.date), style: Theme.of(context).textTheme.bodySmall),
      onTap: () => context.push(Routes.applicationDetails(event.application.applicationId)),
    );
  }
}
