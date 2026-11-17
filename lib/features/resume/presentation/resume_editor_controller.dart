import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/domain/domain.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import 'resume_providers.dart';

/// Editor key for a resume that has not been saved yet.
const newResumeKey = 'new';

enum SaveStatus { idle, saving, saved, error }

class ResumeEditorState {
  const ResumeEditorState({
    required this.draft,
    this.dirty = false,
    this.status = SaveStatus.idle,
    this.error,
  });

  final Resume draft;
  final bool dirty;
  final SaveStatus status;
  final String? error;

  bool get isNew => draft.resumeId.isEmpty;

  ResumeEditorState copyWith({
    Resume? draft,
    bool? dirty,
    SaveStatus? status,
    String? error,
  }) =>
      ResumeEditorState(
        draft: draft ?? this.draft,
        dirty: dirty ?? this.dirty,
        status: status ?? this.status,
        error: error,
      );
}

/// Holds the resume being edited. Changes stay in memory until [save].
class ResumeEditorController extends AsyncNotifier<ResumeEditorState> {
  ResumeEditorController(this.resumeKey);

  final String resumeKey;

  @override
  Future<ResumeEditorState> build() async {
    if (resumeKey == newResumeKey) {
      final user = ref.read(currentUserProvider);
      final profile = ref.read(currentProfileProvider).value;
      final now = DateTime.now();
      return ResumeEditorState(
        draft: Resume(
          resumeId: '',
          userId: user?.uid ?? '',
          title: 'Untitled resume',
          createdAt: now,
          updatedAt: now,
          personalInformation: PersonalInfo(
            fullName: profile?.fullName ?? user?.displayName ?? '',
            email: user?.email ?? '',
            location: profile?.location ?? '',
          ),
        ),
      );
    }
    final result = await ref.read(resumeRepositoryProvider).getResume(resumeKey);
    return ResumeEditorState(draft: result.unwrap());
  }

  /// Applies a change to the draft.
  void edit(Resume Function(Resume draft) change) {
    final s = state.value;
    if (s == null) return;
    state = AsyncData(s.copyWith(draft: change(s.draft), dirty: true, status: SaveStatus.idle));
  }

  Future<bool> save() async {
    final s = state.value;
    if (s == null) return false;
    state = AsyncData(s.copyWith(status: SaveStatus.saving));
    final result = await ref.read(resumeRepositoryProvider).saveResume(s.draft);
    if (!ref.mounted) return result.isOk;
    final current = state.value ?? s;
    state = AsyncData(
      result.when(
        ok: (saved) => current.copyWith(
          // Keep edits made while saving, but adopt the stored id.
          draft: current.draft.copyWith(resumeId: saved.resumeId, updatedAt: saved.updatedAt),
          dirty: current.draft != s.draft,
          status: SaveStatus.saved,
        ),
        err: (f) => current.copyWith(status: SaveStatus.error, error: f.message),
      ),
    );
    return result.isOk;
  }
}

final resumeEditorProvider = AsyncNotifierProvider.autoDispose
    .family<ResumeEditorController, ResumeEditorState, String>(ResumeEditorController.new);
