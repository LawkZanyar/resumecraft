import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/fakes/fake_application_repository.dart';
import '../../../shared/domain/domain.dart';
import '../../auth/presentation/auth_providers.dart';

final applicationRepositoryProvider = Provider<ApplicationRepository>(
  (ref) => FakeApplicationRepository(),
);

final applicationsProvider = StreamProvider<List<JobApplication>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(applicationRepositoryProvider).watchApplications(uid);
});

/// An interview or follow-up coming up for one application.
class UpcomingEvent {
  const UpcomingEvent({required this.application, required this.date, required this.isInterview});

  final JobApplication application;
  final DateTime date;
  final bool isInterview;

  String get label => isInterview ? 'Interview' : 'Follow-up';
}

/// Live statistics computed from the user's applications.
class ApplicationStats {
  const ApplicationStats({required this.byStatus, required this.upcoming, required this.total});

  final Map<ApplicationStatus, int> byStatus;
  final List<UpcomingEvent> upcoming;
  final int total;

  int count(ApplicationStatus s) => byStatus[s] ?? 0;

  int get active => total - count(ApplicationStatus.accepted) - count(ApplicationStatus.rejected);

  /// Share of submitted applications that reached the interview stage or later.
  int get interviewRate {
    final submitted = total - count(ApplicationStatus.interested);
    if (submitted <= 0) return 0;
    final reached = count(ApplicationStatus.interviewScheduled) + count(ApplicationStatus.accepted);
    return (reached * 100 / submitted).round();
  }

  static ApplicationStats from(List<JobApplication> apps, DateTime now) {
    final by = <ApplicationStatus, int>{};
    final upcoming = <UpcomingEvent>[];
    for (final a in apps) {
      by[a.status] = (by[a.status] ?? 0) + 1;
      if (a.interviewDate != null && a.interviewDate!.isAfter(now) && !a.status.isClosed) {
        upcoming.add(UpcomingEvent(application: a, date: a.interviewDate!, isInterview: true));
      }
      if (a.followUpDate != null && a.followUpDate!.isAfter(now) && !a.status.isClosed) {
        upcoming.add(UpcomingEvent(application: a, date: a.followUpDate!, isInterview: false));
      }
    }
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return ApplicationStats(byStatus: by, upcoming: upcoming, total: apps.length);
  }
}

final applicationStatsProvider = Provider<AsyncValue<ApplicationStats>>(
  (ref) =>
      ref.watch(applicationsProvider).whenData((l) => ApplicationStats.from(l, DateTime.now())),
);

final applicationByIdProvider = Provider.family<AsyncValue<JobApplication?>, String>(
  (ref, id) => ref
      .watch(applicationsProvider)
      .whenData((l) => l.where((a) => a.applicationId == id).firstOrNull),
);
