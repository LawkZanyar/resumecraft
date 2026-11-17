import 'package:flutter/material.dart';

import '../../../../shared/domain/domain.dart';

/// A4 width in PDF points; the preview is laid out at this width and scaled.
const double a4Width = 595;
const double a4Height = 842;

/// Renders a resume with its template and customization as a printable page.
/// The PDF builder (Phase 2) mirrors this layout.
class ResumeDocument extends StatelessWidget {
  const ResumeDocument({super.key, required this.resume, this.fixedPage = false});

  final Resume resume;

  /// When true, clip to one A4 page (used for thumbnails).
  final bool fixedPage;

  @override
  Widget build(BuildContext context) {
    final page = Container(
      width: a4Width,
      constraints: BoxConstraints(
        minHeight: a4Height,
        maxHeight: fixedPage ? a4Height : double.infinity,
      ),
      color: Colors.white,
      child: DefaultTextStyle(
        style: TextStyle(
          color: const Color(0xFF222831),
          fontSize: 9.5,
          height: 1.35,
          fontFamily: _fontFamily(resume.customization.font),
        ),
        child: _TemplateBody(resume: resume),
      ),
    );
    return FittedBox(
      fit: BoxFit.fitWidth,
      alignment: Alignment.topCenter,
      child: fixedPage ? ClipRect(child: page) : page,
    );
  }

  static String? _fontFamily(ResumeFont font) => switch (font) {
    ResumeFont.sans => null,
    ResumeFont.serif => 'serif',
    ResumeFont.mono => 'monospace',
  };
}

enum _Header { centered, band, left }

class _TemplateBody extends StatelessWidget {
  const _TemplateBody({required this.resume});

  final Resume resume;

  _Header get _header => switch (resume.templateId) {
    'modern' => _Header.band,
    'minimal' => _Header.left,
    _ => _Header.centered,
  };

  static const _sidebarSections = {
    ResumeSection.skills,
    ResumeSection.languages,
    ResumeSection.certifications,
  };

