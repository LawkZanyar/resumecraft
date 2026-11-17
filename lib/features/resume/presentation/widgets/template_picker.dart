import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/domain/domain.dart';
import '../../domain/resume_templates.dart';
import '../templates/resume_document.dart';

/// Grid of templates, each previewed with [resume]'s own content.
class TemplatePicker extends StatelessWidget {
  const TemplatePicker({
    super.key,
    required this.resume,
    required this.selectedId,
    required this.onSelected,
  });

  final Resume resume;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 0.58,
      children: [
        for (final t in ResumeTemplates.all)
          Semantics(
            selected: t.id == selectedId,
            button: true,
            label: '${t.name} template',
            child: InkWell(
              key: Key('template_${t.id}'),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              onTap: () => onSelected(t.id),
              child: AnimatedContainer(
                duration: AppSpacing.animFast,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: t.id == selectedId ? scheme.secondary : scheme.outlineVariant,
                    width: t.id == selectedId ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: IgnorePointer(
                        child: ResumeDocument(
                          resume: resume.copyWith(templateId: t.id),
                          fixedPage: true,
                        ),
                      ),
                    ),
                    AppSpacing.gapSm,
                    Row(
                      children: [
                        Expanded(child: Text(t.name, style: Theme.of(context).textTheme.titleSmall)),
                        if (t.id == selectedId)
                          Icon(Icons.check_circle_rounded, color: scheme.secondary, size: 18),
                      ],
                    ),
                    Text(
                      t.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
