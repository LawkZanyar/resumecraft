import 'package:flutter_test/flutter_test.dart';
import 'package:resumecraft/core/utils/formatters.dart';
import 'package:resumecraft/shared/domain/domain.dart';

void main() {
  test('Result.ok and Result.err expose values', () {
    const ok = Result<int>.ok(3);
    const err = Result<int>.err(Failure.network());
    expect(ok.isOk, isTrue);
    expect(ok.valueOrNull, 3);
    expect(err.failureOrNull?.kind, FailureKind.network);
    expect(ok.map((v) => v * 2).valueOrNull, 6);
    expect(() => err.unwrap(), throwsA(isA<Failure>()));
  });

  test('guard converts exceptions into failures', () async {
    final r = await guard<int>(() async => throw StateError('x'));
    expect(r.failureOrNull?.kind, FailureKind.unknown);
    final f = await guard<int>(() async => throw const Failure.timeout());
    expect(f.failureOrNull?.kind, FailureKind.timeout);
  });

  test('initials and relative dates', () {
    expect(Formatters.initials('Sara Ahmed'), 'SA');
    expect(Formatters.initials(''), '?');
    final now = DateTime(2026, 1, 10, 12);
    expect(Formatters.relative(now.subtract(const Duration(days: 2)), now: now), '2 days ago');
    expect(Formatters.relative(now.add(const Duration(hours: 3)), now: now), 'in 3 h');
  });

  test('Resume survives a map round trip', () {
    final r = Resume(
      resumeId: 'r1',
      userId: 'u1',
      title: 'Designer',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026, 2),
      personalInformation: const PersonalInfo(fullName: 'Sara'),
      experience: const [Experience(id: 'e1', company: 'Acme', role: 'Designer')],
      skills: const ['Figma'],
      customization: const ResumeCustomization(
        hiddenSections: {ResumeSection.projects},
      ),
      aiScore: 72,
    );
    final back = Resume.fromMap(r.toMap());
    expect(back.title, 'Designer');
    expect(back.experience.single.company, 'Acme');
    expect(back.skills, ['Figma']);
    expect(back.aiScore, 72);
    expect(back.customization.hiddenSections, {ResumeSection.projects});
    expect(back.customization.sectionOrder.length, ResumeSection.values.length);
    expect(back.updatedAt.toUtc(), DateTime.utc(2026, 2));
  });

  test('JobApplication survives a map round trip', () {
    final a = JobApplication(
      applicationId: 'a1',
      userId: 'u1',
      jobId: 'j1',
      jobSnapshot: const Job(
        jobId: 'j1',
        title: 'Dev',
        company: 'Co',
        location: 'Erbil',
        source: JobSource.sample,
        isSample: true,
      ),
      status: ApplicationStatus.interviewScheduled,
      createdAt: DateTime.utc(2026),
    );
    final back = JobApplication.fromMap(a.toMap());
    expect(back.status, ApplicationStatus.interviewScheduled);
    expect(back.jobSnapshot.isSample, isTrue);
  });
}