  @override
  Widget build(BuildContext context) {
    final c = resume.customization;
    final accent = Color(c.accentColor);
    final visible = c.visibleSections;
    final sidebar = c.layout == ResumeLayout.sidebar;
    final main = sidebar ? visible.where((s) => !_sidebarSections.contains(s)) : visible;
    final side = sidebar ? visible.where(_sidebarSections.contains) : const <ResumeSection>[];

    final mainColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final s in main) ..._section(s, accent)],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(accent),
        Padding(
          padding: const EdgeInsets.fromLTRB(36, 8, 36, 36),
          child: sidebar
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [for (final s in side) ..._section(s, accent)],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(child: mainColumn),
                  ],
                )
              : mainColumn,
        ),
      ],
    );
  }

  Widget _buildHeader(Color accent) {
    final p = resume.personalInformation;
    final contact = [
      p.email,
      p.phone,
      p.location,
      p.website,
    ].where((s) => s.trim().isNotEmpty).join('  |  ');
    final name = p.fullName.isEmpty ? 'Your Name' : p.fullName;
    switch (_header) {
      case _Header.band:
        return Container(
          color: accent,
          padding: const EdgeInsets.fromLTRB(36, 30, 36, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (p.jobTitle.isNotEmpty)
                Text(p.jobTitle, style: const TextStyle(fontSize: 12, color: Colors.white)),
              if (contact.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(contact, style: const TextStyle(fontSize: 8.5, color: Colors.white)),
              ],
            ],
          ),
        );
      case _Header.centered:
        return Padding(
          padding: const EdgeInsets.fromLTRB(36, 32, 36, 8),
          child: Column(
            children: [
              Text(
                name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: accent),
              ),
              if (p.jobTitle.isNotEmpty) Text(p.jobTitle, style: const TextStyle(fontSize: 11.5)),
              if (contact.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(contact, textAlign: TextAlign.center, style: const TextStyle(fontSize: 8.5)),
              ],
              const SizedBox(height: 8),
              Container(height: 1.4, color: accent),
            ],
          ),
        );
      case _Header.left:
        return Padding(
          padding: const EdgeInsets.fromLTRB(36, 36, 36, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5,
                ),
              ),
              if (p.jobTitle.isNotEmpty)
                Text(p.jobTitle, style: TextStyle(fontSize: 11.5, color: accent)),
              if (contact.isNotEmpty)
                Text(contact, style: const TextStyle(fontSize: 8.5, color: Color(0xFF6B7280))),
            ],
          ),
        );
    }
  }

  Widget _title(String text, Color accent) {
    final style = TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
      color: _header == _Header.left ? const Color(0xFF374151) : accent,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: switch (_header) {
        _Header.centered => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(text.toUpperCase(), style: style),
            Container(
              height: 0.8,
              color: accent.withValues(alpha: 0.5),
              margin: const EdgeInsets.only(top: 2),
            ),
          ],
        ),
        _Header.band => Row(
          children: [
            Container(width: 4, height: 12, color: accent, margin: const EdgeInsets.only(right: 6)),
            Text(text.toUpperCase(), style: style),
          ],
        ),
        _Header.left => Text(
          text,
          style: style.copyWith(color: accent, letterSpacing: 0.3, fontSize: 11.5),
        ),
      },
    );
  }

  List<Widget> _section(ResumeSection s, Color accent) {
    final r = resume;
    Widget entry(String head, String sub, String dates, String body) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(head, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              if (dates.isNotEmpty)
                Text(dates, style: const TextStyle(fontSize: 8.5, color: Color(0xFF6B7280))),
            ],
          ),
          if (sub.isNotEmpty) Text(sub, style: const TextStyle(fontStyle: FontStyle.italic)),
          if (body.isNotEmpty)
            for (final line in body.split('\n').where((l) => l.trim().isNotEmpty))
              Text('•  ${line.trim()}'),
        ],
      ),
    );
    String range(String a, String b, {bool current = false}) =>
        [a, current ? 'Present' : b].where((x) => x.isNotEmpty).join(' – ');

    switch (s) {
      case ResumeSection.summary:
        final t = r.personalInformation.summary;
        return t.isEmpty ? const [] : [_title(s.label, accent), Text(t)];
      case ResumeSection.experience:
        if (r.experience.isEmpty) return const [];
        return [
          _title(s.label, accent),
          for (final e in r.experience)
            entry(
              e.role,
              [e.company, e.location].where((x) => x.isNotEmpty).join(', '),
              range(e.startDate, e.endDate, current: e.isCurrent),
              e.description,
            ),
        ];
      case ResumeSection.education:
        if (r.education.isEmpty) return const [];
        return [
          _title(s.label, accent),
          for (final e in r.education)
            entry(
              [e.degree, e.field].where((x) => x.isNotEmpty).join(', '),
              e.institution,
              range(e.startDate, e.endDate),
              e.description,
            ),
        ];
      case ResumeSection.skills:
        if (r.skills.isEmpty) return const [];
        return [_title(s.label, accent), Text(r.skills.join('  •  '))];
      case ResumeSection.projects:
        if (r.projects.isEmpty) return const [];
        return [
          _title(s.label, accent),
          for (final p in r.projects) entry(p.name, p.link, '', p.description),
        ];
      case ResumeSection.certifications:
        if (r.certifications.isEmpty) return const [];
        return [
          _title(s.label, accent),
          for (final c in r.certifications)
            Text([c.name, c.issuer, c.date].where((x) => x.isNotEmpty).join(' — ')),
        ];
      case ResumeSection.languages:
        if (r.languages.isEmpty) return const [];
        return [
          _title(s.label, accent),
          for (final l in r.languages) Text(l.level.isEmpty ? l.name : '${l.name} (${l.level})'),
        ];
    }
  }
}
