import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/labels.dart';
import '../../../../core/widgets/phase_label.dart';
import '../../../../core/widgets/state_views.dart';
import '../resume_providers.dart';
import '../templates/resume_document.dart';

/// Live preview of a resume exactly as its template renders it.
class ResumePreviewScreen extends ConsumerWidget {
  const ResumePreviewScreen({super.key, required this.resumeId});

  final String resumeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resume = ref.watch(resumeByIdProvider(resumeId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(Routes.resumeEdit(resumeId)),
          ),
          IconButton(
            tooltip: 'Customize',
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => context.push(Routes.resumeCustomize(resumeId)),
          ),
        ],
      ),
      body: AsyncValueView(
        value: resume,
        data: (r) {
          if (r == null) {
            return const EmptyView(icon: Icons.search_off_rounded, title: 'Resume not found');
          }
          return ListView(
            padding: AppSpacing.page,
            children: [
              Row(
                children: [
                  Expanded(child: Text(r.title, style: Theme.of(context).textTheme.titleMedium)),
                  if (r.isSample) const SampleBadge(),
                ],
              ),
              AppSpacing.gapMd,
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(4),
                clipBehavior: Clip.antiAlias,
                child: ResumeDocument(resume: r),
              ),
              AppSpacing.gapLg,
              const PhaseLockedButton(
                phase: 2,
                label: 'Export PDF',
                icon: Icons.picture_as_pdf_outlined,
              ),
            ],
          );
        },
      ),
    );
  }
}
