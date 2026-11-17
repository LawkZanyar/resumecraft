import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/domain/domain.dart';
import '../../../ai/presentation/ai_providers.dart';
import '../../../ai/presentation/widgets/ai_widgets.dart';
import '../../../ai_assistant/presentation/widgets/resume_picker.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../resume/presentation/resume_providers.dart';
import '../voice_providers.dart';

/// Review and edit organized voice content before adding it to a resume.
class VoiceReviewScreen extends ConsumerStatefulWidget {
  const VoiceReviewScreen({super.key});

  @override
  ConsumerState<VoiceReviewScreen> createState() => _VoiceReviewScreenState();
}

class _VoiceReviewScreenState extends ConsumerState<VoiceReviewScreen> {
  Resume? _target;
  final Set<int> _confirmed = {};
  bool _saving = false;

  Future<void> _add() async {
    final draft = ref.read(voiceDraftProvider);
    if (draft == null) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final base =
        _target ??
        Resume(
          resumeId: '',
          userId: ref.read(currentUserIdProvider) ?? '',
          title: 'Voice resume',
          createdAt: now,
          updatedAt: now,
        );
    final result = await ref
        .read(resumeRepositoryProvider)
        .saveResume(mergeVoiceDraft(base, draft));
    if (!mounted) return;
    setState(() => _saving = false);
    result.when(
      ok: (saved) {
        ref.read(voiceDraftProvider.notifier).set(null);
        showAppSnackBar(context, 'Added to "${saved.title}"');
        context.go(Routes.resumeEdit(saved.resumeId));
      },
      err: (f) => showAppSnackBar(context, f.message, error: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(voiceDraftProvider);
    final ctrl = ref.read(voiceDraftProvider.notifier);
    final isSample = ref.watch(aiServiceProvider).isSample;
    if (draft == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: const EmptyView(icon: Icons.mic_off_outlined, title: 'Nothing to review yet'),
      );
    }
    final allConfirmed = _confirmed.length >= draft.needsConfirmation.length;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Review voice content')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Edit anything before it goes into a resume.')),
              if (isSample) const SampleAiLabel(),
            ],
          ),
          if (draft.isEmpty)
            const EmptyView(
              icon: Icons.help_outline,
              title: 'Nothing recognized',
              message: 'Try describing where you worked or studied, and what you are good at.',
            ),
          if (draft.needsConfirmation.isNotEmpty) ...[
            const SectionHeader('Please confirm'),
            AppCard(
              color: AppColors.warning.withValues(alpha: 0.08),
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < draft.needsConfirmation.length; i++)
                    CheckboxListTile(
                      value: _confirmed.contains(i),
                      title: Text(draft.needsConfirmation[i], style: text.bodyMedium),
                      onChanged: (v) =>
                          setState(() => v! ? _confirmed.add(i) : _confirmed.remove(i)),
                    ),
                ],
              ),
            ),
          ],
          if (draft.summary.isNotEmpty) ...[
            const SectionHeader('Summary'),
            TextFormField(
              initialValue: draft.summary,
              maxLines: 3,
              onChanged: (v) => ctrl.update((d) => d.copyWith(summary: v)),
            ),
          ],
          if (draft.experience.isNotEmpty) const SectionHeader('Experience'),
          for (var i = 0; i < draft.experience.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: draft.experience[i].role,
                      decoration: const InputDecoration(labelText: 'Job title'),
                      onChanged: (v) => ctrl.update(
                        (d) => d.copyWith(
                          experience: [
                            for (var j = 0; j < d.experience.length; j++)
                              j == i ? d.experience[j].copyWith(role: v) : d.experience[j],
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.gapSm,
                    TextFormField(
                      initialValue: draft.experience[i].company,
                      decoration: const InputDecoration(labelText: 'Company'),
                      onChanged: (v) => ctrl.update(
                        (d) => d.copyWith(
                          experience: [
                            for (var j = 0; j < d.experience.length; j++)
                              j == i ? d.experience[j].copyWith(company: v) : d.experience[j],
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.gapSm,
                    TextFormField(
                      initialValue: draft.experience[i].description,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Description'),
                      onChanged: (v) => ctrl.update(
                        (d) => d.copyWith(
                          experience: [
                            for (var j = 0; j < d.experience.length; j++)
                              j == i ? d.experience[j].copyWith(description: v) : d.experience[j],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (draft.education.isNotEmpty) const SectionHeader('Education'),
          for (var i = 0; i < draft.education.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: draft.education[i].field,
                      decoration: const InputDecoration(labelText: 'Field of study'),
                      onChanged: (v) => ctrl.update(
                        (d) => d.copyWith(
                          education: [
                            for (var j = 0; j < d.education.length; j++)
                              j == i ? d.education[j].copyWith(field: v) : d.education[j],
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.gapSm,
                    TextFormField(
                      initialValue: draft.education[i].institution,
                      decoration: const InputDecoration(labelText: 'School'),
                      onChanged: (v) => ctrl.update(
                        (d) => d.copyWith(
                          education: [
                            for (var j = 0; j < d.education.length; j++)
                              j == i ? d.education[j].copyWith(institution: v) : d.education[j],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (draft.skills.isNotEmpty) ...[
            const SectionHeader('Skills'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in draft.skills)
                  InputChip(
                    label: Text(s),
                    onDeleted: () => ctrl.update(
                      (d) => d.copyWith(skills: d.skills.where((x) => x != s).toList()),
                    ),
                  ),
              ],
            ),
          ],
          const SectionHeader('Add to'),
          ResumePicker(
            selectedId: _target?.resumeId,
            allowNone: true,
            label: 'Resume (None creates a new one)',
            onChanged: (r) => setState(() => _target = r),
          ),
          AppSpacing.gapLg,
          if (!allConfirmed)
            Text(
              'Tick each item above once you have checked or fixed it.',
              style: text.bodySmall?.copyWith(color: AppColors.warning),
            ),
          AppSpacing.gapSm,
          PrimaryButton(
            key: const Key('voice_add_button'),
            label: _target == null ? 'Create resume from this' : 'Add to resume',
            loading: _saving,
            onPressed: draft.isEmpty || !allConfirmed ? null : _add,
          ),
        ],
      ),
    );
  }
}
