import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/domain/domain.dart';
import '../../ai/domain/ai_models.dart';

/// The organized draft waiting for review on the voice review screen.
class VoiceDraftController extends Notifier<VoiceResumeDraft?> {
  @override
  VoiceResumeDraft? build() => null;

  void set(VoiceResumeDraft? draft) => state = draft;

  void update(VoiceResumeDraft Function(VoiceResumeDraft d) change) {
    final d = state;
    if (d != null) state = change(d);
  }
}

final voiceDraftProvider = NotifierProvider<VoiceDraftController, VoiceResumeDraft?>(
  VoiceDraftController.new,
);

/// Merges reviewed voice content into [resume] without overwriting what the
/// user already wrote.
Resume mergeVoiceDraft(Resume resume, VoiceResumeDraft draft) {
  final have = resume.skills.map((s) => s.toLowerCase()).toSet();
  final p = resume.personalInformation;
  return resume.copyWith(
    personalInformation: p.summary.trim().isEmpty && draft.summary.isNotEmpty
        ? p.copyWith(summary: draft.summary)
        : p,
    experience: [...resume.experience, ...draft.experience],
    education: [...resume.education, ...draft.education],
    skills: [
      ...resume.skills,
      for (final s in draft.skills)
        if (!have.contains(s.toLowerCase())) s,
    ],
  );
}
