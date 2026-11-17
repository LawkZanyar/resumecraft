import 'job.dart';
import 'map_utils.dart';

/// The six tracker statuses from F7, in pipeline order.
enum ApplicationStatus {
  interested('Interested'),
  applied('Applied'),
  underReview('Under Review'),
  interviewScheduled('Interview Scheduled'),
  accepted('Accepted'),
  rejected('Rejected');

  const ApplicationStatus(this.label);
  final String label;

  bool get isClosed => this == accepted || this == rejected;
}

/// `applications` collection document.
class JobApplication {
  const JobApplication({
    required this.applicationId,
    required this.userId,
    required this.jobId,
    required this.jobSnapshot,
    required this.status,
    required this.createdAt,
    this.applicationDate,
    this.interviewDate,
    this.followUpDate,
    this.notes = '',
    this.matchScore,
  });

  final String applicationId;
  final String userId;
  final String jobId;

  /// Copy of the job at the time it was saved, so the tracker still works if
  /// the listing disappears from the API.
  final Job jobSnapshot;
  final ApplicationStatus status;
  final DateTime? applicationDate;
  final DateTime? interviewDate;
  final DateTime? followUpDate;
  final String notes;

  /// Latest compatibility score for this job, if the user checked it.
  final int? matchScore;
  final DateTime createdAt;

  JobApplication copyWith({
    ApplicationStatus? status,
    DateTime? applicationDate,
    DateTime? interviewDate,
    DateTime? followUpDate,
    bool clearInterviewDate = false,
    bool clearFollowUpDate = false,
    String? notes,
    int? matchScore,
  }) =>
      JobApplication(
        applicationId: applicationId,
        userId: userId,
        jobId: jobId,
        jobSnapshot: jobSnapshot,
        status: status ?? this.status,
        applicationDate: applicationDate ?? this.applicationDate,
        interviewDate: clearInterviewDate ? null : interviewDate ?? this.interviewDate,
        followUpDate: clearFollowUpDate ? null : followUpDate ?? this.followUpDate,
        notes: notes ?? this.notes,
        matchScore: matchScore ?? this.matchScore,
        createdAt: createdAt,
      );

  Map<String, Object?> toMap() => {
        'applicationId': applicationId,
        'userId': userId,
        'jobId': jobId,
        'jobSnapshot': jobSnapshot.toMap(),
        'status': status.name,
        'applicationDate': dateToStr(applicationDate),
        'interviewDate': dateToStr(interviewDate),
        'followUpDate': dateToStr(followUpDate),
        'notes': notes,
        'matchScore': matchScore,
        'createdAt': dateToStr(createdAt),
      };

  factory JobApplication.fromMap(Map<String, Object?> m) => JobApplication(
        applicationId: str(m['applicationId']),
        userId: str(m['userId']),
        jobId: str(m['jobId']),
        jobSnapshot: Job.fromMap(asMap(m['jobSnapshot'])),
        status: enumOf(
          ApplicationStatus.values,
          m['status'],
          ApplicationStatus.interested,
        ),
        applicationDate: dateOrNull(m['applicationDate']),
        interviewDate: dateOrNull(m['interviewDate']),
        followUpDate: dateOrNull(m['followUpDate']),
        notes: str(m['notes']),
        matchScore: intOrNull(m['matchScore']),
        createdAt: dateOf(m['createdAt']),
      );
}
