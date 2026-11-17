import '../../../shared/data/fakes/fake_stream.dart';
import '../../../shared/data/sample/sample_ai.dart';
import '../../../shared/domain/domain.dart';
import '../domain/ai_models.dart';
import '../domain/ai_service.dart';
import 'text_rules.dart';

/// Offline, rule-based "sample AI". Runs without any account, for
/// development, tests and demos. Results are labeled "Sample AI result".
/// It only reorganizes and polishes what the user wrote.
class FakeAiService implements AiService {
  FakeAiService({this.latency = const Duration(milliseconds: 700)});

  final Duration latency;

  @override
  bool get isSample => true;

  Future<Result<T>> _run<T>(T Function() body) async {
    await fakeDelay(latency);
    return Result.ok(body());
  }

  // ---------------------------------------------------------------- Resume

  @override
  Future<Result<ResumeAnalysis>> analyzeResume(Resume resume) =>
      _run(() => ResumeAnalyzer(resume).analyze());

  @override
  Future<Result<TextSuggestion>> rewriteText(String text, {String context = ''}) => _run(() {
    final out = TextRules.rewrite(text);
    return TextSuggestion(
      original: text,
      suggestion: out,
      notes: TextRules.hasNumber(text)
          ? null
          : 'Consider adding a measurable result you can confirm, e.g. [number of users].',
    );
  });

  @override
  Future<Result<TextSuggestion>> correctGrammar(String text) =>
      _run(() => TextSuggestion(original: text, suggestion: TextRules.fixGrammar(text)));

  @override
  Future<Result<TextSuggestion>> generateDescription({
    required String role,
    required String company,
    required String notes,
  }) => _run(() {
    final bullets = TextRules.rewrite(notes);
    final gap = TextRules.hasNumber(notes) ? '' : '\n[Add a measurable result you achieved]';
    return TextSuggestion(
      original: notes,
      suggestion: '$bullets$gap'.trim(),
      notes: 'Built only from your notes. Fill in any [bracketed] gap or delete it.',
    );
  });

  @override
  Future<Result<List<SkillSuggestion>>> suggestSkills(Resume resume) => _run(() {
    final have = resume.skills.map((s) => s.toLowerCase()).toSet();
    final text = [
      resume.personalInformation.summary,
      for (final e in resume.experience) '${e.role}. ${e.description}',
      for (final p in resume.projects) p.description,
    ].join('\n');
    return [
      for (final e in TextRules.findSkills(text).entries)
        if (!have.contains(e.key.toLowerCase())) SkillSuggestion(skill: e.key, evidence: e.value),
    ];
  });

  // ----------------------------------------------------------------- Voice

  @override
  Future<Result<VoiceResumeDraft>> structureVoiceTranscript(String transcript) =>
      _run(() => VoiceStructurer(transcript).structure());

  // ------------------------------------------------------------- Interview

  @override
  Future<Result<List<InterviewQuestion>>> generateInterviewQuestions({
    required String jobTitle,
    required InterviewCategory category,
    Resume? resume,
    int count = 5,
  }) => _run(() {
    final role = jobTitle.trim().isEmpty ? 'this' : jobTitle.trim();
    String fill(String t) => t.replaceAll('{role}', role);
    final technical = [
      ...?sampleTechnicalQuestions[category.label],
      if (resume != null)
        for (final s in resume.skills.take(2)) 'How have you used $s in your work or projects?',
    ];
    final behavioral = [
      if (resume != null && resume.experience.isNotEmpty)
        'Tell me about a challenge you faced at ${resume.experience.first.company} '
            'and how you handled it.',
      ...sampleBehavioralQuestions,
    ];
    final general = sampleGeneralQuestions.map(fill).toList();
    final out = <InterviewQuestion>[];
    var g = 0, b = 0, t = 0;
    for (var i = 0; out.length < count; i++) {
      final slot = i % 3;
      if (slot == 0 && g < general.length) {
        out.add(
          InterviewQuestion(
            id: 'q${out.length + 1}',
            text: general[g++],
            type: InterviewQuestionType.general,
          ),
        );
      } else if (slot == 1 && b < behavioral.length) {
        out.add(
          InterviewQuestion(
            id: 'q${out.length + 1}',
            text: behavioral[b++],
            type: InterviewQuestionType.behavioral,
          ),
        );
      } else if (slot == 2 && t < technical.length) {
        out.add(
          InterviewQuestion(
            id: 'q${out.length + 1}',
            text: technical[t++],
            type: InterviewQuestionType.technical,
          ),
        );
      }
      if (i > 30) break;
    }
    return out;
  });

  @override
  Future<Result<AnswerEvaluation>> evaluateAnswer({
    required InterviewQuestion question,
    required String answer,
    required String jobTitle,
    Resume? resume,
  }) => _run(() => AnswerScorer(question: question, answer: answer, jobTitle: jobTitle).evaluate());

