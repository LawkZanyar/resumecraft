import 'dart:async';

import '../../domain/domain.dart';
import 'fake_stream.dart';

/// In-memory interview sessions.
class FakeInterviewRepository implements InterviewRepository {
  final Map<String, InterviewSession> _sessions = {};
  final StreamController<void> _changes = StreamController.broadcast();

  @override
  Stream<List<InterviewSession>> watchSessions(String userId) => watchWithInitial(
    () =>
        _sessions.values.where((s) => s.userId == userId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    _changes.stream,
  );

  @override
  Future<Result<void>> saveSession(InterviewSession session) async {
    _sessions[session.sessionId] = session;
    _changes.add(null);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> deleteSession(String sessionId) async {
    _sessions.remove(sessionId);
    _changes.add(null);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> deleteAllForUser(String userId) async {
    _sessions.removeWhere((_, s) => s.userId == userId);
    _changes.add(null);
    return const Result.ok(null);
  }
}
