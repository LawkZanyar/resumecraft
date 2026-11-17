import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/labels.dart';
import '../../../../core/widgets/phase_label.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/domain/domain.dart';
import '../../domain/resume_templates.dart';
import '../resume_providers.dart';
import '../templates/resume_document.dart';

enum _MenuAction { edit, preview, customize, rename, duplicate, exportPdf, delete }

class ResumeCard extends ConsumerWidget {
  const ResumeCard({super.key, required this.resume});

  final Resume resume;

  Future<void> _onMenu(BuildContext context, WidgetRef ref, _MenuAction a) async {
    final repo = ref.read(resumeRepositoryProvider);
    final id = resume.resumeId;
    switch (a) {
      case _MenuAction.edit:
        await context.push(Routes.resumeEdit(id));
      case _MenuAction.preview:
        await context.push(Routes.resumePreview(id));
      case _MenuAction.customize:
        await context.push(Routes.resumeCustomize(id));
      case _MenuAction.exportPdf:
        showAppSnackBar(context, 'PDF export is available in Phase 2.');
      case _MenuAction.rename:
        final title = await showRenameDialog(context, resume.title);
        if (title != null) await repo.renameResume(id, title);
      case _MenuAction.duplicate:
        final r = await repo.duplicateResume(id);
        if (context.mounted) {
          showAppSnackBar(context, r.isOk ? 'Resume duplicated' : 'Could not duplicate');
        }
      case _MenuAction.delete:
        final ok = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Delete resume?'),
            content: Text('"${resume.title}" will be permanently deleted.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
            ],
          ),
        );
        if (ok ?? false) await repo.deleteResume(id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final template = ResumeTemplates.byId(resume.templateId);
    return AppCard(
      onTap: () => context.push(Routes.resumeEdit(resume.resumeId)),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 64,
              height: 90,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: IgnorePointer(child: ResumeDocument(resume: resume, fixedPage: true)),
            ),
          ),
          AppSpacing.gapLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resume.title, style: text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                AppSpacing.gapXs,
                Text('${template.name} template', style: text.bodySmall),
                Text('Edited ${Formatters.relative(resume.updatedAt)}', style: text.bodySmall),
                AppSpacing.gapSm,
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (resume.isSample) const SampleBadge(),
                    if (resume.aiScore != null)
                      Pill(
                        text: 'Score ${resume.aiScore}',
                        color: AppColors.scoreColor(resume.aiScore!),
                        icon: Icons.insights_rounded,
                      ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<_MenuAction>(
            tooltip: 'Resume actions',
            onSelected: (a) => _onMenu(context, ref, a),
            itemBuilder: (_) => [
              const PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
              const PopupMenuItem(value: _MenuAction.preview, child: Text('Preview')),
              const PopupMenuItem(value: _MenuAction.customize, child: Text('Customize')),
              const PopupMenuItem(
                value: _MenuAction.exportPdf,
                child: Row(
                  children: [Text('Export PDF'), SizedBox(width: 8), PhaseLabel(2)],
                ),
              ),
              const PopupMenuItem(value: _MenuAction.rename, child: Text('Rename')),
              const PopupMenuItem(value: _MenuAction.duplicate, child: Text('Duplicate')),
              const PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}

Future<String?> showRenameDialog(BuildContext context, String current) {
  final controller = TextEditingController(text: current);
  return showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Rename resume'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Title'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final t = controller.text.trim();
            Navigator.pop(c, t.isEmpty ? null : t);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
