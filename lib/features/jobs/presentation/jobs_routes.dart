import 'package:go_router/go_router.dart';

import '../../applications/presentation/screens/application_details_screen.dart';
import '../../applications/presentation/screens/stats_screen.dart';
import '../../applications/presentation/screens/tracker_screen.dart';
import 'screens/job_details_screen.dart';
import 'screens/job_search_screen.dart';
import 'screens/nearby_jobs_screen.dart';
import 'screens/saved_jobs_screen.dart';

/// Sub-routes of the Jobs tab (`/jobs/...`).
final jobsRoutes = <RouteBase>[
  GoRoute(path: 'search', builder: (_, _) => const JobSearchScreen()),
  GoRoute(path: 'saved', builder: (_, _) => const SavedJobsScreen()),
  GoRoute(path: 'nearby', builder: (_, _) => const NearbyJobsScreen()),
  GoRoute(
    path: 'view/:id',
    builder: (_, s) => JobDetailsScreen(jobId: s.pathParameters['id']!),
  ),
  GoRoute(
    path: 'tracker',
    builder: (_, _) => const TrackerScreen(),
    routes: [
      GoRoute(path: 'stats', builder: (_, _) => const StatsScreen()),
      GoRoute(
        path: ':id',
        builder: (_, s) => ApplicationDetailsScreen(applicationId: s.pathParameters['id']!),
      ),
    ],
  ),
];
