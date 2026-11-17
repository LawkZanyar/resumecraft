import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/fakes/fake_resume_repository.dart';
import '../../../shared/domain/domain.dart';
import '../../auth/presentation/auth_providers.dart';

final resumeRepositoryProvider = Provider<ResumeRepository>(
  (ref) => FakeResumeRepository(),
);

/// The signed-in user's resumes, most recently updated first.
final userResumesProvider = StreamProvider<List<Resume>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(resumeRepositoryProvider).watchResumes(uid);
});

/// One resume from the live list, or null when it does not exist.
final resumeByIdProvider = Provider.family<AsyncValue<Resume?>, String>(
  (ref, id) => ref.watch(userResumesProvider).whenData(
        (list) => list.where((r) => r.resumeId == id).firstOrNull,
      ),
);
