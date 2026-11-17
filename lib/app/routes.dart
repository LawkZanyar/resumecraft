/// Route paths for every screen, shared by all members.
/// Features register their screens for these paths in their own route files.
abstract final class Routes {
  // Access.
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const resetPassword = '/reset-password';

  // Tab roots.
  static const home = '/home';
  static const resumes = '/resumes';
  static const assistant = '/assistant';
  static const jobs = '/jobs';
  static const profile = '/profile';

  // My Resumes (Pasha).
  static const resumeNew = '/resumes/new';
  static const templates = '/resumes/templates';
  static const scanner = '/resumes/scan';
  static const scanReview = '/resumes/scan/review';
  static String resumeEdit(String id) => '/resumes/$id/edit';
  static String resumePreview(String id) => '/resumes/$id/preview';
  static String resumeCustomize(String id) => '/resumes/$id/customize';
  static String resumePdf(String id) => '/resumes/$id/pdf';

  // AI Career Assistant (Hananeh).
  static const aiConsent = '/assistant/consent';
  static const improveResume = '/assistant/improve';
  static const analysis = '/assistant/analysis';
  static const skills = '/assistant/skills';
  static const voice = '/assistant/voice';
  static const voiceReview = '/assistant/voice/review';
  static const interview = '/assistant/interview';
  static const interviewSession = '/assistant/interview/session';
  static const interviewReport = '/assistant/interview/report';
  static const interviewHistory = '/assistant/interview/history';

  // Jobs (Fatemeh).
  static const jobSearch = '/jobs/search';
  static const savedJobs = '/jobs/saved';
  static const nearbyJobs = '/jobs/nearby';
  static const tracker = '/jobs/tracker';
  static const trackerStats = '/jobs/tracker/stats';
  static String jobDetails(String id) => '/jobs/view/$id';
  static String compatibility(String id) => '/jobs/view/$id/compatibility';
  static String applicationDetails(String id) => '/jobs/tracker/$id';

  // Profile (Lawk).
  static const editProfile = '/profile/edit';
  static const settings = '/profile/settings';
  static const notificationSettings = '/profile/notifications';
  static const vault = '/profile/vault';
  static const deleteAccount = '/profile/delete-account';

  /// Routes reachable without signing in.
  static const public = {splash, onboarding, login, register, resetPassword};
}
