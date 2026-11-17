import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/domain/domain.dart';
import '../application_providers.dart';
import '../widgets/application_widgets.dart';

/// Application tracker grouped by status, with upcoming events on top.
class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  ApplicationStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final apps = ref.watch(applicationsProvider);
    final stats = ref.watch(applicationStatsProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application tracker'),
        actions: [
          IconButton(
            tooltip: 'Statistics',
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => context.push(Routes.trackerStats),
          ),
        ],
      ),
      body: AsyncValueView<List<JobApplication>>(
        value: apps,
        onRetry: () => ref.invalidate(applicationsProvider),
        data: (list) {
          final shown = _filter == null ? list : list.where((a) => a.status == _filter).toList();
          return ListView(
            padding: AppSpacing.page,
            children: [
              if (stats != null && stats.upcoming.isNotEmpty) ...[
                const SectionHeader('Coming up'),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [for (final e in stats.upcoming.take(3)) UpcomingEventTile(event: e)],
                  ),
                ),
              ],
              AppSpacing.gapMd,
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('All (${list.length})'),
                        selected: _filter == null,
                        onSelected: (_) => setState(() => _filter = null),
                      ),
                    ),
                    for (final s in ApplicationStatus.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('${s.label} (${stats?.count(s) ?? 0})'),
                          selected: _filter == s,
                          onSelected: (_) => setState(() => _filter = s),
                        ),
                      ),
                  ],
                ),
              ),
              AppSpacing.gapMd,
              if (shown.isEmpty)
                EmptyView(
                  icon: Icons.inbox_outlined,
                  title: _filter == null ? 'No applications yet' : 'Nothing in "${_filter!.label}"',
                  message: 'Open a job and tap "Add to application tracker".',
                  action: FilledButton(
                    onPressed: () => context.push(Routes.jobSearch),
                    child: const Text('Find jobs'),
                  ),
                )
              else
                for (final a in shown)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ApplicationCard(application: a),
                  ),
            ],
          );
        },
      ),
    );
  }
}
