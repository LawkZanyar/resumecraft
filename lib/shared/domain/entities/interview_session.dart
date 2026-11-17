import 'map_utils.dart';

enum InterviewQuestionType {
  behavioral('Behavioral'),
  technical('Technical'),
  general('General');

  const InterviewQuestionType(this.label);
  final String label;
}

class InterviewQuestion {
  const InterviewQuestion({
    required this.id,
    required this.text,
    required this.type,
    this.isFollowUp = false,
  });

  final String id;
  final String text;
  final InterviewQuestionType type;

  /// True when the question adapts to an earlier answer.
  final bool isFollowUp;

  Map<String, Object?> toMap() =>
      {'id': id, 'text': text, 'type': type.name, 'isFollowUp': isFollowUp};

  factory InterviewQuestion.fromMap(Map<String, Object?> m) => InterviewQuestion(
        id: str(m['id']),
        text: str(m['text']),
        type: enumOf(
          InterviewQuestionType.values,
          m['type'],
          InterviewQuestionType.general,
        ),
        isFollowUp: boolOf(m['isFollowUp']),
      );
}

/// Scores for one answer. Sub-scores are 0 to 10; [score] is 0 to 100.
/// "Confidence" refers to language patterns such as hedging, never emotion.
class AnswerEvaluation {
  const AnswerEvaluation({
    required this.relevance,
    required this.clarity,
    required this.confidence,
    required this.completeness,
    required this.score,
    this.wentWell = const [],
    this.toImprove = const [],
    this.strongerAnswer = '',
  });

  final int relevance;
  final int clarity;
  final int confidence;
  final int completeness;
  final int score;
  final List<String> wentWell;
  final List<String> toImprove;

  /// Stronger example built only from the user's own background.
  final String strongerAnswer;

  Map<String, Object?> toMap() => {
        'relevance': relevance,
        'clarity': clarity,
        'confidence': confidence,
        'completeness': completeness,
        'score': score,
        'wentWell': wentWell,
        'toImprove': toImprove,
        'strongerAnswer': strongerAnswer,
      };

  factory AnswerEvaluation.fromMap(Map<String, Object?> m) => AnswerEvaluation(
        relevance: intOf(m['relevance']),
        clarity: intOf(m['clarity']),
        confidence: intOf(m['confidence']),
        completeness: intOf(m['completeness']),
        score: intOf(m['score']),
        wentWell: strList(m['wentWell']),
        toImprove: strList(m['toImprove']),
        strongerAnswer: str(m['strongerAnswer']),
      );
}

class InterviewAnswer {
  const InterviewAnswer({
    required this.questionId,
    required this.text,
    this.evaluation,
  });

  final String questionId;
  final String text;
  final AnswerEvaluation? evaluation;

  Map<String, Object?> toMap() => {
        'questionId': questionId,
        'text': text,
        'evaluation': evaluation?.toMap(),
      };

  factory InterviewAnswer.fromMap(Map<String, Object?> m) => InterviewAnswer(
        questionId: str(m['questionId']),
        text: str(m['text']),
        evaluation: m['evaluation'] is Map
            ? AnswerEvaluation.fromMap(asMap(m['evaluation']))
            : null,
      );
}

/// Final performance report for a whole session.
class InterviewReport {
  const InterviewReport({
    required this.summary,
    this.strengths = const [],
    this.improvements = const [],
  });

  final String summary;
  final List<String> strengths;
  final List<String> improvements;

  Map<String, Object?> toMap() => {
        'summary': summary,
        'strengths': strengths,
        'improvements': improvements,
      };

  factory InterviewReport.fromMap(Map<String, Object?> m) => InterviewReport(
        summary: str(m['summary']),
        strengths: strList(m['strengths']),
        improvements: strList(m['improvements']),
      );
}

/// `interviewSessions` collection document.
class InterviewSession {
  const InterviewSession({
    required this.sessionId,
    required this.userId,
    required this.jobTitle,
    required this.createdAt,
    this.category = '',
    this.questions = const [],
    this.answers = const [],
    this.evaluation,
    this.overallScore,
    this.isSample = false,
  });

  final String sessionId;
  final String userId;
  final String jobTitle;
  final String category;
  final List<InterviewQuestion> questions;
  final List<InterviewAnswer> answers;
  final InterviewReport? evaluation;
  final int? overallScore;
  final bool isSample;
  final DateTime createdAt;

  bool get isComplete => evaluation != null;

  InterviewSession copyWith({
    List<InterviewQuestion>? questions,
    List<InterviewAnswer>? answers,
    InterviewReport? evaluation,
    int? overallScore,
  }) =>
      InterviewSession(
        sessionId: sessionId,
        userId: userId,
        jobTitle: jobTitle,
        category: category,
        questions: questions ?? this.questions,
        answers: answers ?? this.answers,
        evaluation: evaluation ?? this.evaluation,
        overallScore: overallScore ?? this.overallScore,
        isSample: isSample,
        createdAt: createdAt,
      );

  Map<String, Object?> toMap() => {
        'sessionId': sessionId,
        'userId': userId,
        'jobTitle': jobTitle,
        'category': category,
        'questions': questions.map((q) => q.toMap()).toList(),
        'answers': answers.map((a) => a.toMap()).toList(),
        'evaluation': evaluation?.toMap(),
        'overallScore': overallScore,
        'isSample': isSample,
        'createdAt': dateToStr(createdAt),
      };

  factory InterviewSession.fromMap(Map<String, Object?> m) => InterviewSession(
        sessionId: str(m['sessionId']),
        userId: str(m['userId']),
        jobTitle: str(m['jobTitle']),
        category: str(m['category']),
        questions: mapList(m['questions']).map(InterviewQuestion.fromMap).toList(),
        answers: mapList(m['answers']).map(InterviewAnswer.fromMap).toList(),
        evaluation: m['evaluation'] is Map
            ? InterviewReport.fromMap(asMap(m['evaluation']))
            : null,
        overallScore: intOrNull(m['overallScore']),
        isSample: boolOf(m['isSample']),
        createdAt: dateOf(m['createdAt']),
      );
}
