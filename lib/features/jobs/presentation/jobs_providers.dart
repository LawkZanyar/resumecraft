import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/fakes/fake_job_repository.dart';
import '../../../shared/domain/domain.dart';
import '../../auth/presentation/auth_providers.dart';

final jobRepositoryProvider = Provider<JobRepository>((ref) => FakeJobRepository());

/// State of a job search: the query, the jobs loaded so far, and paging.
class JobSearchState {
  const JobSearchState({
    required this.query,
    this.jobs = const [],
    this.loading = false,
    this.hasMore = false,
    this.source,
    this.notice,
    this.error,
    this.totalCount,
  });

  final JobQuery query;
  final List<Job> jobs;
  final bool loading;
  final bool hasMore;
  final JobSource? source;
  final String? notice;
  final Failure? error;
  final int? totalCount;

  JobSearchState copyWith({
    JobQuery? query,
    List<Job>? jobs,
    bool? loading,
    bool? hasMore,
    JobSource? source,
    String? notice,
    Failure? error,
    int? totalCount,
  }) => JobSearchState(
    query: query ?? this.query,
    jobs: jobs ?? this.jobs,
    loading: loading ?? this.loading,
    hasMore: hasMore ?? this.hasMore,
    source: source ?? this.source,
    notice: notice ?? this.notice,
    error: error,
    totalCount: totalCount ?? this.totalCount,
  );
}

class JobSearchController extends Notifier<JobSearchState> {
  @override
  JobSearchState build() {
    Future.microtask(() => search(const JobQuery()));
    return const JobSearchState(query: JobQuery(), loading: true);
  }

  Future<void> search(JobQuery query) async {
    state = JobSearchState(query: query.copyWith(page: 1), loading: true);
    await _load(query.copyWith(page: 1), append: false);
  }

  Future<void> loadMore() async {
    if (state.loading || !state.hasMore) return;
    final next = state.query.copyWith(page: state.query.page + 1);
    state = state.copyWith(loading: true);
    await _load(next, append: true);
  }

  Future<void> _load(JobQuery q, {required bool append}) async {
    final result = await ref.read(jobRepositoryProvider).searchJobs(q);
    if (!ref.mounted) return;
    state = result.when(
      ok: (page) => state.copyWith(
        query: q,
        jobs: append ? [...state.jobs, ...page.jobs] : page.jobs,
        loading: false,
        hasMore: page.hasMore,
        source: page.source,
        notice: page.notice,
        totalCount: page.totalCount,
      ),
      err: (f) => state.copyWith(loading: false, error: f),
    );
  }
}

final jobSearchProvider = NotifierProvider<JobSearchController, JobSearchState>(
  JobSearchController.new,
);

final jobByIdProvider = FutureProvider.family<Job, String>((ref, id) async {
  return (await ref.watch(jobRepositoryProvider).getJob(id)).unwrap();
});

final savedJobsProvider = StreamProvider<List<Job>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(jobRepositoryProvider).watchSavedJobs(uid);
});

final isJobSavedProvider = Provider.family<bool, String>(
  (ref, id) => ref.watch(savedJobsProvider).value?.any((j) => j.jobId == id) ?? false,
);
