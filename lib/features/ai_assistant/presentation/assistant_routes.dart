import 'package:go_router/go_router.dart';

import '../../interview/presentation/screens/interview_report_screen.dart';
import '../../interview/presentation/screens/interview_session_screen.dart';
import '../../interview/presentation/screens/interview_setup_screen.dart';
import '../../voice/presentation/screens/voice_review_screen.dart';
import '../../voice/presentation/screens/voice_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/improve_resume_screen.dart';
import 'screens/skills_screen.dart';

/// Sub-routes of the AI Career Assistant tab (`/assistant/...`).
final assistantRoutes = <RouteBase>[
  GoRoute(path: 'improve', builder: (_, _) => const ImproveResumeScreen()),
  GoRoute(path: 'analysis', builder: (_, _) => const AnalysisScreen()),
  GoRoute(path: 'skills', builder: (_, _) => const SkillsScreen()),
  GoRoute(
    path: 'voice',
    builder: (_, _) => const VoiceScreen(),
    routes: [GoRoute(path: 'review', builder: (_, _) => const VoiceReviewScreen())],
  ),
  GoRoute(
    path: 'interview',
    builder: (_, _) => const InterviewSetupScreen(),
    routes: [
      GoRoute(path: 'session', builder: (_, _) => const InterviewSessionScreen()),
      GoRoute(
        path: 'report',
        builder: (_, s) => InterviewReportScreen(sessionId: s.uri.queryParameters['id']),
      ),
    ],
  ),
];
