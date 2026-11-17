import 'map_utils.dart';

/// Sections a resume can show, in their default order.
enum ResumeSection {
  summary('Summary'),
  experience('Experience'),
  education('Education'),
  skills('Skills'),
  projects('Projects'),
  certifications('Certifications'),
  languages('Languages');

  const ResumeSection(this.label);
  final String label;
}

class PersonalInfo {
  const PersonalInfo({
    this.fullName = '',
    this.jobTitle = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.website = '',
    this.summary = '',
  });

  final String fullName;
  final String jobTitle;
  final String email;
  final String phone;
  final String location;
  final String website;
  final String summary;

  PersonalInfo copyWith({
    String? fullName,
    String? jobTitle,
    String? email,
    String? phone,
    String? location,
    String? website,
    String? summary,
  }) =>
      PersonalInfo(
        fullName: fullName ?? this.fullName,
        jobTitle: jobTitle ?? this.jobTitle,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        location: location ?? this.location,
        website: website ?? this.website,
        summary: summary ?? this.summary,
      );

  Map<String, Object?> toMap() => {
        'fullName': fullName,
        'jobTitle': jobTitle,
        'email': email,
        'phone': phone,
        'location': location,
        'website': website,
        'summary': summary,
      };

  factory PersonalInfo.fromMap(Map<String, Object?> m) => PersonalInfo(
        fullName: str(m['fullName']),
        jobTitle: str(m['jobTitle']),
        email: str(m['email']),
        phone: str(m['phone']),
        location: str(m['location']),
        website: str(m['website']),
        summary: str(m['summary']),
      );
}

class Education {
  const Education({
    required this.id,
    this.institution = '',
    this.degree = '',
    this.field = '',
    this.startDate = '',
    this.endDate = '',
    this.description = '',
  });

  final String id;
  final String institution;
  final String degree;
  final String field;

  /// Free text such as "Sep 2021" so users can write dates their own way.
  final String startDate;
  final String endDate;
  final String description;

  Education copyWith({
    String? institution,
    String? degree,
    String? field,
    String? startDate,
    String? endDate,
    String? description,
  }) =>
      Education(
        id: id,
        institution: institution ?? this.institution,
        degree: degree ?? this.degree,
        field: field ?? this.field,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        description: description ?? this.description,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'institution': institution,
        'degree': degree,
        'field': field,
        'startDate': startDate,
        'endDate': endDate,
        'description': description,
      };

  factory Education.fromMap(Map<String, Object?> m) => Education(
        id: str(m['id']),
        institution: str(m['institution']),
        degree: str(m['degree']),
        field: str(m['field']),
        startDate: str(m['startDate']),
        endDate: str(m['endDate']),
        description: str(m['description']),
      );
}

class Experience {
  const Experience({
    required this.id,
    this.company = '',
    this.role = '',
    this.location = '',
    this.startDate = '',
    this.endDate = '',
    this.isCurrent = false,
    this.description = '',
  });

  final String id;
  final String company;
  final String role;
  final String location;
  final String startDate;
  final String endDate;
  final bool isCurrent;
  final String description;

  Experience copyWith({
    String? company,
    String? role,
    String? location,
    String? startDate,
    String? endDate,
    bool? isCurrent,
    String? description,
  }) =>
      Experience(
        id: id,
        company: company ?? this.company,
        role: role ?? this.role,
        location: location ?? this.location,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        isCurrent: isCurrent ?? this.isCurrent,
        description: description ?? this.description,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'company': company,
        'role': role,
        'location': location,
        'startDate': startDate,
        'endDate': endDate,
        'isCurrent': isCurrent,
        'description': description,
      };

  factory Experience.fromMap(Map<String, Object?> m) => Experience(
        id: str(m['id']),
        company: str(m['company']),
        role: str(m['role']),
        location: str(m['location']),
        startDate: str(m['startDate']),
        endDate: str(m['endDate']),
        isCurrent: boolOf(m['isCurrent']),
        description: str(m['description']),
      );
}

class Certification {
  const Certification({
    required this.id,
    this.name = '',
    this.issuer = '',
    this.date = '',
  });

  final String id;
  final String name;
  final String issuer;
  final String date;

  Certification copyWith({String? name, String? issuer, String? date}) =>
      Certification(
        id: id,
        name: name ?? this.name,
        issuer: issuer ?? this.issuer,
        date: date ?? this.date,
      );

