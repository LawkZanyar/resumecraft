import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../shared/data/fakes/fake_profile_repository.dart';
import '../../../shared/domain/domain.dart';
import '../../auth/presentation/auth_providers.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => FakeProfileRepository(),
);

/// Profile of the signed-in user; null while signed out.
final currentProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watchProfile(user.uid).map(
        (p) =>
            p ??
            UserProfile(
              userId: user.uid,
              fullName: user.displayName ?? '',
              email: user.email,
              createdAt: DateTime.now(),
            ),
      );
});

/// Notification preferences stored on the device.
class NotificationPrefs {
  const NotificationPrefs({
    this.interviewReminders = true,
    this.followUpReminders = true,
    this.deadlineReminders = true,
    this.reminderLeadHours = 24,
  });

  final bool interviewReminders;
  final bool followUpReminders;
  final bool deadlineReminders;

  /// How long before an interview the reminder fires.
  final int reminderLeadHours;

  NotificationPrefs copyWith({
    bool? interviewReminders,
    bool? followUpReminders,
    bool? deadlineReminders,
    int? reminderLeadHours,
  }) =>
      NotificationPrefs(
        interviewReminders: interviewReminders ?? this.interviewReminders,
        followUpReminders: followUpReminders ?? this.followUpReminders,
        deadlineReminders: deadlineReminders ?? this.deadlineReminders,
        reminderLeadHours: reminderLeadHours ?? this.reminderLeadHours,
      );
}

class NotificationPrefsController extends Notifier<NotificationPrefs> {
  static const _prefix = 'notif_';

  @override
  NotificationPrefs build() {
    final p = ref.watch(sharedPreferencesProvider);
    return NotificationPrefs(
      interviewReminders: p.getBool('${_prefix}interview') ?? true,
      followUpReminders: p.getBool('${_prefix}followup') ?? true,
      deadlineReminders: p.getBool('${_prefix}deadline') ?? true,
      reminderLeadHours: p.getInt('${_prefix}lead') ?? 24,
    );
  }

  Future<void> update(NotificationPrefs prefs) async {
    state = prefs;
    final p = ref.read(sharedPreferencesProvider);
    await p.setBool('${_prefix}interview', prefs.interviewReminders);
    await p.setBool('${_prefix}followup', prefs.followUpReminders);
    await p.setBool('${_prefix}deadline', prefs.deadlineReminders);
    await p.setInt('${_prefix}lead', prefs.reminderLeadHours);
  }
}

final notificationPrefsProvider =
    NotifierProvider<NotificationPrefsController, NotificationPrefs>(
  NotificationPrefsController.new,
);
