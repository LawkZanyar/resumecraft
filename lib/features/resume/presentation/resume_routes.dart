import 'package:go_router/go_router.dart';

import 'screens/customize_screen.dart';
import 'screens/resume_editor_screen.dart';
import 'screens/resume_preview_screen.dart';
import 'screens/template_gallery_screen.dart';

/// Sub-routes of the My Resumes tab (`/resumes/...`).
final resumeRoutes = <RouteBase>[
  GoRoute(path: 'new', builder: (_, _) => const ResumeEditorScreen()),
  GoRoute(path: 'templates', builder: (_, _) => const TemplateGalleryScreen()),
  GoRoute(
    path: ':id/edit',
    builder: (_, s) => ResumeEditorScreen(resumeId: s.pathParameters['id']),
  ),
  GoRoute(
    path: ':id/preview',
    builder: (_, s) => ResumePreviewScreen(resumeId: s.pathParameters['id']!),
  ),
  GoRoute(
    path: ':id/customize',
    builder: (_, s) => CustomizeScreen(resumeId: s.pathParameters['id']!),
  ),
];