  Map<String, Object?> toMap() =>
      {'id': id, 'name': name, 'issuer': issuer, 'date': date};

  factory Certification.fromMap(Map<String, Object?> m) => Certification(
        id: str(m['id']),
        name: str(m['name']),
        issuer: str(m['issuer']),
        date: str(m['date']),
      );
}

class ResumeProject {
  const ResumeProject({
    required this.id,
    this.name = '',
    this.description = '',
    this.link = '',
  });

  final String id;
  final String name;
  final String description;
  final String link;

  ResumeProject copyWith({String? name, String? description, String? link}) =>
      ResumeProject(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        link: link ?? this.link,
      );

  Map<String, Object?> toMap() =>
      {'id': id, 'name': name, 'description': description, 'link': link};

  factory ResumeProject.fromMap(Map<String, Object?> m) => ResumeProject(
        id: str(m['id']),
        name: str(m['name']),
        description: str(m['description']),
        link: str(m['link']),
      );
}

class LanguageSkill {
  const LanguageSkill({required this.id, this.name = '', this.level = ''});

  final String id;
  final String name;

  /// For example "Native", "Fluent", "Intermediate", "Basic".
  final String level;

  LanguageSkill copyWith({String? name, String? level}) =>
      LanguageSkill(id: id, name: name ?? this.name, level: level ?? this.level);

  Map<String, Object?> toMap() => {'id': id, 'name': name, 'level': level};

  factory LanguageSkill.fromMap(Map<String, Object?> m) => LanguageSkill(
        id: str(m['id']),
        name: str(m['name']),
        level: str(m['level']),
      );
}

enum ResumeFont {
  sans('Sans'),
  serif('Serif'),
  mono('Monospace');

  const ResumeFont(this.label);
  final String label;
}

enum ResumeLayout {
  single('Single column'),
  sidebar('Sidebar');

  const ResumeLayout(this.label);
  final String label;
}

/// User-chosen look of a resume: colors, fonts, layout and sections.
class ResumeCustomization {
  const ResumeCustomization({
    this.accentColor = 0xFF3478F6,
    this.font = ResumeFont.sans,
    this.layout = ResumeLayout.single,
    this.sectionOrder = ResumeSection.values,
    this.hiddenSections = const {},
  });

  final int accentColor;
  final ResumeFont font;
  final ResumeLayout layout;
  final List<ResumeSection> sectionOrder;
  final Set<ResumeSection> hiddenSections;

  List<ResumeSection> get visibleSections =>
      sectionOrder.where((s) => !hiddenSections.contains(s)).toList();

  ResumeCustomization copyWith({
    int? accentColor,
    ResumeFont? font,
    ResumeLayout? layout,
    List<ResumeSection>? sectionOrder,
    Set<ResumeSection>? hiddenSections,
  }) =>
      ResumeCustomization(
        accentColor: accentColor ?? this.accentColor,
        font: font ?? this.font,
        layout: layout ?? this.layout,
        sectionOrder: sectionOrder ?? this.sectionOrder,
        hiddenSections: hiddenSections ?? this.hiddenSections,
      );

  Map<String, Object?> toMap() => {
        'accentColor': accentColor,
        'font': font.name,
        'layout': layout.name,
        'sectionOrder': sectionOrder.map((s) => s.name).toList(),
        'hiddenSections': hiddenSections.map((s) => s.name).toList(),
      };

  factory ResumeCustomization.fromMap(Map<String, Object?> m) {
    final order = strList(m['sectionOrder'])
        .map((n) => enumOf(ResumeSection.values, n, ResumeSection.summary))
        .toSet()
        .toList();
    for (final s in ResumeSection.values) {
      if (!order.contains(s)) order.add(s);
    }
    return ResumeCustomization(
      accentColor: intOf(m['accentColor'], 0xFF3478F6),
      font: enumOf(ResumeFont.values, m['font'], ResumeFont.sans),
      layout: enumOf(ResumeLayout.values, m['layout'], ResumeLayout.single),
      sectionOrder: order,
      hiddenSections: strList(m['hiddenSections'])
          .map((n) => enumOf(ResumeSection.values, n, ResumeSection.summary))
          .toSet(),
    );
  }
}

/// `resumes` collection document.
class Resume {
  const Resume({
    required this.resumeId,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.personalInformation = const PersonalInfo(),
    this.education = const [],
    this.experience = const [],
    this.skills = const [],
    this.certifications = const [],
    this.projects = const [],
    this.languages = const [],
    this.templateId = 'classic',
    this.customization = const ResumeCustomization(),
    this.aiScore,
    this.isSample = false,
  });

