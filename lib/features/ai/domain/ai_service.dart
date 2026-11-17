import '../../../shared/domain/domain.dart';
import 'ai_models.dart';

/// The single entry point for every AI feature (Task 1.3).
///
/// Rules every implementation follows:
/// - Only improve information the user supplied. Never invent qualifications,
///   degrees, employers, dates, achievements, metrics or experience.
/// - Leave a marked gap such as "[add a result]" when information is missing.
/// - Return typed failures instead of throwing.
abstract interface class AiService {
  /// True for the offline sample engine; the UI then shows "Sample AI result".
  bool get isSample;

  /// Scores a resume out of 100 with strengths, weaknesses and recommendations.
  Future<Result<ResumeAnalysis>> analyzeResume(Resume resume);

  /// Rewrites poorly written text in a professional tone.
  Future<Result<TextSuggestion>> rewriteText(String text, {String context = ''});

  /// Corrects grammar and spelling without changing meaning.
  Future<Result<TextSuggestion>> correctGrammar(String text);

  /// Turns the user's rough notes about a role into a professional description.
  Future<Result<TextSuggestion>> generateDescription({
    required String role,
    required String company,
    required String notes,
  });

  /// Suggests skills that the user's own experience text supports.
  Future<Result<List<SkillSuggestion>>> suggestSkills(Resume resume);

  /// Organizes a spoken description into resume sections.
  Future<Result<VoiceResumeDraft>> structureVoiceTranscript(String transcript);

  /// Behavioral, technical and general questions for a role.
  Future<Result<List<InterviewQuestion>>> generateInterviewQuestions({
    required String jobTitle,
    required InterviewCategory category,
    Resume? resume,
    int count = 5,
  });

  /// Scores one answer on relevance, clarity, confidence language and completeness.
  Future<Result<AnswerEvaluation>> evaluateAnswer({
    required InterviewQuestion question,
    required String answer,
    required String jobTitle,
    Resume? resume,
  });

  /// Final performance report for a finished session.
  Future<Result<InterviewReport>> summarizeInterview(InterviewSession session);
}