  @override
  Future<Result<InterviewReport>> summarizeInterview(InterviewSession session) => _run(() {
    final evals = session.answers.map((a) => a.evaluation).whereType<AnswerEvaluation>().toList();
    if (evals.isEmpty) {
      return const InterviewReport(summary: 'No answers were evaluated in this session.');
    }
    final avg = evals.fold<int>(0, (n, e) => n + e.score) ~/ evals.length;
    List<String> top(Iterable<String> items) {
      final counts = <String, int>{};
      for (final i in items) {
        counts[i] = (counts[i] ?? 0) + 1;
      }
      final sorted = counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!));
      return sorted.take(3).toList();
    }

    final band = avg >= 80
        ? 'a strong'
        : avg >= 60
        ? 'a solid'
        : avg >= 40
        ? 'a developing'
        : 'an early-stage';
    return InterviewReport(
      summary:
          'You gave $band performance for the ${session.jobTitle} practice interview, '
          'averaging $avg out of 100 across ${evals.length} answers.',
      strengths: top(evals.expand((e) => e.wentWell)),
      improvements: top(evals.expand((e) => e.toImprove)),
    );
  });
}

/// Rule-based 100-point resume score.
class ResumeAnalyzer {
  ResumeAnalyzer(this.resume);

  final Resume resume;
  final _strengths = <String>[];
  final _weak = <String>[];
  final _recs = <String>[];

  int _check(bool ok, int points, String strength, String weakness, String rec) {
    if (ok) {
      _strengths.add(strength);
      return points;
    }
    _weak.add(weakness);
    _recs.add(rec);
    return 0;
  }

  ResumeAnalysis analyze() {
    final r = resume;
    final p = r.personalInformation;
    final scores = <String, int>{};

    scores['Contact'] =
        (p.fullName.isNotEmpty ? 4 : 0) +
        (p.email.isNotEmpty ? 3 : 0) +
        (p.phone.isNotEmpty || p.location.isNotEmpty ? 3 : 0);
    if (scores['Contact']! < 10) {
      _weak.add('Contact details are incomplete.');
      _recs.add('Add your email and a phone number or city so employers can reach you.');
    }

    final summaryWords = TextRules.wordCount(p.summary);
    scores['Summary'] =
        _check(
          p.summary.isNotEmpty,
          5,
          'You include a professional summary.',
          'There is no professional summary.',
          'Write two or three sentences about your focus and strengths.',
        ) +
        (summaryWords >= 20 && summaryWords <= 90 ? 5 : 0);
    if (p.summary.isNotEmpty && summaryWords < 20) {
      _recs.add('Expand your summary to about 2-3 sentences (it has $summaryWords words).');
    }

    final exp = r.experience;
    final lines = exp.expand((e) => TextRules.lines(e.description)).toList();
    final described = exp.where((e) => e.description.trim().isNotEmpty).length;
    final verbShare = lines.isEmpty
        ? 0.0
        : lines.where(TextRules.startsWithActionVerb).length / lines.length;
    scores['Experience'] =
        _check(
          exp.isNotEmpty,
          10,
          'You list relevant experience.',
          'No work experience is listed.',
          'Add jobs, internships or volunteer work, even short ones.',
        ) +
        (exp.isEmpty ? 0 : (10 * described / exp.length).round()) +
        _check(
          verbShare >= 0.6,
          5,
          'Bullet points start with strong action verbs.',
          'Many bullet points do not start with an action verb.',
          'Start each bullet with a verb such as "Designed", "Led" or "Improved".',
        ) +
        _check(
          lines.any(TextRules.hasNumber),
          5,
          'You quantify at least one achievement.',
          'Achievements are not measured.',
          'Add measurable results you can confirm, such as numbers of users, sales or time saved.',
        );

    scores['Education'] =
        _check(
          r.education.isNotEmpty,
          10,
          'Education is included.',
          'No education is listed.',
          'Add your highest qualification or current studies.',
        ) +
        (r.education.any((e) => e.degree.isNotEmpty && e.institution.isNotEmpty) ? 5 : 0);

    final n = r.skills.length;
    scores['Skills'] = n >= 5 ? 15 : (n >= 3 ? 10 : (n >= 1 ? 5 : 0));
    if (n < 5) {
      _weak.add('The skills section is short ($n listed).');
      _recs.add('List at least five skills that your experience can back up.');
    } else {
      _strengths.add('You list a healthy range of skills.');
    }

    scores['Extras'] =
        (r.projects.isNotEmpty ? 4 : 0) +
        (r.certifications.isNotEmpty ? 3 : 0) +
        (r.languages.isNotEmpty ? 3 : 0);
    if (r.projects.isEmpty) _recs.add('Add a project that shows your skills in action.');

    String norm(String s) => s.replaceAll(RegExp(r'\.$'), '');
    final prose = [
      p.summary,
      for (final e in exp) e.description,
      for (final pr in r.projects) pr.description,
    ].join('\n');
    final issues = TextRules.lines(
      prose,
    ).where((l) => norm(TextRules.fixLine(l)) != norm(l)).length;
    scores['Writing'] = (10 - issues * 2).clamp(0, 10);
    if (issues > 0) {
      _weak.add('Some lines have spelling, spacing or capitalization issues.');
      _recs.add('Run "Fix grammar" on your descriptions.');
    }

    final total = scores.values.fold(0, (a, b) => a + b).clamp(0, 100);
    final summary = total >= 80
        ? 'Strong resume. A few refinements will make it stand out.'
        : total >= 60
        ? 'Good foundation. Address the recommendations to strengthen it.'
        : 'This resume needs more detail before you send it out.';
    return ResumeAnalysis(
      score: total,
      summary: summary,
      sectionScores: scores,
      strengths: _strengths,
      weaknesses: _weak,
      recommendations: _recs.toSet().toList(),
    );
  }
}

