import 'dart:async';

import '../../domain/domain.dart';
import '../sample/sample_resumes.dart';
import 'fake_stream.dart';

/// In-memory resumes. Each user starts with labeled sample resumes.
class FakeResumeRepository implements ResumeRepository {
  FakeResumeRepository({
    this.latency = const Duration(milliseconds: 250),
    this.seedSamples = true,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final Duration latency;
  final bool seedSamples;
  final DateTime Function() _clock;
  final Map<String, Resume> _resumes = {};
  final Set<String> _seededUsers = {};
  final StreamController<void> _changes = StreamController.broadcast();
  int _nextId = 1;

  void _seed(String userId) {
    if (!seedSamples || !_seededUsers.add(userId)) return;
    for (final r in sampleResumes(userId, _clock())) {
      _resumes[r.resumeId] = r;
    }
  }

  List<Resume> _forUser(String userId) {
    final list = _resumes.values.where((r) => r.userId == userId).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  void _notify() => _changes.add(null);

  @override
  Stream<List<Resume>> watchResumes(String userId) {
    _seed(userId);
    return watchWithInitial(() => _forUser(userId), _changes.stream);
  }

  @override
  Future<Result<Resume>> getResume(String resumeId) async {
    await fakeDelay(latency);
    final r = _resumes[resumeId];
    return r == null ? const Result.err(Failure.notFound()) : Result.ok(r);
  }

  @override
  Future<Result<Resume>> saveResume(Resume resume) async {
    await fakeDelay(latency);
    final id = resume.resumeId.isEmpty ? 'resume-${_nextId++}' : resume.resumeId;
    final saved = resume.copyWith(resumeId: id, updatedAt: _clock());
    _resumes[id] = saved;
    _notify();
    return Result.ok(saved);
  }

  @override
  Future<Result<Resume>> duplicateResume(String resumeId) async {
    await fakeDelay(latency);
    final r = _resumes[resumeId];
    if (r == null) return const Result.err(Failure.notFound());
    final now = _clock();
    final copy = r.copyWith(
      resumeId: 'resume-${_nextId++}',
      title: '${r.title} (copy)',
      createdAt: now,
      updatedAt: now,
    );
    _resumes[copy.resumeId] = copy;
    _notify();
    return Result.ok(copy);
  }

  @override
  Future<Result<void>> renameResume(String resumeId, String title) async {
    await fakeDelay(latency);
    final r = _resumes[resumeId];
    if (r == null) return const Result.err(Failure.notFound());
    _resumes[resumeId] = r.copyWith(title: title, updatedAt: _clock());
    _notify();
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> deleteResume(String resumeId) async {
    await fakeDelay(latency);
    _resumes.remove(resumeId);
    _notify();
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> deleteAllForUser(String userId) async {
    _resumes.removeWhere((_, r) => r.userId == userId);
    _notify();
    return const Result.ok(null);
  }
}
