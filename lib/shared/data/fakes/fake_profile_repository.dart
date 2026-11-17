import 'dart:async';

import '../../domain/domain.dart';
import 'fake_stream.dart';

/// In-memory `users` documents.
class FakeProfileRepository implements ProfileRepository {
  final Map<String, UserProfile> _profiles = {};
  final StreamController<void> _changes = StreamController.broadcast();

  @override
  Stream<UserProfile?> watchProfile(String userId) =>
      watchWithInitial(() => _profiles[userId], _changes.stream);

  @override
  Future<Result<void>> saveProfile(UserProfile profile) async {
    _profiles[profile.userId] = profile;
    _changes.add(null);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> deleteProfile(String userId) async {
    _profiles.remove(userId);
    _changes.add(null);
    return const Result.ok(null);
  }
}
