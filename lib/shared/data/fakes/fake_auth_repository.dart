import 'dart:async';

import '../../domain/domain.dart';
import 'fake_stream.dart';

/// In-memory sign-in for development, tests and demos without accounts.
/// Nothing is persisted, and passwords only live in memory for this session.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.latency = const Duration(milliseconds: 400),
    bool seedSampleAccount = true,
  }) {
    if (seedSampleAccount) {
      _accounts[sampleEmail] = _Account(
        const AuthUser(uid: 'sample-user', email: sampleEmail, displayName: 'Sara Ahmed'),
        samplePassword,
      );
    }
  }

  /// Labeled sample account shown on the login screen.
  static const sampleEmail = 'sample@resumecraft.app';
  static const samplePassword = 'Sample1234';

  final Duration latency;
  final Map<String, _Account> _accounts = {};
  final StreamController<AuthUser?> _changes = StreamController.broadcast();
  AuthUser? _current;
  int _nextId = 1;

  @override
  AuthUser? get currentUser => _current;

  @override
  Stream<AuthUser?> authStateChanges() =>
      watchWithInitial(() => _current, _changes.stream);

  void _set(AuthUser? user) {
    _current = user;
    _changes.add(user);
  }

  Future<void> _wait() => fakeDelay(latency);

  @override
  Future<Result<AuthUser>> signIn({
    required String email,
    required String password,
  }) async {
    await _wait();
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      return const Result.err(Failure.auth('Incorrect email or password.'));
    }
    _set(account.user);
    return Result.ok(account.user);
  }

  @override
  Future<Result<AuthUser>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _wait();
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      return const Result.err(
        Failure.auth('An account already exists for that email.'),
      );
    }
    final user = AuthUser(
      uid: 'fake-user-${_nextId++}',
      email: key,
      displayName: fullName.trim(),
    );
    _accounts[key] = _Account(user, password);
    _set(user);
    return Result.ok(user);
  }

  @override
  Future<Result<void>> sendPasswordReset(String email) async {
    await _wait();
    // Same answer whether or not the account exists, to avoid leaking accounts.
    return const Result.ok(null);
  }

  @override
  Future<void> signOut() async {
    await _wait();
    _set(null);
  }

  @override
  Future<Result<void>> reauthenticate(String password) async {
    await _wait();
    final user = _current;
    if (user == null) return const Result.err(Failure.auth('Not signed in.'));
    if (_accounts[user.email]?.password != password) {
      return const Result.err(Failure.auth('Incorrect password.'));
    }
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> deleteAccount() async {
    await _wait();
    final user = _current;
    if (user == null) return const Result.err(Failure.auth('Not signed in.'));
    _accounts.remove(user.email);
    _set(null);
    return const Result.ok(null);
  }
}

class _Account {
  _Account(this.user, this.password);
  final AuthUser user;
  final String password;
}
