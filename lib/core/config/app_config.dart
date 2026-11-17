/// Compile-time configuration for ResumeCraft AI.
///
/// Values come from `--dart-define` so that no secret is ever committed.
/// Example: `flutter run --dart-define=USE_FAKES=true`.
abstract final class AppConfig {
  static const String appName = 'ResumeCraft AI';

  /// When true the app uses in-memory fake repositories and labeled sample
  /// data, so it runs without any backend account.
  static const bool useFakes = bool.fromEnvironment(
    'USE_FAKES',
    defaultValue: true,
  );
}
