import '../../../core/errors/result.dart';
import '../entities/job_application.dart';

abstract interface class ApplicationRepository {
  Stream<List<JobApplication>> watchApplications(String userId);

  Future<Result<JobApplication>> addApplication(JobApplication application);

  Future<Result<void>> updateApplication(JobApplication application);

  Future<Result<void>> deleteApplication(String applicationId);

  Future<Result<void>> deleteAllForUser(String userId);
}
