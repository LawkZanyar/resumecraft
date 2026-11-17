import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:resumecraft/app/theme/app_theme.dart';
import 'package:resumecraft/core/providers/core_providers.dart';
import 'package:resumecraft/features/auth/presentation/auth_providers.dart';
import 'package:resumecraft/shared/data/fakes/fake_auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Base overrides every widget test needs: preferences and an instant fake auth.
Future<List<Override>> baseOverrides({
  Map<String, Object> prefs = const {},
  FakeAuthRepository? auth,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final instance = await SharedPreferences.getInstance();
  return [
    sharedPreferencesProvider.overrideWithValue(instance),
    authRepositoryProvider.overrideWithValue(
      auth ?? FakeAuthRepository(latency: Duration.zero),
    ),
  ];
}

/// Pumps a single screen inside MaterialApp + ProviderScope.
Future<ProviderContainer> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  List<Override> overrides = const [],
}) async {
  final base = await baseOverrides();
  final container = ProviderContainer(
    overrides: [...base, ...overrides],
    retry: (_, _) => null,
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: AppTheme.light, home: screen),
    ),
  );
  return container;
}

/// Signs in the fake sample account directly through the repository.
Future<void> signInSample(ProviderContainer container) async {
  await container.read(authRepositoryProvider).signIn(
        email: FakeAuthRepository.sampleEmail,
        password: FakeAuthRepository.samplePassword,
      );
}
