import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/labels.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/data/sample/sample_resumes.dart';
import '../../../../shared/domain/domain.dart';
import '../../domain/resume_templates.dart';
import '../resume_providers.dart';
import '../widgets/template_picker.dart';

/// Browse templates. Each is previewed with a labeled sample resume, and can
/// be applied to one of the user's resumes.
class TemplateGalleryScreen extends ConsumerStatefulWidget {
  const TemplateGalleryScreen({super.key});

  @override
  ConsumerState<TemplateGalleryScreen> createState() => _TemplateGalleryScreenState();
}

class _TemplateGalleryScreenState extends ConsumerState<TemplateGalleryScreen> {
  String _selected = ResumeTemplates.classic.id;

  Future<void> _apply() async {
    final resumes = ref.read(userResumesProvider).value ?? const <Resume>[];
    if (resumes.isEmpty) {
      showAppSnackBar(context, 'Create a resume first.');
      return;
    }
    final target = await showModalBottomSheet<Resume>(
      context: context,
      builder: (c) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Apply to which resume?')),
            for (final r in resumes)
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(r.title),
                onTap: () => Navigator.pop(c, r),
              ),
          ],
        ),
      ),
    );
    if (target == null) return;
    final result = await ref
        .read(resumeRepositoryProvider)
        .saveResume(target.copyWith(templateId: _selected));
    if (mounted) {
      showAppSnackBar(
        context,
        result.isOk
            ? '${ResumeTemplates.byId(_selected).name} applied to "${target.title}"'
            : 'Could not apply the template.',
        error: !result.isOk,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sample = sampleResumes('preview', DateTime.now()).first;
    return Scaffold(
      appBar: AppBar(title: const Text('Templates')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          const Row(
            children: [
              Expanded(child: Text('Previews use a made-up resume.')),
              SampleBadge(),
            ],
          ),
          AppSpacing.gapLg,
          TemplatePicker(
            resume: sample,
            selectedId: _selected,
            onSelected: (id) => setState(() => _selected = id),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: FilledButton(onPressed: _apply, child: const Text('Use this template')),
        ),
      ),
    );
  }
}
