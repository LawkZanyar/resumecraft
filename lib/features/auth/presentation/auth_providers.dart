import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/fakes/fake_auth_repository.dart';
import '../../../shared/domain/domain.dart';

/// Phase 1 uses the in-memory fake. Phase 2 switches on `AppConfig.useFakes`.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FakeAuthRepository(),
);

final authStateProvider = StreamProvider<AuthUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// The signed-in user, or null while signed out or still loading.
final currentUserProvider = Provider<AuthUser?>(
  (ref) => ref.watch(authStateProvider).value,
);

/// The signed-in user id, or null.
final currentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(currentUserProvider)?.uid,
);

/// Shared busy/error state for auth forms.
class AuthFormController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> run(Future<Result<Object?>> Function(AuthRepository repo) action) async {
    state = const AsyncLoading();
    final result = await action(ref.read(authRepositoryProvider));
    if (!ref.mounted) return result.isOk;
    state = result.when(
      ok: (_) => const AsyncData(null),
      err: (f) => AsyncError(f, StackTrace.current),
    );
    return result.isOk;
  }

  void reset() => state = const AsyncData(null);
}

final authFormControllerProvider =
    NotifierProvider.autoDispose<AuthFormController, AsyncValue<void>>(
  AuthFormController.new,
);
