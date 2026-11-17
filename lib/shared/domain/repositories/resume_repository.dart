import '../../../core/errors/result.dart';
import '../entities/resume.dart';

/// Stores the user's resumes. Implementations: fake (Phase 1), Firestore.
abstract interface class ResumeRepository {
  /// All resumes of [userId], most recently updated first.
  Stream<List<Resume>> watchResumes(String userId);

  Future<Result<Resume>> getResume(String resumeId);

  /// Creates or replaces the resume and returns it with a fresh `updatedAt`.
  Future<Result<Resume>> saveResume(Resume resume);

  Future<Result<Resume>> duplicateResume(String resumeId);

  Future<Result<void>> renameResume(String resumeId, String title);

  Future<Result<void>> deleteResume(String resumeId);

  /// Used by account deletion.
  Future<Result<void>> deleteAllForUser(String userId);
}
