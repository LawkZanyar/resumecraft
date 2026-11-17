import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumecraft/features/ai/data/fake_ai_service.dart';
import 'package:resumecraft/features/ai/domain/ai_models.dart';
import 'package:resumecraft/features/ai/presentation/ai_providers.dart';
import 'package:resumecraft/features/interview/presentation/interview_providers.dart';
import 'package:resumecraft/features/interview/presentation/screens/interview_session_screen.dart';
import 'package:resumecraft/shared/data/fakes/fake_interview_repository.dart';

import '../../helpers/test_app.dart';

void main() {
  final overrides = [
    aiServiceProvider.overrideWithValue(FakeAiService(latency: Duration.zero)),
    interviewRepositoryProvider.overrideWithValue(FakeInterviewRepository()),
  ];

  test('controller runs a full session and saves it', () async {
    final base = await baseOverrides();
    final c = ProviderContainer(overrides: [...base, ...overrides]);
    addTearDown(c.dispose);
    await signInSample(c);
    final ctrl = c.read(interviewControllerProvider.notifier);
    expect(
      await ctrl.start(jobTitle: 'Designer', category: InterviewCategory.design, count: 3),
      isNull,
    );
    for (var i = 0; i < 3; i++) {
      await ctrl.submitAnswer(
        'During my last project I designed a screen and tested it with users.',
      );
      expect(c.read(interviewControllerProvider)!.stage, InterviewStage.feedback);
      await ctrl.next();
    }
    final s = c.read(interviewControllerProvider)!;
    expect(s.stage, InterviewStage.done);
    expect(s.session.overallScore, isNotNull);
    expect(s.session.evaluation, isNotNull);
    final saved = await c.read(interviewRepositoryProvider).watchSessions(s.session.userId).first;
    expect(saved.single.sessionId, s.session.sessionId);
  });

  testWidgets('session screen shows question, then feedback after answering', (tester) async {
    final c = await pumpScreen(tester, const InterviewSessionScreen(), overrides: overrides);
    await c
        .read(interviewControllerProvider.notifier)
        .start(jobTitle: 'Developer', category: InterviewCategory.software, count: 3);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('interview_question')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('interview_answer')),
      'I built a small app and tested it.',
    );
    await tester.tap(find.byKey(const Key('submit_answer')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('answer_score')), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('next_question')), 300);
    expect(find.byKey(const Key('next_question')), findsOneWidget);
  });
}
