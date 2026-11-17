import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/labels.dart';
import '../../../../core/widgets/phase_label.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../ai/presentation/ai_providers.dart';
import '../../../ai/presentation/widgets/ai_widgets.dart';
import '../interview_providers.dart';
import '../widgets/answer_feedback.dart';

/// One question at a time: answer, get feedback, move on.
class InterviewSessionScreen extends ConsumerStatefulWidget {
  const InterviewSessionScreen({super.key});

  @override
  ConsumerState<InterviewSessionScreen> createState() => _InterviewSessionScreenState();
}

class _InterviewSessionScreenState extends ConsumerState<InterviewSessionScreen> {
  final _answer = TextEditingController();

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_answer.text.trim().isEmpty) {
      showAppSnackBar(context, 'Type your answer first.');
      return;
    }
    await ref.read(interviewControllerProvider.notifier).submitAnswer(_answer.text.trim());
  }

  Future<void> _next() async {
    _answer.clear();
    await ref.read(interviewControllerProvider.notifier).next();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(interviewControllerProvider);
    final isSample = ref.watch(aiServiceProvider).isSample;
    ref.listen(interviewControllerProvider, (prev, next) {
      if (next?.stage == InterviewStage.done && prev?.stage != InterviewStage.done) {
        context.pushReplacement('${Routes.interviewReport}?id=${next!.session.sessionId}');
      }
      if (next?.error != null && next?.error != prev?.error) {
        showAppSnackBar(context, next!.error!, error: true);
      }
    });
    if (state == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Interview')),
        body: EmptyView(
          icon: Icons.record_voice_over_outlined,
          title: 'No interview in progress',
          action: FilledButton(
            onPressed: () => context.go(Routes.interview),
            child: const Text('Set up an interview'),
          ),
        ),
      );
    }
    final q = state.question;
    final total = state.session.questions.length;
    final busy =
        state.stage == InterviewStage.evaluating || state.stage == InterviewStage.summarizing;
    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${state.index + 1} of $total'),
        actions: [
          TextButton(
            onPressed: busy ? null : () => ref.read(interviewControllerProvider.notifier).finish(),
            child: const Text('End'),
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          LinearProgressIndicator(value: (state.index + 1) / total),
          AppSpacing.gapLg,
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  children: [
                    Pill(text: q.type.label, color: Theme.of(context).colorScheme.secondary),
                    if (q.isFollowUp)
                      Pill(text: 'Follow-up', color: Theme.of(context).colorScheme.tertiary),
                    if (isSample) const SampleAiLabel(),
                  ],
                ),
                AppSpacing.gapMd,
                Text(
                  q.text,
                  key: const Key('interview_question'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          AppSpacing.gapLg,
          if (state.stage == InterviewStage.answering) ...[
            TextField(
              key: const Key('interview_answer'),
              controller: _answer,
              maxLines: 8,
              minLines: 5,
              decoration: const InputDecoration(labelText: 'Your answer'),
            ),
            AppSpacing.gapSm,
            const Row(
              children: [
                Icon(Icons.mic_none_rounded, size: 18),
                SizedBox(width: 6),
                Expanded(child: Text('Answer by voice')),
                PhaseLabel(3),
              ],
            ),
            AppSpacing.gapLg,
            PrimaryButton(
              key: const Key('submit_answer'),
              label: 'Submit answer',
              onPressed: _submit,
            ),
          ],
          if (state.stage == InterviewStage.evaluating)
            const AiLoadingView(message: 'Evaluating your answer…'),
          if (state.stage == InterviewStage.summarizing)
            const AiLoadingView(message: 'Preparing your report…'),
          if (state.stage == InterviewStage.feedback && state.currentEvaluation != null) ...[
            AnswerFeedback(evaluation: state.currentEvaluation!, isSample: isSample),
            AppSpacing.gapLg,
            PrimaryButton(
              key: const Key('next_question'),
              label: state.isLast ? 'Finish and see report' : 'Next question',
              onPressed: _next,
            ),
          ],
        ],
      ),
    );
  }
}
