import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../shared/data/fakes/fake_interview_repository.dart';
import '../../../shared/domain/domain.dart';
import '../../ai/domain/ai_models.dart';
import '../../ai/presentation/ai_providers.dart';
import '../../auth/presentation/auth_providers.dart';

final interviewRepositoryProvider = Provider<InterviewRepository>(
  (ref) => FakeInterviewRepository(),
);

final interviewSessionsProvider = StreamProvider<List<InterviewSession>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(interviewRepositoryProvider).watchSessions(uid);
});

enum InterviewStage { answering, evaluating, feedback, summarizing, done }

class InterviewState {
  const InterviewState({
    required this.session,
    required this.index,
    required this.stage,
    this.resume,
    this.error,
  });

  final InterviewSession session;
  final int index;
  final InterviewStage stage;
  final Resume? resume;
  final String? error;

  InterviewQuestion get question => session.questions[index];
  bool get isLast => index >= session.questions.length - 1;
  AnswerEvaluation? get currentEvaluation =>
      session.answers.where((a) => a.questionId == question.id).firstOrNull?.evaluation;

  InterviewState copyWith({
    InterviewSession? session,
    int? index,
    InterviewStage? stage,
    String? error,
  }) => InterviewState(
    session: session ?? this.session,
    index: index ?? this.index,
    stage: stage ?? this.stage,
    resume: resume,
    error: error,
  );
}

/// Runs one practice interview: questions, answers, feedback and report.
class InterviewController extends Notifier<InterviewState?> {
  @override
  InterviewState? build() => null;

  /// Generates questions and starts a session. Returns an error message or null.
  Future<String?> start({
    required String jobTitle,
    required InterviewCategory category,
    Resume? resume,
    int count = 5,
  }) async {
    final result = await ref
        .read(aiServiceProvider)
        .generateInterviewQuestions(
          jobTitle: jobTitle,
          category: category,
          resume: resume,
          count: count,
        );
    return result.when(
      ok: (questions) {
        state = InterviewState(
          session: InterviewSession(
            sessionId: ref.read(uuidProvider).v4(),
            userId: ref.read(currentUserIdProvider) ?? '',
            jobTitle: jobTitle,
            category: category.label,
            questions: questions,
            createdAt: DateTime.now(),
          ),
          index: 0,
          stage: InterviewStage.answering,
          resume: resume,
        );
        return null;
      },
      err: (f) => f.message,
    );
  }

  Future<void> submitAnswer(String text) async {
    final s = state;
    if (s == null) return;
    state = s.copyWith(stage: InterviewStage.evaluating);
    final result = await ref
        .read(aiServiceProvider)
        .evaluateAnswer(
          question: s.question,
          answer: text,
          jobTitle: s.session.jobTitle,
          resume: s.resume,
        );
    final current = state;
    if (current == null) return;
    state = result.when(
      ok: (eval) => current.copyWith(
        stage: InterviewStage.feedback,
        session: current.session.copyWith(
          answers: [
            ...current.session.answers.where((a) => a.questionId != s.question.id),
            InterviewAnswer(questionId: s.question.id, text: text, evaluation: eval),
          ],
        ),
      ),
      err: (f) => current.copyWith(stage: InterviewStage.answering, error: f.message),
    );
  }

  Future<void> next() async {
    final s = state;
    if (s == null) return;
    if (!s.isLast) {
      state = s.copyWith(index: s.index + 1, stage: InterviewStage.answering);
      return;
    }
    await finish();
  }

  Future<void> finish() async {
    final s = state;
    if (s == null) return;
    state = s.copyWith(stage: InterviewStage.summarizing);
    final report = await ref.read(aiServiceProvider).summarizeInterview(s.session);
    final evals = s.session.answers.map((a) => a.evaluation).whereType<AnswerEvaluation>();
    final overall = evals.isEmpty ? 0 : evals.fold<int>(0, (n, e) => n + e.score) ~/ evals.length;
    final done = s.session.copyWith(
      evaluation:
          report.valueOrNull ??
          const InterviewReport(summary: 'The report could not be generated.'),
      overallScore: overall,
    );
    await ref.read(interviewRepositoryProvider).saveSession(done);
    state = s.copyWith(session: done, stage: InterviewStage.done);
  }

  void reset() => state = null;
}

final interviewControllerProvider = NotifierProvider<InterviewController, InterviewState?>(
  InterviewController.new,
);
