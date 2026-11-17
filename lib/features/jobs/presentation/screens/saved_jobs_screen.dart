import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/domain/domain.dart';
import '../jobs_providers.dart';
import '../widgets/job_card.dart';

class SavedJobsScreen extends ConsumerWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedJobsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Saved jobs')),
      body: AsyncValueView<List<Job>>(
        value: saved,
        onRetry: () => ref.invalidate(savedJobsProvider),
        data: (list) => list.isEmpty
            ? EmptyView(
                icon: Icons.bookmark_outline_rounded,
                title: 'No saved jobs',
                message: 'Tap the bookmark on a job to keep it here.',
                action: FilledButton(
                  onPressed: () => context.push(Routes.jobSearch),
                  child: const Text('Find jobs'),
                ),
              )
            : ListView.separated(
                padding: AppSpacing.page,
                itemCount: list.length,
                separatorBuilder: (_, _) => AppSpacing.gapSm,
                itemBuilder: (_, i) => JobCard(job: list[i]),
              ),
      ),
    );
  }
}
