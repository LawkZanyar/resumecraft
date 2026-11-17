import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/domain/domain.dart';
import '../resume_providers.dart';
import '../widgets/resume_card.dart';
import '../widgets/resume_entry_actions.dart';

/// My Resumes tab: create, edit, scan, templates and export.
class ResumeListScreen extends ConsumerWidget {
  const ResumeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumes = ref.watch(userResumesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Resumes'),
        actions: [
          IconButton(
            tooltip: 'Templates',
            icon: const Icon(Icons.dashboard_customize_outlined),
            onPressed: () => context.push(Routes.templates),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('create_resume_fab'),
        onPressed: () => context.push(Routes.resumeNew),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New resume'),
      ),
      body: AsyncValueView<List<Resume>>(
        value: resumes,
        onRetry: () => ref.invalidate(userResumesProvider),
        data: (list) => ListView(
          padding: AppSpacing.page.copyWith(bottom: 96),
          children: [
            const ResumeEntryActions(),
            const SectionHeader('Your resumes'),
            if (list.isEmpty)
              EmptyView(
                icon: Icons.description_outlined,
                title: 'No resumes yet',
                message: 'Create your first resume or scan a paper one.',
                action: FilledButton(
                  onPressed: () => context.push(Routes.resumeNew),
                  child: const Text('Create resume'),
                ),
              )
            else
              for (final r in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: ResumeCard(resume: r),
                ),
          ],
        ),
      ),
    );
  }
}
