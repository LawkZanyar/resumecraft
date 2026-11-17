import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/domain/domain.dart';
import '../application_providers.dart';
import '../widgets/application_widgets.dart';

/// Dashboard of application statistics and upcoming events.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(applicationStatsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Application statistics')),
      body: AsyncValueView<ApplicationStats>(
        value: stats,
        data: (s) => ListView(
          padding: AppSpacing.page,
          children: [
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    icon: Icons.work_outline_rounded,
                    label: 'Total',
                    value: '${s.total}',
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: StatTile(
                    icon: Icons.pending_actions_rounded,
                    label: 'Active',
                    value: '${s.active}',
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: StatTile(
                    icon: Icons.trending_up_rounded,
                    label: 'Interview rate',
                    value: '${s.interviewRate}%',
                  ),
                ),
              ],
            ),
            const SectionHeader('By status'),
            AppCard(
              child: Column(
                children: [
                  for (final st in ApplicationStatus.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          SizedBox(width: 140, child: StatusPill(st)),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: s.total == 0 ? 0 : s.count(st) / s.total,
                                minHeight: 10,
                                color: statusColor(st),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text('${s.count(st)}', textAlign: TextAlign.end),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SectionHeader('Upcoming interviews and deadlines'),
            if (s.upcoming.isEmpty)
              const EmptyView(icon: Icons.event_busy_outlined, title: 'Nothing scheduled')
            else
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(children: [for (final e in s.upcoming) UpcomingEventTile(event: e)]),
              ),
          ],
        ),
      ),
    );
  }
}
