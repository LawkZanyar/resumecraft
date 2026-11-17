import 'dart:async';

import '../../../features/jobs/domain/geo.dart';
import '../../domain/domain.dart';
import '../sample/sample_jobs.dart';
import 'fake_stream.dart';

/// Searches the labeled sample job database in memory.
class FakeJobRepository implements JobRepository {
  FakeJobRepository({this.latency = const Duration(milliseconds: 350), List<Job>? jobs})
    : _jobs = jobs ?? sampleJobs;

  final Duration latency;
  final List<Job> _jobs;
  final Map<String, Map<String, Job>> _saved = {};
  final StreamController<void> _changes = StreamController.broadcast();

  /// Shared matching rules, also used by other repositories' sample fallback.
  static List<Job> filter(List<Job> jobs, JobQuery q) {
    final words = q.keywords.toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final loc = q.location.trim().toLowerCase();
    final list = jobs.where((j) {
      final hay = '${j.title} ${j.company} ${j.description} ${j.requirements.join(' ')}'
          .toLowerCase();
      if (!words.every(hay.contains)) return false;
      if (loc.isNotEmpty && !j.location.toLowerCase().contains(loc)) return false;
      if (q.category.isNotEmpty && j.category != q.category) return false;
      if (q.hasCenter && q.radiusKm != null) {
        if (!j.hasPosition) return false;
        final d = distanceKm(q.latitude!, q.longitude!, j.latitude!, j.longitude!);
        if (d > q.radiusKm!) return false;
      }
      return true;
    }).toList();
    list.sort((a, b) => (b.postedAt ?? DateTime(0)).compareTo(a.postedAt ?? DateTime(0)));
    return list;
  }

  @override
  Future<Result<JobSearchPage>> searchJobs(JobQuery query) async {
    await fakeDelay(latency);
    final all = filter(_jobs, query);
    final start = (query.page - 1) * query.pageSize;
    final page = all.skip(start).take(query.pageSize).toList();
    return Result.ok(
      JobSearchPage(
        jobs: page,
        page: query.page,
        hasMore: start + page.length < all.length,
        source: JobSource.sample,
        totalCount: all.length,
        notice: 'Showing the sample job database. Companies are fictional.',
      ),
    );
  }

  @override
  Future<Result<Job>> getJob(String jobId) async {
    final saved = _saved.values.expand((m) => m.values).where((j) => j.jobId == jobId);
    final job = _jobs.where((j) => j.jobId == jobId).firstOrNull ?? saved.firstOrNull;
    return job == null
        ? const Result.err(Failure.notFound('This job is no longer available.'))
        : Result.ok(job);
  }

  @override
  Stream<List<Job>> watchSavedJobs(String userId) =>
      watchWithInitial(() => (_saved[userId] ?? {}).values.toList(), _changes.stream);

  @override
  Future<Result<void>> saveJob(String userId, Job job) async {
    (_saved[userId] ??= {})[job.jobId] = job;
    _changes.add(null);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> removeSavedJob(String userId, String jobId) async {
    _saved[userId]?.remove(jobId);
    _changes.add(null);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> deleteAllForUser(String userId) async {
    _saved.remove(userId);
    _changes.add(null);
    return const Result.ok(null);
  }
}
