/// Deterministic text rules used by the offline sample AI engine.
/// They only rearrange and polish the user's own words; they never add facts.
abstract final class TextRules {
  static const _weakStarts = <String, String>{
    'was responsible for': 'Managed',
    'responsible for': 'Managed',
    'in charge of': 'Led',
    'worked on': 'Contributed to',
    'helped with': 'Supported',
    'helped': 'Supported',
    'dealt with': 'Handled',
    'talked to': 'Communicated with',
    'tried to': 'Worked to',
    'made': 'Created',
    'did': 'Completed',
    'fixed': 'Resolved',
    'got': 'Achieved',
  };

  static const _fillers = ['basically', 'really', 'very', 'just', 'actually', 'kind of', 'sort of'];

  static const _misspellings = <String, String>{
    'teh': 'the',
    'recieve': 'receive',
    'recieved': 'received',
    'managment': 'management',
    'experiance': 'experience',
    'responsable': 'responsible',
    'acheived': 'achieved',
    'acheive': 'achieve',
    'succesful': 'successful',
    'succesfully': 'successfully',
    'enviroment': 'environment',
    'comunication': 'communication',
    'communcation': 'communication',
    'devloped': 'developed',
    'develope': 'develop',
    'occured': 'occurred',
    'seperate': 'separate',
    'definately': 'definitely',
    'buisness': 'business',
    'calender': 'calendar',
    'collegue': 'colleague',
    'collegues': 'colleagues',
    'wich': 'which',
    'alot': 'a lot',
  };

  static const actionVerbs = {
    'achieved',
    'analyzed',
    'built',
    'contributed',
    'coordinated',
    'created',
    'delivered',
    'designed',
    'developed',
    'improved',
    'increased',
    'launched',
    'led',
    'managed',
    'organized',
    'planned',
    'reduced',
    'resolved',
    'supported',
    'trained',
    'wrote',
    'tested',
    'handled',
    'communicated',
    'completed',
    'ran',
    'implemented',
    'prepared',
    'presented',
    'researched',
    'served',
    'taught',
  };

  static const hedges = [
    'maybe',
    'i think',
    'kind of',
    'sort of',
    'probably',
    'i guess',
    'i feel like',
    'perhaps',
    'not sure',
    'hopefully',
    'i hope',
  ];

  static const stopWords = {
    'the',
    'and',
    'for',
    'with',
    'that',
    'this',
    'your',
    'you',
    'what',
    'about',
    'tell',
    'describe',
    'time',
    'how',
    'did',
    'have',
    'from',
    'when',
    'would',
    'which',
    'their',
    'there',
    'they',
    'them',
    'were',
    'will',
    'into',
    'some',
  };

  /// Pattern -> skill name. Patterns match the user's own text.
  static final skillPatterns = <RegExp, String>{
    for (final e in const {
      r'\bfigma\b': 'Figma',
      r'\bflutter\b': 'Flutter',
      r'\bdart\b': 'Dart',
      r'\bpython\b': 'Python',
      r'\bjava\b': 'Java',
      r'\bjavascript\b': 'JavaScript',
      r'\btypescript\b': 'TypeScript',
      r'\breact\b': 'React',
      r'\bsql\b': 'SQL',
      r'\bgit\b': 'Git',
      r'\bfirebase\b': 'Firebase',
      r'\bapis?\b': 'REST APIs',
      r'\bexcel\b': 'Microsoft Excel',
      r'\bphotoshop\b': 'Adobe Photoshop',
      r'\bcanva\b': 'Canva',
      r'social media': 'Social media management',
      r'\bcopywrit': 'Copywriting',
      r'\bcustomer': 'Customer service',
      r'\bmarketing\b': 'Marketing',
      r'\bsales\b': 'Sales',
      r'\bresearch': 'Research',
      r'\busability|\buser test': 'Usability testing',
      r'\bprototyp': 'Prototyping',
      r'\bled\b|\blead a team|\bleading\b': 'Leadership',
      r'\bteam\b|\bteammates?\b': 'Teamwork',
      r'\bpresent(ed|ation)': 'Presentation skills',
      r'\bbudget': 'Budgeting',
      r'\bschedul': 'Scheduling',
      r'\btrain(ed|ing)\b': 'Training',
      r'\bdata analy': 'Data analysis',
      r'\bcommunicat': 'Communication',
      r'\bpatients?\b': 'Patient care',
      r'\baccounting\b': 'Accounting',
      r'\btest(ed|ing|s)?\b': 'Testing',
      r'\bdesign(ed|ing)?\b': 'Design',
      r'\bcontent\b': 'Content creation',
    }.entries)
      RegExp(e.key, caseSensitive: false): e.value,
  };