/// Splits a spoken description into resume sections.
class VoiceStructurer {
  VoiceStructurer(this.transcript);

  final String transcript;

  static final _work = RegExp(
    r'\b(?:worked|work|working|interned|volunteered|was employed)\s+(?:at|for|with)\s+(?:an?\s+|the\s+)?([^,.]+?)(?=\s+for\s|\s+as\s|\s+and\s|\s+where\s|,|$)',
    caseSensitive: false,
  );
  static final _role = RegExp(
    r'\bas\s+(?:an?\s+)?([a-z][a-z ]{2,40}?)(?=\s+at\s|\s+for\s|\s+and\s|,|$)',
    caseSensitive: false,
  );
  static final _duration = RegExp(
    r'\bfor\s+((?:\w+\s+)?(?:years?|months?|weeks?))',
    caseSensitive: false,
  );
  static final _study = RegExp(
    r'\b(?:studied|study|studying|graduated in|degree in|majored in)\s+([^,.]+?)(?=\s+at\s|,|$)',
    caseSensitive: false,
  );
  static final _school = RegExp(
    r'\bat\s+((?:the\s+)?[A-Z][\w ]*(?:University|College|Institute|School|Polytechnic)[\w ]*)',
  );
  static final _skillList = RegExp(
    r'\b(?:good at|skilled in|experienced with|i know|i can use|know how to use|familiar with)\s+([^.]+)',
    caseSensitive: false,
  );
  static final _iAm = RegExp(r"^i(?:'m| am)\s+(?:an?\s+)?(.+)$", caseSensitive: false);

  VoiceResumeDraft structure() {
    final confirm = <String>[];
    final experience = <Experience>[];
    final education = <Education>[];
    final skills = <String>{};
    var summary = '';

    for (final s in TextRules.sentences(transcript)) {
      final work = _work.firstMatch(s);
      final study = _study.firstMatch(s);
      if (work != null) {
        final company = TextRules.capitalize(work[1]!.trim());
        final role = _role.firstMatch(s)?[1]?.trim() ?? '';
        final rest = s.substring(work.end).replaceFirst(_duration, '').replaceFirst(_role, '');
        final duty = rest
            .replaceFirst(RegExp(r'^\s*(and|where)\s+', caseSensitive: false), '')
            .trim();
        final duration = _duration.firstMatch(s)?[1];
        if (company.toLowerCase().contains('company') || company.split(' ').length > 3) {
          confirm.add('Company name: you said "$company". Add the real name if you want it shown.');
        }
        if (role.isEmpty) confirm.add('Job title at $company: you did not mention one.');
        if (duration != null) {
          confirm.add('Dates at $company: you said "$duration". Add start and end months.');
        }
        experience.add(
          Experience(
            id: 'voice-exp-${experience.length + 1}',
            company: company,
            role: TextRules.capitalize(role),
            description: duty.isEmpty ? '' : TextRules.rewriteLine(duty),
          ),
        );
      } else if (study != null) {
        final school = _school.firstMatch(s)?[1]?.trim() ?? '';
        if (school.isEmpty) confirm.add('School name for "${study[1]!.trim()}": please add it.');
        education.add(
          Education(
            id: 'voice-edu-${education.length + 1}',
            field: TextRules.capitalize(study[1]!.trim()),
            institution: school,
          ),
        );
      } else if (_iAm.hasMatch(s) && summary.isEmpty) {
        summary = TextRules.fixLine(TextRules.capitalize(_iAm.firstMatch(s)![1]!.trim()));
      } else if (experience.isNotEmpty && !_skillList.hasMatch(s)) {
        // A follow-on sentence about the last job: add it as another bullet.
        final last = experience.removeLast();
        final line = TextRules.rewriteLine(s);
        experience.add(
          last.copyWith(
            description: [last.description, line].where((l) => l.isNotEmpty).join('\n'),
          ),
        );
      }
      final list = _skillList.firstMatch(s);
      if (list != null) {
        skills.addAll(
          list[1]!
              .split(RegExp(r',|\band\b'))
              .map((x) => TextRules.capitalize(x.trim()))
              .where((x) => x.isNotEmpty && x.length < 40),
        );
      }
    }
    skills.addAll(TextRules.findSkills(transcript).keys);
    return VoiceResumeDraft(
      transcript: transcript,
      summary: summary,
      experience: experience,
      education: education,
      skills: skills.toList(),
      needsConfirmation: confirm,
    );
  }
}

