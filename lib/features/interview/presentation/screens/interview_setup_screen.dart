import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/labels.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/domain/domain.dart';
import '../../../ai/domain/ai_models.dart';
import '../../../ai_assistant/presentation/widgets/resume_picker.dart';
import '../interview_providers.dart';

/// Choose a position and category, then start a practice interview.
class InterviewSetupScreen extends ConsumerStatefulWidget {
  const InterviewSetupScreen({super.key});

  @override
  ConsumerState<InterviewSetupScreen> createState() => _InterviewSetupScreenState();
}

class _InterviewSetupScreenState extends ConsumerState<InterviewSetupScreen> {
  final _form = GlobalKey<FormState>();
  final _jobTitle = TextEditingController();
  InterviewCategory _category = InterviewCategory.general;
  Resume? _resume;
  int _count = 5;
  bool _starting = false;

  @override
  void dispose() {
    _jobTitle.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _starting = true);
    final error = await ref
        .read(interviewControllerProvider.notifier)
        .start(
          jobTitle: _jobTitle.text.trim(),
          category: _category,
          resume: _resume,
          count: _count,
        );
    if (!mounted) return;
    setState(() => _starting = false);
    if (error != null) {
      showAppSnackBar(context, error, error: true);
    } else {
      await context.push(Routes.interviewSession);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(interviewSessionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Interview simulator')),
      body: Form(
        key: _form,
        child: ListView(
          padding: AppSpacing.page,
          children: [
            TextFormField(
              key: const Key('interview_job_title'),
              controller: _jobTitle,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Position',
                hintText: 'For example: Junior Flutter Developer',
              ),
              validator: (v) => Validators.required(v, field: 'Position'),
            ),
            const SectionHeader('Category'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in InterviewCategory.values)
                  ChoiceChip(
                    label: Text(c.label),
                    selected: c == _category,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SectionHeader('Base questions on'),
            ResumePicker(
              selectedId: _resume?.resumeId,
              allowNone: true,
              label: 'Resume (optional)',
              onChanged: (r) => setState(() => _resume = r),
            ),
            const SectionHeader('Number of questions'),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 3, label: Text('3')),
                ButtonSegment(value: 5, label: Text('5')),
                ButtonSegment(value: 7, label: Text('7')),
              ],
              selected: {_count},
              onSelectionChanged: (s) => setState(() => _count = s.first),
            ),
            AppSpacing.gapXl,
            PrimaryButton(
              key: const Key('start_interview'),
              label: 'Start interview',
              icon: Icons.play_arrow_rounded,
              loading: _starting,
              onPressed: _start,
            ),
            const SectionHeader('Past sessions'),
            sessions.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => ErrorView(error: e),
              data: (list) => list.isEmpty
                  ? Text('No sessions yet.', style: Theme.of(context).textTheme.bodySmall)
                  : Column(
                      children: [
                        for (final s in list)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: AppCard(
                              padding: EdgeInsets.zero,
                              onTap: () =>
                                  context.push('${Routes.interviewReport}?id=${s.sessionId}'),
                              child: ListTile(
                                title: Text(s.jobTitle),
                                subtitle: Text('${s.category} · ${Formatters.date(s.createdAt)}'),
                                trailing: s.overallScore == null
                                    ? null
                                    : Pill(
                                        text: '${s.overallScore}',
                                        color: AppColors.scoreColor(s.overallScore!),
                                      ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
