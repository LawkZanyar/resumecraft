import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumecraft/app/app.dart';
import 'package:resumecraft/features/auth/presentation/auth_providers.dart';
import 'package:resumecraft/features/auth/presentation/screens/login_screen.dart';
import 'package:resumecraft/features/auth/presentation/screens/register_screen.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('login shows validation errors for empty fields', (tester) async {
    await pumpScreen(tester, const LoginScreen());
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pump();
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('register validates password rules and matching', (tester) async {
    await pumpScreen(tester, const RegisterScreen());
    await tester.enterText(find.byKey(const Key('register_name')), 'Test User');
    await tester.enterText(find.byKey(const Key('register_email')), 'test@example.com');
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('register_password')),
        matching: find.byType(TextFormField),
      ),
      'short',
    );
    await tester.ensureVisible(find.byKey(const Key('register_submit')));
    await tester.tap(find.byKey(const Key('register_submit')));
    await tester.pump();
    expect(find.text('Use at least 8 characters'), findsOneWidget);
  });

  testWidgets('first launch shows onboarding, then login, then home', (tester) async {
    final overrides = await baseOverrides();
    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const ResumeCraftApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Build a standout resume'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.tap(find.text('Fill in the sample account for a demo'));
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('every tab is reachable from the bottom bar', (tester) async {
    final overrides = await baseOverrides(prefs: {'onboarding_seen': true});
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    await signInSample(container);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const ResumeCraftApp()),
    );
    await tester.pumpAndSettle();
    expect(container.read(currentUserProvider), isNotNull);
    for (final label in ['My Resumes', 'Assistant', 'Jobs', 'Profile', 'Home']) {
      await tester.tap(find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ));
      await tester.pumpAndSettle();
    }
    expect(find.text('Quick actions'), findsOneWidget);
  });
}
