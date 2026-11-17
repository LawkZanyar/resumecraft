/// The professionally designed templates a resume can use.
class ResumeTemplate {
  const ResumeTemplate(this.id, this.name, this.description);

  final String id;
  final String name;
  final String description;
}

abstract final class ResumeTemplates {
  static const classic = ResumeTemplate(
    'classic',
    'Classic',
    'Centered header and ruled sections. Safe for any industry.',
  );
  static const modern = ResumeTemplate(
    'modern',
    'Modern',
    'Colored header band with bold section labels.',
  );
  static const minimal = ResumeTemplate(
    'minimal',
    'Minimal',
    'Quiet layout with generous white space.',
  );

  static const all = [classic, modern, minimal];

  static ResumeTemplate byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => classic);

  /// Accent colors offered in the customization panel.
  static const accentColors = <int>[
    0xFF3478F6,
    0xFF142B4A,
    0xFF24B8A0,
    0xFF7A4CD9,
    0xFFD9534F,
    0xFF3D3D3D,
  ];
}
