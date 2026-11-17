import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumecraft/features/jobs/domain/geo.dart';
import 'package:resumecraft/features/jobs/presentation/jobs_providers.dart';
import 'package:resumecraft/features/jobs/presentation/screens/job_search_screen.dart';
import 'package:resumecraft/shared/data/fakes/fake_job_repository.dart';
import 'package:resumecraft/shared/data/sample/sample_jobs.dart';
import 'package:resumecraft/shared/domain/domain.dart';

import '../../helpers/test_app.dart';

void main() {
  final repo = FakeJobRepository(latency: Duration.zero);

  test('sample jobs are all labeled and fictional', () {
    expect(sampleJobs.length, inInclusiveRange(15, 20));
    for (final j in sampleJobs) {
      expect(j.isSample, isTrue);
      expect(j.source, JobSource.sample);
      expect(j.company, contains('(Sample)'));
      expect(j.applicationUrl, startsWith('https://example.com/'));
      expect(j.hasPosition, isTrue);
    }
  });

  test('distance helper is roughly right', () {
    // Erbil to Sulaymaniyah is about 150 km in a straight line.
    final d = distanceKm(36.1911, 44.0092, 35.5613, 45.4373);
    expect(d, inInclusiveRange(130, 170));
  });

  test('search filters by keyword, location, category and radius', () async {
    final flutter = (await repo.searchJobs(const JobQuery(keywords: 'flutter'))).unwrap();
    expect(
      flutter.jobs.every((j) => '${j.title} ${j.requirements}'.toLowerCase().contains('flutter')),
      isTrue,
    );

    final duhok = (await repo.searchJobs(const JobQuery(location: 'duhok'))).unwrap();
    expect(duhok.jobs, isNotEmpty);
    expect(duhok.jobs.every((j) => j.location.contains('Duhok')), isTrue);

    final design = (await repo.searchJobs(const JobQuery(category: 'Design'))).unwrap();
    expect(design.jobs.every((j) => j.category == 'Design'), isTrue);

    final near = (await repo.searchJobs(
      JobQuery(latitude: sampleCenter.latitude, longitude: sampleCenter.longitude, radiusKm: 20),
    )).unwrap();
    expect(near.jobs.every((j) => j.location.startsWith('Erbil')), isTrue);
  });

  test('pagination returns pages and hasMore', () async {
    final p1 = (await repo.searchJobs(const JobQuery(pageSize: 5))).unwrap();
    expect(p1.jobs, hasLength(5));
    expect(p1.hasMore, isTrue);
    final last = (await repo.searchJobs(const JobQuery(pageSize: 5, page: 4))).unwrap();
    expect(last.hasMore, isFalse);
  });

  test('saved jobs per user', () async {
    await repo.saveJob('u1', sampleJobs.first);
    expect(await repo.watchSavedJobs('u1').first, hasLength(1));
    expect(await repo.watchSavedJobs('u2').first, isEmpty);
    await repo.removeSavedJob('u1', sampleJobs.first.jobId);
    expect(await repo.watchSavedJobs('u1').first, isEmpty);
  });

  testWidgets('search screen shows results with Sample labels', (tester) async {
    await pumpScreen(
      tester,
      const JobSearchScreen(),
      overrides: [
        jobRepositoryProvider.overrideWithValue(FakeJobRepository(latency: Duration.zero)),
      ],
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('job_keywords')), 'designer');
    await tester.tap(find.byKey(const Key('job_search_button')));
    await tester.pumpAndSettle();
    expect(find.textContaining('results'), findsOneWidget);
    expect(find.text('Sample'), findsWidgets);
  });
}
