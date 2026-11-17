import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/phase_label.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/domain/domain.dart';
import '../../../applications/presentation/application_providers.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../jobs_providers.dart';
import '../widgets/job_card.dart';

/// Job details, company information and the application link.
class JobDetailsScreen extends ConsumerWidget {
  const JobDetailsScreen({super.key, required this.jobId});

  final String jobId;

  Future<void> _toggleSave(BuildContext context, WidgetRef ref, Job job, bool saved) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    final repo = ref.read(jobRepositoryProvider);
    final r = saved ? await repo.removeSavedJob(uid, job.jobId) : await repo.saveJob(uid, job);
    if (context.mounted && !r.isOk) {
      showAppSnackBar(context, 'Could not update saved jobs.', error: true);
    }
  }

  Future<void> _track(BuildContext context, WidgetRef ref, Job job) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    final r = await ref
        .read(applicationRepositoryProvider)
        .addApplication(
          JobApplication(
            applicationId: '',
            userId: uid,
            jobId: job.jobId,
            jobSnapshot: job,
            status: ApplicationStatus.interested,
            createdAt: DateTime.now(),
          ),
        );
    if (!context.mounted) return;
    r.when(
      ok: (a) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Added to your tracker'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => context.push(Routes.applicationDetails(a.applicationId)),
          ),
        ),
      ),
      err: (f) => showAppSnackBar(context, f.message, error: true),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref.watch(jobByIdProvider(jobId));
    final saved = ref.watch(isJobSavedProvider(jobId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job details'),
        actions: [
          if (job.value case final j?)
            IconButton(
              key: const Key('save_job'),
              tooltip: saved ? 'Remove from saved' : 'Save job',
              icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded),
              onPressed: () => _toggleSave(context, ref, j, saved),
            ),
        ],
      ),
      body: AsyncValueView<Job>(
        value: job,
        onRetry: () => ref.invalidate(jobByIdProvider(jobId)),
        data: (j) {
          final text = Theme.of(context).textTheme;
          return ListView(
            padding: AppSpacing.page,
            children: [
              Text(j.title, style: text.headlineSmall),
              AppSpacing.gapXs,
              Text(j.company, style: text.titleMedium),
              AppSpacing.gapSm,
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  JobSourceLabel(job: j),
                  Text(j.location, style: text.bodyMedium),
                  if (j.employmentType.isNotEmpty)
                    Text('· ${j.employmentType}', style: text.bodyMedium),
                ],
              ),
              if (j.salary != null) ...[AppSpacing.gapSm, Text(j.salary!, style: text.titleSmall)],
              if (j.postedAt != null)
                Text('Posted ${Formatters.date(j.postedAt)}', style: text.bodySmall),
              const SectionHeader('About the role'),
              Text(j.description.isEmpty ? 'No description provided.' : j.description),
              if (j.requirements.isNotEmpty) ...[
                const SectionHeader('Requirements'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final r in j.requirements) Chip(label: Text(r))],
                ),
              ],
              const SectionHeader('Company'),
              AppCard(
                child: Text(
                  j.isSample
                      ? '${j.company} is a fictional company in the sample job database.'
                      : 'Listed by ${j.company}. Company details come from the job listing.',
                ),
              ),
              AppSpacing.gapXl,
              const PhaseLockedButton(
                phase: 4,
                label: 'Check compatibility with my resume',
                icon: Icons.fact_check_outlined,
              ),
              AppSpacing.gapMd,
              OutlinedButton.icon(
                key: const Key('add_to_tracker'),
                onPressed: () => _track(context, ref, j),
                icon: const Icon(Icons.playlist_add_rounded),
                label: const Text('Add to application tracker'),
              ),
              AppSpacing.gapMd,
              FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: j.applicationUrl));
                  if (context.mounted) {
                    showAppSnackBar(context, 'Application link copied: ${j.applicationUrl}');
                  }
                },
                icon: const Icon(Icons.link_rounded),
                label: const Text('Copy application link'),
              ),
            ],
          );
        },
      ),
    );
  }
}
