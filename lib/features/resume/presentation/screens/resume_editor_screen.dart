import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/state_views.dart';
import '../resume_editor_controller.dart';
import '../widgets/editor_fields.dart';
import '../widgets/editor_steps.dart';
import '../widgets/save_status_chip.dart';
import '../widgets/template_picker.dart';

/// Multi-step editor for every resume section.
class ResumeEditorScreen extends ConsumerStatefulWidget {
  const ResumeEditorScreen({super.key, this.resumeId});

  /// Null when creating a new resume.
  final String? resumeId;

  @override
  ConsumerState<ResumeEditorScreen> createState() => _ResumeEditorScreenState();
}

class _ResumeEditorScreenState extends ConsumerState<ResumeEditorScreen> {
  static const steps = [
    'Basics',
    'Experience',
    'Education',
    'Skills',
    'Projects',
    'Certifications',
    'Languages',
    'Template',
  ];

  final _formKey = GlobalKey<FormState>();
  int _step = 0;

  String get _key => widget.resumeId ?? newResumeKey;

  bool _validate() => _formKey.currentState?.validate() ?? true;

  void _goTo(int step) {
    if (step > _step && !_validate()) return;
    setState(() => _step = step);
  }

  Future<void> _save({bool finish = false}) async {
    if (!_validate()) return;
    final controller = ref.read(resumeEditorProvider(_key).notifier);
    final ok = await controller.save();
    if (!mounted) return;
    if (!ok) {
      showAppSnackBar(context, 'Could not save. Please try again.', error: true);
      return;
    }
    final id = ref.read(resumeEditorProvider(_key)).value?.draft.resumeId;
    if (finish && id != null) {
      context.pushReplacement(Routes.resumePreview(id));
    } else {
      showAppSnackBar(context, 'Resume saved');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resumeEditorProvider(_key));
    final controller = ref.read(resumeEditorProvider(_key).notifier);
    final s = state.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resumeId == null ? 'New resume' : 'Edit resume'),
        actions: [
          if (s != null) SaveStatusChip(state: s),
          IconButton(
            key: const Key('editor_save'),
            tooltip: 'Save',
            onPressed: s == null ? null : _save,
            icon: const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: AsyncValueView(
        value: state,
        onRetry: () => ref.invalidate(resumeEditorProvider(_key)),
        data: (s) {
          final draft = s.draft;
          String newId() => ref.read(uuidProvider).v4();
          final body = switch (_step) {
            0 => BasicsStep(draft: draft, edit: controller.edit, newId: newId),
            1 => ExperienceStep(draft: draft, edit: controller.edit, newId: newId),
            2 => EducationStep(draft: draft, edit: controller.edit, newId: newId),
            3 => SkillsStep(draft: draft, edit: controller.edit),
            4 => ProjectsStep(draft: draft, edit: controller.edit, newId: newId),
            5 => CertificationsStep(draft: draft, edit: controller.edit, newId: newId),
            6 => LanguagesStep(draft: draft, edit: controller.edit, newId: newId),
            _ => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const StepIntro('Choose a template. You can change colors, fonts and '
                      'sections after saving.'),
                  TemplatePicker(
                    resume: draft,
                    selectedId: draft.templateId,
                    onSelected: (id) => controller.edit((d) => d.copyWith(templateId: id)),
                  ),
                ],
              ),
          };
          return Column(
            children: [
              _StepBar(steps: steps, current: _step, onTap: _goTo),
              LinearProgressIndicator(value: (_step + 1) / steps.length, minHeight: 2),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    key: PageStorageKey('step_$_step'),
                    padding: AppSpacing.page,
                    children: [
                      AnimatedSwitcher(
                        duration: AppSpacing.animFast,
                        child: KeyedSubtree(key: ValueKey(_step), child: body),
                      ),
                    ],
                  ),
                ),
              ),
              _BottomBar(
                isFirst: _step == 0,
                isLast: _step == steps.length - 1,
                saving: s.status == SaveStatus.saving,
                onBack: () => _goTo(_step - 1),
                onNext: () => _goTo(_step + 1),
                onFinish: () => _save(finish: true),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.steps, required this.current, required this.onTap});

  final List<String> steps;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        itemCount: steps.length,
        separatorBuilder: (_, _) => AppSpacing.gapSm,
        itemBuilder: (_, i) => ChoiceChip(
          label: Text('${i + 1}. ${steps[i]}'),
          selected: i == current,
          onSelected: (_) => onTap(i),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isFirst,
    required this.isLast,
    required this.saving,
    required this.onBack,
    required this.onNext,
    required this.onFinish,
  });

  final bool isFirst;
  final bool isLast;
  final bool saving;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            if (!isFirst)
              Expanded(
                child: OutlinedButton(onPressed: onBack, child: const Text('Back')),
              ),
            if (!isFirst) AppSpacing.gapMd,
            Expanded(
              child: FilledButton(
                key: const Key('editor_next'),
                onPressed: saving ? null : (isLast ? onFinish : onNext),
                child: Text(isLast ? 'Save and preview' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