/// Scores an interview answer from its text only. "Confidence" means
/// language patterns (hedging, vagueness), never emotion or voice.
class AnswerScorer {
  AnswerScorer({required this.question, required this.answer, required this.jobTitle});

  final InterviewQuestion question;
  final String answer;
  final String jobTitle;

  AnswerEvaluation evaluate() {
    final words = TextRules.wordCount(answer);
    final sents = TextRules.sentences(answer);
    final lower = answer.toLowerCase();

    final overlap = TextRules.contentWords(
      '${question.text} $jobTitle',
    ).intersection(TextRules.contentWords(answer)).length;
    final relevance = words < 5 ? 1 : (4 + overlap * 2).clamp(0, 10);

    final avgLen = sents.isEmpty ? 0 : words / sents.length;
    final fillers = RegExp(r'\b(um+|uh+|like,|you know)\b').allMatches(lower).length;
    final clarity = words < 5 ? 2 : ((avgLen >= 6 && avgLen <= 28 ? 9 : 6) - fillers).clamp(1, 10);

    final hedges = TextRules.hedgeCount(answer);
    final owns = RegExp(
      r'\bi (led|built|created|designed|managed|organized|solved|decided|improved|wrote)\b',
    ).hasMatch(lower);
    final confidence = (8 - hedges * 2 + (owns ? 2 : 0)).clamp(1, 10);

    final situation = RegExp(r'\b(when|during|at my|in my|while)\b').hasMatch(lower);
    final action = owns || TextRules.actionVerbs.any((v) => lower.contains(' $v '));
    final result =
        TextRules.hasNumber(answer) ||
        RegExp(r'\b(result|as a result|so that|which led|outcome|learned)\b').hasMatch(lower);
    final completeness =
        ((words >= 60
                    ? 4
                    : words >= 30
                    ? 2
                    : 0) +
                (situation ? 2 : 0) +
                (action ? 2 : 0) +
                (result ? 2 : 0))
            .clamp(0, 10);

    final wentWell = <String>[
      if (relevance >= 7) 'Your answer stayed on the question.',
      if (clarity >= 8) 'Clear, well-sized sentences.',
      if (confidence >= 8) 'Direct language that takes ownership.',
      if (result) 'You described an outcome.',
      if (situation && action) 'You set the scene and explained your actions.',
    ];
    final toImprove = <String>[
      if (words < 30) 'Give more detail: aim for 4-6 sentences.',
      if (relevance < 6) 'Connect your answer more directly to the question.',
      if (hedges > 0) 'Avoid hedging words such as "maybe" or "I think".',
      if (!result) 'End with the result or what you learned.',
      if (!situation) 'Start with the situation so the listener has context.',
    ];
    final score = ((relevance + clarity + confidence + completeness) * 2.5).round();
    return AnswerEvaluation(
      relevance: relevance,
      clarity: clarity,
      confidence: confidence,
      completeness: completeness,
      score: score,
      wentWell: wentWell.isEmpty ? ['You attempted the question.'] : wentWell,
      toImprove: toImprove,
      strongerAnswer: _stronger(sents, result),
    );
  }

  /// Rebuilds the user's own sentences into a STAR structure, with marked
  /// gaps instead of invented details.
  String _stronger(List<String> sents, bool hasResult) {
    if (sents.isEmpty) {
      return 'Situation: [describe a real situation]\nAction: [what you did]\n'
          'Result: [the outcome, only if it is true]';
    }
    final polished = sents.map(TextRules.rewriteLine).toList();
    final situation = polished.first;
    final actions = polished.length > 1
        ? polished.sublist(1, hasResult ? polished.length - 1 : polished.length)
        : <String>[];
    final result = hasResult && polished.length > 1
        ? polished.last
        : '[Add the result you achieved, only if it is true]';
    return 'Situation: $situation.\n'
        'Action: ${actions.isEmpty ? '[Explain the specific steps you took]' : '${actions.join('. ')}.'}\n'
        'Result: $result${result.endsWith(']') ? '' : '.'}';
  }
}
