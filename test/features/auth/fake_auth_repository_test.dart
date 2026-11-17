import 'package:flutter_test/flutter_test.dart';
import 'package:resumecraft/shared/data/fakes/fake_auth_repository.dart';
import 'package:resumecraft/shared/domain/domain.dart';

void main() {
  late FakeAuthRepository repo;

  setUp(() => repo = FakeAuthRepository(latency: Duration.zero));

  test('register signs the user in and emits the new user', () async {
    final events = <AuthUser?>[];
    final sub = repo.authStateChanges().listen(events.add);
    final r = await repo.register(
      fullName: 'Test User',
      email: 'Test@Example.com',
      password: 'Password1',
    );
    await Future<void>.delayed(Duration.zero);
    expect(r.isOk, isTrue);
    expect(repo.currentUser?.email, 'test@example.com');
    expect(events.last?.email, 'test@example.com');
    await sub.cancel();
  });

  test('duplicate registration fails', () async {
    await repo.register(fullName: 'A', email: 'a@b.co', password: 'Password1');
    final r = await repo.register(fullName: 'A', email: 'a@b.co', password: 'Password1');
    expect(r.failureOrNull?.kind, FailureKind.auth);
  });

  test('wrong password fails, right password works', () async {
    final bad = await repo.signIn(email: FakeAuthRepository.sampleEmail, password: 'nope');
    expect(bad.isOk, isFalse);
    final good = await repo.signIn(
      email: FakeAuthRepository.sampleEmail,
      password: FakeAuthRepository.samplePassword,
    );
    expect(good.isOk, isTrue);
  });

  test('sign out and delete account clear the session', () async {
    await repo.register(fullName: 'A', email: 'x@y.co', password: 'Password1');
    expect((await repo.reauthenticate('wrong')).isOk, isFalse);
    expect((await repo.reauthenticate('Password1')).isOk, isTrue);
    await repo.deleteAccount();
    expect(repo.currentUser, isNull);
    final again = await repo.signIn(email: 'x@y.co', password: 'Password1');
    expect(again.isOk, isFalse);
  });
}