  static String capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  static List<String> lines(String text) =>
      text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

  static List<String> sentences(String text) => text
      .replaceAll('\n', '. ')
      .split(RegExp(r'(?<=[.!?])\s+|\.\s*$'))
      .map((s) => s.trim().replaceAll(RegExp(r'[.!?]+$'), ''))
      .where((s) => s.isNotEmpty)
      .toList();

  static int wordCount(String text) =>
      text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;

  /// Spelling, spacing, "i" and capitalization fixes, line by line.
  static String fixGrammar(String text) => lines(text).map(fixLine).join('\n');

  static String fixLine(String line) {
    var l = line.replaceAll(RegExp(r'\s+'), ' ').trim();
    l = l.replaceAllMapped(RegExp(r'\bi\b(?!\.)'), (_) => 'I');
    l = l.replaceAllMapped(RegExp(r'\b([A-Za-z]+)\b'), (m) {
      final w = m[1]!;
      final fix = _misspellings[w.toLowerCase()];
      if (fix == null) return w;
      return w[0] == w[0].toUpperCase() ? capitalize(fix) : fix;
    });
    l = l.replaceAll(RegExp(r'\s+([,.;:!?])'), r'$1');
    l = l.replaceAllMapped(RegExp(r'([.!?])\s+([a-z])'), (m) => '${m[1]} ${m[2]!.toUpperCase()}');
    l = capitalize(l);
    if (wordCount(l) > 6 && !RegExp(r'[.!?:]$').hasMatch(l)) l = '$l.';
    return l;
  }

  /// Professional rewrite of one bullet/sentence using only its own words.
  static String rewriteLine(String line) {
    var l = line.trim().replaceAll(RegExp(r'^[-•*]\s*'), '');
    l = l.replaceFirst(RegExp(r'^(i|we)\s+(also\s+)?', caseSensitive: false), '');
    for (final f in _fillers) {
      l = l.replaceAll(RegExp('\\b$f\\b ?', caseSensitive: false), '');
    }
    final lower = l.toLowerCase();
    for (final e in _weakStarts.entries) {
      if (lower.startsWith('${e.key} ')) {
        l = '${e.value}${l.substring(e.key.length)}';
        break;
      }
    }
    // "managed their social media" -> "managed social media".
    l = l.replaceAll(RegExp(r'\b(their|our|my) (?=\w)', caseSensitive: false), '');
    l = fixLine(l).replaceAll(RegExp(r'\.$'), '');
    return l;
  }

  /// Rewrites multi-line text: each line becomes a polished bullet.
  static String rewrite(String text) => lines(text)
      .expand((l) => l.contains('. ') ? sentences(l) : [l])
      .map(rewriteLine)
      .where((l) => l.isNotEmpty)
      .join('\n');

  static bool startsWithActionVerb(String line) {
    final first = line.trim().split(RegExp(r'\s+')).first.toLowerCase();
    return actionVerbs.contains(first);
  }

  static bool hasNumber(String text) => RegExp(r'\d').hasMatch(text);

  static int hedgeCount(String text) {
    final t = ' ${text.toLowerCase()} ';
    return hedges.fold(0, (n, h) => n + RegExp('\\b$h\\b').allMatches(t).length);
  }

  static Set<String> contentWords(String text) => text
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9+#]+'))
      .where((w) => w.length > 3 && !stopWords.contains(w))
      .toSet();

  /// Skills found in [text], with the sentence that supports each one.
  static Map<String, String> findSkills(String text) {
    final found = <String, String>{};
    final sents = sentences(text);
    for (final e in skillPatterns.entries) {
      for (final s in sents) {
        if (e.key.hasMatch(s)) {
          found.putIfAbsent(e.value, () => s);
          break;
        }
      }
    }
    return found;
  }
}
