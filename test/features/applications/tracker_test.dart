import 'package:flutter_test/flutter_test.dart';
import 'package:resumecraft/features/applications/presentation/application_providers.dart';
import 'package:resumecraft/features/applications/presentation/screens/tracker_screen.dart';
import 'package:resumecraft/shared/data/fakes/fake_application_repository.dart';
import 'package:resumecraft/shared/data/sample/sample_jobs.dart';
import 'package:resumecraft/shared/domain/domain.dart';

import '../../helpers/test_app.dart';

void main() {
  JobApplication app(String id, ApplicationStatus s, {DateTime? interview}) => JobApplication(
    applicationId: id,
    userId: 'u',
    jobId: 'job-$id',
    jobSnapshot: sampleJobs.first,
    status: s,
    interviewDate: interview,
    createdAt: DateTime(2026),
  );

  test('statistics count statuses and list upcoming events', () {
    final now = DateTime(2026, 11, 15);
    final stats = ApplicationStats.from([
      app('1', ApplicationStatus.interested),
      app('2', ApplicationStatus.applied),
      app('3', ApplicationStatus.interviewScheduled, interview: DateTime(2026, 11, 20)),
      app('4', ApplicationStatus.rejected, interview: DateTime(2026, 11, 21)),
    ], now);
    expect(stats.total, 4);
    expect(stats.active, 3);
    expect(stats.count(ApplicationStatus.applied), 1);
    expect(stats.upcoming, hasLength(1)); // closed applications are ignored
    expect(stats.interviewRate, 33);
  });

  test('repository adds, prevents duplicates, updates and deletes', () async {
    final repo = FakeApplicationRepository(seedSamples: false);
    final a = (await repo.addApplication(app('', ApplicationStatus.interested))).unwrap();
    expect(a.applicationId, isNotEmpty);
    final dup = await repo.addApplication(app('', ApplicationStatus.interested));
    expect(dup.isOk, isFalse);
    await repo.updateApplication(a.copyWith(status: ApplicationStatus.applied, notes: 'hi'));
    final list = await repo.watchApplications('u').first;
    expect(list.single.status, ApplicationStatus.applied);
    expect(list.single.notes, 'hi');
    await repo.deleteApplication(a.applicationId);
    expect(await repo.watchApplications('u').first, isEmpty);
  });

  testWidgets('tracker filters by status', (tester) async {
    final c = await pumpScreen(
      tester,
      const TrackerScreen(),
      overrides: [applicationRepositoryProvider.overrideWithValue(FakeApplicationRepository())],
    );
    await signInSample(c);
    await tester.pumpAndSettle();
    expect(find.text('Sample'), findsWidgets);
    await tester.tap(find.textContaining('Applied ('));
    await tester.pumpAndSettle();
    expect(find.text('Junior Flutter Developer'), findsOneWidget);
    expect(find.text('UI/UX Designer'), findsNothing);
  });
}
