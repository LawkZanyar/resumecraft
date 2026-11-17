import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../applications/presentation/application_providers.dart';
import '../jobs_providers.dart';
import '../widgets/job_card.dart';

/// Jobs tab: search, nearby, saved jobs and the application tracker.
class JobsHubScreen extends ConsumerWidget {
  const JobsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(jobSearchProvider);
    final stats = ref.watch(applicationStatsProvider).value;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Jobs')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(jobSearchProvider.notifier).search(search.query),
        child: ListView(
          padding: AppSpacing.page,
          children: [
            AppCard(
              key: const Key('jobs_search_entry'),
              onTap: () => context.push(Routes.jobSearch),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: scheme.onSurfaceVariant),
                  AppSpacing.gapMd,
                  Text(
                    'Search by title, skill or city',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            AppSpacing.gapLg,
            Row(
              children: [
                _Shortcut(
                  icon: Icons.near_me_outlined,
                  label: 'Nearby',
                  onTap: () => context.push(Routes.nearbyJobs),
                ),
                AppSpacing.gapSm,
                _Shortcut(
                  icon: Icons.bookmark_outline_rounded,
                  label: 'Saved',
                  onTap: () => context.push(Routes.savedJobs),
                ),
                AppSpacing.gapSm,
                _Shortcut(
                  key: const Key('tracker_entry'),
                  icon: Icons.view_kanban_outlined,
                  label: 'Tracker',
                  badge: stats?.active,
                  onTap: () => context.push(Routes.tracker),
                ),
                AppSpacing.gapSm,
                _Shortcut(
                  icon: Icons.bar_chart_rounded,
                  label: 'Stats',
                  onTap: () => context.push(Routes.trackerStats),
                ),
              ],
            ),
            const SectionHeader('Latest opportunities'),
            if (search.notice != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(search.notice!, style: Theme.of(context).textTheme.bodySmall),
              ),
            if (search.loading && search.jobs.isEmpty)
              const LoadingView()
            else if (search.error != null)
              ErrorView(
                error: search.error!,
                onRetry: () => ref.read(jobSearchProvider.notifier).search(search.query),
              )
            else if (search.jobs.isEmpty)
              const EmptyView(icon: Icons.work_off_outlined, title: 'No jobs found')
            else
              for (final j in search.jobs.take(8))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: JobCard(job: j),
                ),
          ],
        ),
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          children: [
            Badge(
              isLabelVisible: (badge ?? 0) > 0,
              label: Text('${badge ?? 0}'),
              child: Icon(icon, color: scheme.secondary),
            ),
            AppSpacing.gapXs,
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
