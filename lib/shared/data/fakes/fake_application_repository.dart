import 'dart:async';

import '../../domain/domain.dart';
import '../sample/sample_jobs.dart';
import 'fake_stream.dart';

/// In-memory job applications. Each user starts with labeled sample entries.
class FakeApplicationRepository implements ApplicationRepository {
  FakeApplicationRepository({this.seedSamples = true, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final bool seedSamples;
  final DateTime Function() _clock;
  final Map<String, JobApplication> _apps = {};
  final Set<String> _seeded = {};
  final StreamController<void> _changes = StreamController.broadcast();
  int _nextId = 1;

  void _seed(String userId) {
    if (!seedSamples || !_seeded.add(userId)) return;
    for (final a in sampleApplications(userId, _clock())) {
      _apps[a.applicationId] = a;
    }
  }

  @override
  Stream<List<JobApplication>> watchApplications(String userId) {
    _seed(userId);
    return watchWithInitial(
      () =>
          _apps.values.where((a) => a.userId == userId).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      _changes.stream,
    );
  }

  @override
  Future<Result<JobApplication>> addApplication(JobApplication application) async {
    final exists = _apps.values.any(
      (a) => a.userId == application.userId && a.jobId == application.jobId,
    );
    if (exists) {
      return const Result.err(Failure.validation('This job is already in your tracker.'));
    }
    final id = application.applicationId.isEmpty ? 'app-${_nextId++}' : application.applicationId;
    final saved = JobApplication.fromMap({...application.toMap(), 'applicationId': id});
    _apps[id] = saved;
    _changes.add(null);
    return Result.ok(saved);
  }

  @override
  Future<Result<void>> updateApplication(JobApplication application) async {
    if (!_apps.containsKey(application.applicationId)) {
      return const Result.err(Failure.notFound());
    }
    _apps[application.applicationId] = application;
    _changes.add(null);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> deleteApplication(String applicationId) async {
    _apps.remove(applicationId);
    _changes.add(null);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> deleteAllForUser(String userId) async {
    _apps.removeWhere((_, a) => a.userId == userId);
    _changes.add(null);
    return const Result.ok(null);
  }
}
