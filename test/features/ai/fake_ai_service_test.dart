import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumecraft/features/ai/data/fake_ai_service.dart';
import 'package:resumecraft/features/ai/data/text_rules.dart';
import 'package:resumecraft/features/ai/domain/ai_models.dart';
import 'package:resumecraft/features/ai/presentation/widgets/ai_widgets.dart';
import 'package:resumecraft/shared/data/sample/sample_ai.dart';
import 'package:resumecraft/shared/data/sample/sample_resumes.dart';
import 'package:resumecraft/shared/domain/domain.dart';

void main() {
  final ai = FakeAiService(latency: Duration.zero);
  final resume = sampleResumes('u', DateTime(2026)).first;

  group('text rules', () {
    test('rewrite strengthens weak starts without adding facts', () {
      final out = TextRules.rewrite('i worked on the app and helped the team');
      expect(out, startsWith('Contributed to the app'));
      expect(out.toLowerCase(), isNot(contains('%')));
    });

    test('grammar fixes spelling, "i" and capitalization', () {
      final out = TextRules.fixGrammar('i recieved teh  award for managment');
      expect(out, 'I received the award for management');
    });
  });

  group('FakeAiService', () {
    test('is labeled as sample', () => expect(ai.isSample, isTrue));

    test('analysis scores out of 100 with recommendations', () async {
      final a = (await ai.analyzeResume(resume)).unwrap();
      expect(a.score, inInclusiveRange(0, 100));
      expect(a.sectionScores.keys, containsAll(['Experience', 'Skills']));
      final empty = Resume(
        resumeId: 'e',
        userId: 'u',
        title: 'Empty',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      final low = (await ai.analyzeResume(empty)).unwrap();
      expect(low.score, lessThan(a.score));
      expect(low.recommendations, isNotEmpty);
    });

    test('skill suggestions come with evidence from the resume', () async {
      final skills = (await ai.suggestSkills(resume)).unwrap();
      for (final s in skills) {
        expect(resume.plainText.toLowerCase(), contains(s.evidence.toLowerCase().split(' ').first));
        expect(resume.skills.map((x) => x.toLowerCase()), isNot(contains(s.skill.toLowerCase())));
      }
    });

    test('generated descriptions leave a marked gap instead of inventing numbers', () async {
      final s = (await ai.generateDescription(
        role: 'Assistant',
        company: 'Shop',
        notes: 'answered customer emails',
      )).unwrap();
      expect(s.suggestion, contains('['));
      expect(RegExp(r'\d').hasMatch(s.suggestion), isFalse);
    });

    test('voice transcript is organized and asks for confirmation', () async {
      final d = (await ai.structureVoiceTranscript(sampleTranscript)).unwrap();
      expect(d.experience, hasLength(1));
      expect(d.experience.first.description.toLowerCase(), contains('social media'));
      expect(d.education, hasLength(1));
      expect(d.skills, contains('Canva'));
      expect(d.needsConfirmation, isNotEmpty);
      // Never adds content that was not said.
      expect(d.experience.first.description.toLowerCase(), isNot(contains('campaign')));
    });

    test('interview questions mix types and use the resume', () async {
      final qs = (await ai.generateInterviewQuestions(
        jobTitle: 'Designer',
        category: InterviewCategory.design,
        resume: resume,
        count: 5,
      )).unwrap();
      expect(qs, hasLength(5));
      expect(qs.map((q) => q.type).toSet(), hasLength(3));
      expect(qs.any((q) => q.text.contains('Northwind Studio')), isTrue);
    });

    test('answer scoring rewards detail and penalizes hedging', () async {
      const q = InterviewQuestion(
        id: 'q',
        text: 'Describe a tight deadline.',
        type: InterviewQuestionType.behavioral,
      );
      final weak = (await ai.evaluateAnswer(
        question: q,
        answer: 'Maybe I think it was ok.',
        jobTitle: 'Dev',
      )).unwrap();
      final strong = (await ai.evaluateAnswer(
        question: q,
        answer:
            'During my internship we had a tight deadline for a client demo. '
            'I organized the remaining tasks, I built the login screen and tested it daily. '
            'As a result we delivered two days early and the client approved the next phase.',
        jobTitle: 'Dev',
      )).unwrap();
      expect(strong.score, greaterThan(weak.score));
      expect(weak.confidence, lessThan(strong.confidence));
      expect(weak.strongerAnswer, contains('['));
    });
  });

  group('SuggestionCard', () {
    testWidgets('accept, edit and reject', (tester) async {
      String? accepted;
      var rejected = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SuggestionCard(
                suggestion: const TextSuggestion(original: 'old', suggestion: 'New text'),
                onAccept: (t) => accepted = t,
                onReject: () => rejected = true,
              ),
            ),
          ),
        ),
      );
      expect(find.text('Sample AI result'), findsOneWidget);
      await tester.tap(find.byKey(const Key('suggestion_edit')));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('suggestion_edit_field')), 'Edited text');
      await tester.tap(find.byKey(const Key('suggestion_accept')));
      expect(accepted, 'Edited text');
      await tester.tap(find.byKey(const Key('suggestion_reject')));
      expect(rejected, isTrue);
    });
  });
}
