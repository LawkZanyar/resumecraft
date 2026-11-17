import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/domain/domain.dart';
import '../../../ai/domain/ai_models.dart';
import '../../../ai/presentation/ai_providers.dart';
import '../../../ai/presentation/widgets/ai_widgets.dart';
import '../../../resume/presentation/resume_providers.dart';
import '../widgets/resume_picker.dart';

/// Skills that the user's own experience text supports.
class SkillsScreen extends ConsumerStatefulWidget {
  const SkillsScreen({super.key});

  @override
  ConsumerState<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends ConsumerState<SkillsScreen> {
  Resume? _resume;
  AsyncValue<List<SkillSuggestion>>? _result;
  final Set<String> _added = {};

  Future<void> _suggest() async {
    final r = _resume;
    if (r == null) return;
    setState(() => _result = const AsyncLoading());
    final out = await ref.read(aiServiceProvider).suggestSkills(r);
    if (!mounted) return;
    setState(
      () => _result = out.when(ok: AsyncData.new, err: (f) => AsyncError(f, StackTrace.current)),
    );
  }

  Future<void> _add(SkillSuggestion s) async {
    final r = _resume;
    if (r == null) return;
    final updated = r.copyWith(skills: [...r.skills, s.skill]);
    final result = await ref.read(resumeRepositoryProvider).saveResume(updated);
    if (!mounted) return;
    if (result.isOk) {
      setState(() {
        _resume = result.valueOrNull;
        _added.add(s.skill);
      });
      showAppSnackBar(context, '"${s.skill}" added to ${r.title}');
    } else {
      showAppSnackBar(context, 'Could not add the skill.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSample = ref.watch(aiServiceProvider).isSample;
    return Scaffold(
      appBar: AppBar(title: const Text('Skill recommendations')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          ResumePicker(
            selectedId: _resume?.resumeId,
            onChanged: (r) => setState(() {
              _resume = r;
              _result = null;
              _added.clear();
            }),
          ),
          AppSpacing.gapLg,
          FilledButton.icon(
            key: const Key('suggest_skills_button'),
            onPressed: _resume == null || _result is AsyncLoading ? null : _suggest,
            icon: const Icon(Icons.psychology_alt_outlined),
            label: const Text('Suggest skills'),
          ),
          AppSpacing.gapLg,
          if (_result != null)
            _result!.when(
              loading: () => const AiLoadingView(message: 'Reading your experience…'),
              error: (e, _) => ErrorView(error: e, onRetry: _suggest),
              data: (list) => list.isEmpty
                  ? const EmptyView(
                      icon: Icons.check_circle_outline,
                      title: 'No new skills found',
                      message:
                          'Your skills already cover what your experience describes. '
                          'Add more detail to your experience to get more suggestions.',
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isSample)
                          const Align(alignment: Alignment.centerRight, child: SampleAiLabel()),
                        AppSpacing.gapSm,
                        for (final s in list)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: AppCard(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.skill,
                                          style: Theme.of(context).textTheme.titleSmall,
                                        ),
                                        Text(
                                          'Because you wrote: "${s.evidence}"',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  _added.contains(s.skill)
                                      ? const Icon(Icons.check_rounded)
                                      : TextButton(
                                          onPressed: () => _add(s),
                                          child: const Text('Add'),
                                        ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}
