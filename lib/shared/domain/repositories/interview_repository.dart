import '../../../core/errors/result.dart';
import '../entities/interview_session.dart';

abstract interface class InterviewRepository {
  Stream<List<InterviewSession>> watchSessions(String userId);

  Future<Result<void>> saveSession(InterviewSession session);

  Future<Result<void>> deleteSession(String sessionId);

  Future<Result<void>> deleteAllForUser(String userId);
}