  final String resumeId;
  final String userId;
  final String title;
  final PersonalInfo personalInformation;
  final List<Education> education;
  final List<Experience> experience;
  final List<String> skills;
  final List<Certification> certifications;
  final List<ResumeProject> projects;
  final List<LanguageSkill> languages;
  final String templateId;
  final ResumeCustomization customization;

  /// Latest AI analysis score out of 100, or null when not analyzed yet.
  final int? aiScore;

  /// True for the made-up resumes bundled with the app.
  final bool isSample;
  final DateTime createdAt;
  final DateTime updatedAt;

  Resume copyWith({
    String? resumeId,
    String? userId,
    String? title,
    PersonalInfo? personalInformation,
    List<Education>? education,
    List<Experience>? experience,
    List<String>? skills,
    List<Certification>? certifications,
    List<ResumeProject>? projects,
    List<LanguageSkill>? languages,
    String? templateId,
    ResumeCustomization? customization,
    int? aiScore,
    bool clearAiScore = false,
    bool? isSample,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Resume(
        resumeId: resumeId ?? this.resumeId,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        personalInformation: personalInformation ?? this.personalInformation,
        education: education ?? this.education,
        experience: experience ?? this.experience,
        skills: skills ?? this.skills,
        certifications: certifications ?? this.certifications,
        projects: projects ?? this.projects,
        languages: languages ?? this.languages,
        templateId: templateId ?? this.templateId,
        customization: customization ?? this.customization,
        aiScore: clearAiScore ? null : aiScore ?? this.aiScore,
        isSample: isSample ?? this.isSample,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  /// All user-written text in the resume, used by AI fabrication checks.
  String get plainText {
    final p = personalInformation;
    return [
      p.fullName,
      p.jobTitle,
      p.email,
      p.phone,
      p.location,
      p.website,
      p.summary,
      for (final e in experience) ...[
        e.role,
        e.company,
        e.location,
        e.startDate,
        e.endDate,
        e.description,
      ],
      for (final e in education) ...[
        e.degree,
        e.field,
        e.institution,
        e.startDate,
        e.endDate,
        e.description,
      ],
      ...skills,
      for (final c in certifications) ...[c.name, c.issuer, c.date],
      for (final p in projects) ...[p.name, p.description, p.link],
      for (final l in languages) ...[l.name, l.level],
    ].where((s) => s.trim().isNotEmpty).join('\n');
  }

  Map<String, Object?> toMap() => {
        'resumeId': resumeId,
        'userId': userId,
        'title': title,
        'personalInformation': personalInformation.toMap(),
        'education': education.map((e) => e.toMap()).toList(),
        'experience': experience.map((e) => e.toMap()).toList(),
        'skills': skills,
        'certifications': certifications.map((e) => e.toMap()).toList(),
        'projects': projects.map((e) => e.toMap()).toList(),
        'languages': languages.map((e) => e.toMap()).toList(),
        'templateId': templateId,
        'customization': customization.toMap(),
        'aiScore': aiScore,
        'isSample': isSample,
        'createdAt': dateToStr(createdAt),
        'updatedAt': dateToStr(updatedAt),
      };

  factory Resume.fromMap(Map<String, Object?> m) => Resume(
        resumeId: str(m['resumeId']),
        userId: str(m['userId']),
        title: str(m['title'], 'Untitled resume'),
        personalInformation: PersonalInfo.fromMap(asMap(m['personalInformation'])),
        education: mapList(m['education']).map(Education.fromMap).toList(),
        experience: mapList(m['experience']).map(Experience.fromMap).toList(),
        skills: strList(m['skills']),
        certifications:
            mapList(m['certifications']).map(Certification.fromMap).toList(),
        projects: mapList(m['projects']).map(ResumeProject.fromMap).toList(),
        languages: mapList(m['languages']).map(LanguageSkill.fromMap).toList(),
        templateId: str(m['templateId'], 'classic'),
        customization: ResumeCustomization.fromMap(asMap(m['customization'])),
        aiScore: intOrNull(m['aiScore']),
        isSample: boolOf(m['isSample']),
        createdAt: dateOf(m['createdAt']),
        updatedAt: dateOf(m['updatedAt']),
      );
}
