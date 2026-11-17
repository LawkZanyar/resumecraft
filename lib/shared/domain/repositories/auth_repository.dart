import '../../../core/errors/result.dart';
import '../entities/user_profile.dart';

/// Email-and-password authentication. Passwords are never stored by the app.
abstract interface class AuthRepository {
  Stream<AuthUser?> authStateChanges();

  AuthUser? get currentUser;

  Future<Result<AuthUser>> signIn({
    required String email,
    required String password,
  });

  Future<Result<AuthUser>> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<Result<void>> sendPasswordReset(String email);

  Future<void> signOut();

  /// Confirms the password again before sensitive actions such as deletion.
  Future<Result<void>> reauthenticate(String password);

  /// Deletes the authentication account. Data is removed by the caller first.
  Future<Result<void>> deleteAccount();
}

/// `users` documents.
abstract interface class ProfileRepository {
  Stream<UserProfile?> watchProfile(String userId);

  Future<Result<void>> saveProfile(UserProfile profile);

  Future<Result<void>> deleteProfile(String userId);
}
