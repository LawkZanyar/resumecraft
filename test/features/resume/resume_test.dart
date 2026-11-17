import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumecraft/features/resume/presentation/resume_providers.dart';
import 'package:resumecraft/features/resume/presentation/screens/resume_editor_screen.dart';
import 'package:resumecraft/features/resume/presentation/screens/resume_list_screen.dart';
import 'package:resumecraft/features/resume/presentation/templates/resume_document.dart';
import 'package:resumecraft/shared/data/fakes/fake_resume_repository.dart';
import 'package:resumecraft/shared/data/sample/sample_resumes.dart';
import 'package:resumecraft/shared/domain/domain.dart';

import '../../helpers/test_app.dart';

void main() {
  group('FakeResumeRepository', () {
    test('seeds labeled samples and supports create, rename, duplicate, delete', () async {
      final repo = FakeResumeRepository(latency: Duration.zero);
      final first = await repo.watchResumes('u1').first;
      expect(first, isNotEmpty);
      expect(first.every((r) => r.isSample), isTrue);

      final now = DateTime.now();
      final created = (await repo.saveResume(
        Resume(resumeId: '', userId: 'u1', title: 'Mine', createdAt: now, updatedAt: now),
      ))
          .unwrap();
      expect(created.resumeId, isNotEmpty);

      await repo.renameResume(created.resumeId, 'Renamed');
      expect((await repo.getResume(created.resumeId)).unwrap().title, 'Renamed');

      final copy = (await repo.duplicateResume(created.resumeId)).unwrap();
      expect(copy.title, 'Renamed (copy)');

      await repo.deleteResume(created.resumeId);
      expect((await repo.getResume(created.resumeId)).isOk, isFalse);

      await repo.deleteAllForUser('u1');
      expect(await repo.watchResumes('u1').first, isEmpty);
    });

    test('users only see their own resumes', () async {
      final repo = FakeResumeRepository(latency: Duration.zero);
      final a = await repo.watchResumes('a').first;
      final b = await repo.watchResumes('b').first;
      expect(a.every((r) => r.userId == 'a'), isTrue);
      expect(b.every((r) => r.userId == 'b'), isTrue);
    });
  });

  group('screens', () {
    final overrides = [
      resumeRepositoryProvider.overrideWithValue(FakeResumeRepository(latency: Duration.zero)),
    ];

    testWidgets('list shows sample resumes with a Sample label', (tester) async {
      final c = await pumpScreen(tester, const ResumeListScreen(), overrides: overrides);
      await signInSample(c);
      await tester.pumpAndSettle();
      expect(find.text('Product Designer (Sample)'), findsOneWidget);
      expect(find.text('Sample'), findsWidgets);
    });

    testWidgets('editor blocks Next until required fields are filled', (tester) async {
      await pumpScreen(tester, const ResumeEditorScreen(), overrides: overrides);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('field_title')).last, '');
      await tester.tap(find.byKey(const Key('editor_next')));
      await tester.pumpAndSettle();
      expect(find.text('Title is required'), findsOneWidget);
      expect(find.text('Name is required'), findsOneWidget);

      await tester.enterText(
        find.descendant(of: find.byKey(const Key('field_title')), matching: find.byType(TextFormField)),
        'My resume',
      );
      await tester.enterText(
        find.descendant(of: find.byKey(const Key('field_full_name')), matching: find.byType(TextFormField)),
        'Test User',
      );
      await tester.tap(find.byKey(const Key('editor_next')));
      await tester.pumpAndSettle();
      expect(find.text('Add experience'), findsOneWidget);
    });
  });

  group('templates', () {
    final resume = sampleResumes('u', DateTime(2026)).first;

    for (final id in ['classic', 'modern', 'minimal']) {
      testWidgets('$id template renders the resume content', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SingleChildScrollView(
              child: ResumeDocument(resume: resume.copyWith(templateId: id)),
            ),
          ),
        );
        expect(find.text('Sara Ahmed'), findsOneWidget);
        expect(find.textContaining('Northwind Studio'), findsOneWidget);
      });
    }

    testWidgets('hidden sections are not rendered', (tester) async {
      final hidden = resume.copyWith(
        customization: resume.customization.copyWith(hiddenSections: {ResumeSection.experience}),
      );
      await tester.pumpWidget(
        MaterialApp(home: SingleChildScrollView(child: ResumeDocument(resume: hidden))),
      );
      expect(find.textContaining('Northwind Studio'), findsNothing);
      expect(find.text('SKILLS'), findsOneWidget);
    });

    testWidgets('sidebar layout still shows every visible section', (tester) async {
      final side = resume.copyWith(
        customization: resume.customization.copyWith(layout: ResumeLayout.sidebar),
      );
      await tester.pumpWidget(
        MaterialApp(home: SingleChildScrollView(child: ResumeDocument(resume: side))),
      );
      expect(find.textContaining('Figma'), findsOneWidget);
      expect(find.textContaining('Kurdish'), findsOneWidget);
    });
  });
}
