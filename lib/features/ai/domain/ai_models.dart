import '../../../shared/domain/domain.dart';

/// A word or phrase in AI output that did not appear in the user's input,
/// such as a name, date, employer, degree or number.
class FabricationFlag {
  const FabricationFlag({required this.text, required this.reason});

  final String text;
  final String reason;
}

/// AI-proposed text. Must be reviewed (accept, edit or reject) before saving.
class TextSuggestion {
  const TextSuggestion({
    required this.original,
    required this.suggestion,
    this.flags = const [],
    this.notes,
  });

  final String original;
  final String suggestion;
  final List<FabricationFlag> flags;

  /// Questions or gaps the user should fill in, e.g. "[add a measurable result]".
  final String? notes;

  bool get changed => original.trim() != suggestion.trim();

  TextSuggestion withFlags(List<FabricationFlag> flags) =>
      TextSuggestion(original: original, suggestion: suggestion, flags: flags, notes: notes);
}

/// A skill the AI found evidence for in the user's own words.
class SkillSuggestion {
  const SkillSuggestion({required this.skill, required this.evidence});

  final String skill;

  /// The user's text that supports this skill.
  final String evidence;
}

/// The 100-point resume analysis.
class ResumeAnalysis {
  const ResumeAnalysis({
    required this.score,
    required this.summary,
    this.sectionScores = const {},
    this.strengths = const [],
    this.weaknesses = const [],
    this.recommendations = const [],
  });

  final int score;
  final String summary;
  final Map<String, int> sectionScores;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
}

/// Resume sections organized from a spoken (or typed) description.
class VoiceResumeDraft {
  const VoiceResumeDraft({
    required this.transcript,
    this.summary = '',
    this.experience = const [],
    this.education = const [],
    this.skills = const [],
    this.needsConfirmation = const [],
  });

  final String transcript;
  final String summary;
  final List<Experience> experience;
  final List<Education> education;
  final List<String> skills;

  /// Wording the user must confirm because they did not say it explicitly.
  final List<String> needsConfirmation;

  bool get isEmpty => summary.isEmpty && experience.isEmpty && education.isEmpty && skills.isEmpty;

  VoiceResumeDraft copyWith({
    String? summary,
    List<Experience>? experience,
    List<Education>? education,
    List<String>? skills,
    List<String>? needsConfirmation,
  }) => VoiceResumeDraft(
    transcript: transcript,
    summary: summary ?? this.summary,
    experience: experience ?? this.experience,
    education: education ?? this.education,
    skills: skills ?? this.skills,
    needsConfirmation: needsConfirmation ?? this.needsConfirmation,
  );
}

/// Interview categories the simulator offers.
enum InterviewCategory {
  general('General'),
  software('Software and IT'),
  design('Design'),
  marketing('Marketing and sales'),
  business('Business and admin'),
  healthcare('Healthcare');

  const InterviewCategory(this.label);
  final String label;
}
