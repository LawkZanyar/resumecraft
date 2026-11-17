import '../../../core/errors/result.dart';
import '../entities/job.dart';

/// Search filters. Any field may be empty.
class JobQuery {
  const JobQuery({
    this.keywords = '',
    this.location = '',
    this.category = '',
    this.radiusKm,
    this.latitude,
    this.longitude,
    this.page = 1,
    this.pageSize = 20,
  });

  final String keywords;
  final String location;
  final String category;
  final double? radiusKm;

  /// Center for radius searches (user position or a searched place).
  final double? latitude;
  final double? longitude;
  final int page;
  final int pageSize;

  bool get hasCenter => latitude != null && longitude != null;

  JobQuery copyWith({
    String? keywords,
    String? location,
    String? category,
    double? radiusKm,
    double? latitude,
    double? longitude,
    int? page,
    bool clearCenter = false,
    bool clearRadius = false,
  }) =>
      JobQuery(
        keywords: keywords ?? this.keywords,
        location: location ?? this.location,
        category: category ?? this.category,
        radiusKm: clearRadius ? null : radiusKm ?? this.radiusKm,
        latitude: clearCenter ? null : latitude ?? this.latitude,
        longitude: clearCenter ? null : longitude ?? this.longitude,
        page: page ?? this.page,
        pageSize: pageSize,
      );
}

/// One page of results and where they came from.
class JobSearchPage {
  const JobSearchPage({
    required this.jobs,
    required this.page,
    required this.hasMore,
    required this.source,
    this.notice,
    this.totalCount,
  });

  final List<Job> jobs;
  final int page;
  final bool hasMore;
  final JobSource source;

  /// Explains a fallback, for example "Live listings are unavailable".
  final String? notice;
  final int? totalCount;
}

abstract interface class JobRepository {
  Future<Result<JobSearchPage>> searchJobs(JobQuery query);

  Future<Result<Job>> getJob(String jobId);

  Stream<List<Job>> watchSavedJobs(String userId);

  Future<Result<void>> saveJob(String userId, Job job);

  Future<Result<void>> removeSavedJob(String userId, String jobId);

  Future<Result<void>> deleteAllForUser(String userId);
}
