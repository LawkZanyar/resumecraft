import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/domain/domain.dart';
import 'editor_fields.dart';

typedef DraftEdit = void Function(Resume Function(Resume draft) change);

/// Common inputs of every step.
abstract class EditorStep extends StatelessWidget {
  const EditorStep({super.key, required this.draft, required this.edit, required this.newId});

  final Resume draft;
  final DraftEdit edit;
  final String Function() newId;
}

List<T> _replace<T>(List<T> list, int i, T value) => [...list]..[i] = value;
List<T> _remove<T>(List<T> list, int i) => [...list]..removeAt(i);

class BasicsStep extends EditorStep {
  const BasicsStep({super.key, required super.draft, required super.edit, required super.newId});

  @override
  Widget build(BuildContext context) {
    final p = draft.personalInformation;
    void set(PersonalInfo Function(PersonalInfo p) f) =>
        edit((d) => d.copyWith(personalInformation: f(d.personalInformation)));
    return Column(
      children: [
        const StepIntro('Start with the basics. Only your name and a resume title are required.'),
        DraftField(
          key: const Key('field_title'),
          label: 'Resume title',
          hint: 'For example: Product Designer resume',
          initialValue: draft.title,
          validator: (v) => Validators.required(v, field: 'Title'),
          onChanged: (v) => edit((d) => d.copyWith(title: v)),
        ),
        DraftField(
          key: const Key('field_full_name'),
          label: 'Full name',
          initialValue: p.fullName,
          capitalization: TextCapitalization.words,
          validator: Validators.name,
          onChanged: (v) => set((p) => p.copyWith(fullName: v)),
        ),
        DraftField(
          label: 'Job title',
          initialValue: p.jobTitle,
          capitalization: TextCapitalization.words,
          onChanged: (v) => set((p) => p.copyWith(jobTitle: v)),
        ),
        DraftField(
          label: 'Email',
          initialValue: p.email,
          keyboardType: TextInputType.emailAddress,
          capitalization: TextCapitalization.none,
          validator: Validators.optionalEmail,
          onChanged: (v) => set((p) => p.copyWith(email: v)),
        ),
        DraftField(
          label: 'Phone',
          initialValue: p.phone,
          keyboardType: TextInputType.phone,
          validator: Validators.optionalPhone,
          onChanged: (v) => set((p) => p.copyWith(phone: v)),
        ),
        DraftField(
          label: 'Location',
          initialValue: p.location,
          onChanged: (v) => set((p) => p.copyWith(location: v)),
        ),
        DraftField(
          label: 'Website or portfolio',
          initialValue: p.website,
          keyboardType: TextInputType.url,
          capitalization: TextCapitalization.none,
          validator: Validators.optionalUrl,
          onChanged: (v) => set((p) => p.copyWith(website: v)),
        ),
        DraftField(
          label: 'Professional summary',
          initialValue: p.summary,
          maxLines: 5,
          validator: (v) => Validators.maxLength(v, 800),
          onChanged: (v) => set((p) => p.copyWith(summary: v)),
        ),
      ],
    );
  }
}

class ExperienceStep extends EditorStep {
  const ExperienceStep({super.key, required super.draft, required super.edit, required super.newId});

  @override
  Widget build(BuildContext context) {
    final list = draft.experience;
    void set(int i, Experience e) => edit((d) => d.copyWith(experience: _replace(d.experience, i, e)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepIntro('Add your jobs, internships and volunteer roles, newest first. '
            'Write one achievement per line.'),
        for (var i = 0; i < list.length; i++)
          EntryCard(
            key: ValueKey(list[i].id),
            title: list[i].role.isEmpty ? 'New experience' : list[i].role,
            onDelete: () => edit((d) => d.copyWith(experience: _remove(d.experience, i))),
            children: [
              DraftField(
                label: 'Role',
                initialValue: list[i].role,
                capitalization: TextCapitalization.words,
                validator: (v) => Validators.required(v, field: 'Role'),
                onChanged: (v) => set(i, draft.experience[i].copyWith(role: v)),
              ),
              DraftField(
                label: 'Company or organization',
                initialValue: list[i].company,
                capitalization: TextCapitalization.words,
                validator: (v) => Validators.required(v, field: 'Company'),
                onChanged: (v) => set(i, draft.experience[i].copyWith(company: v)),
              ),
              DraftField(
                label: 'Location',
                initialValue: list[i].location,
                onChanged: (v) => set(i, draft.experience[i].copyWith(location: v)),
              ),
              FieldPair(
                left: DraftField(
                  label: 'Start',
                  hint: 'Mar 2023',
                  initialValue: list[i].startDate,
                  onChanged: (v) => set(i, draft.experience[i].copyWith(startDate: v)),
                ),
                right: DraftField(
                  label: 'End',
                  hint: 'Jun 2024',
                  initialValue: list[i].endDate,
                  onChanged: (v) => set(i, draft.experience[i].copyWith(endDate: v)),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('I currently work here'),
                value: list[i].isCurrent,
                onChanged: (v) => set(i, draft.experience[i].copyWith(isCurrent: v)),
              ),
              DraftField(
                label: 'What you did and achieved',
                initialValue: list[i].description,
                maxLines: 6,
                onChanged: (v) => set(i, draft.experience[i].copyWith(description: v)),
              ),
            ],
          ),
        AddEntryButton(
          label: 'Add experience',
          onPressed: () => edit((d) => d.copyWith(experience: [...d.experience, Experience(id: newId())])),
        ),
      ],
    );
  }
}

class EducationStep extends EditorStep {
  const EducationStep({super.key, required super.draft, required super.edit, required super.newId});

  @override
  Widget build(BuildContext context) {
    final list = draft.education;
    void set(int i, Education e) => edit((d) => d.copyWith(education: _replace(d.education, i, e)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepIntro('Add degrees, diplomas and courses.'),
        for (var i = 0; i < list.length; i++)
          EntryCard(
            key: ValueKey(list[i].id),
            title: list[i].institution.isEmpty ? 'New education' : list[i].institution,
            onDelete: () => edit((d) => d.copyWith(education: _remove(d.education, i))),
            children: [
              DraftField(
                label: 'School or university',
                initialValue: list[i].institution,
                capitalization: TextCapitalization.words,
                validator: (v) => Validators.required(v, field: 'School'),
                onChanged: (v) => set(i, draft.education[i].copyWith(institution: v)),
              ),
              FieldPair(
                left: DraftField(
                  label: 'Degree',
                  hint: 'BSc',
                  initialValue: list[i].degree,
                  onChanged: (v) => set(i, draft.education[i].copyWith(degree: v)),
                ),
                right: DraftField(
                  label: 'Field of study',
                  initialValue: list[i].field,
                  onChanged: (v) => set(i, draft.education[i].copyWith(field: v)),
                ),
              ),
              FieldPair(
                left: DraftField(
                  label: 'Start',
                  initialValue: list[i].startDate,
                  onChanged: (v) => set(i, draft.education[i].copyWith(startDate: v)),
                ),
                right: DraftField(
                  label: 'End',
                  initialValue: list[i].endDate,
                  onChanged: (v) => set(i, draft.education[i].copyWith(endDate: v)),
                ),
              ),
              DraftField(
                label: 'Details (optional)',
                initialValue: list[i].description,
                maxLines: 3,
                onChanged: (v) => set(i, draft.education[i].copyWith(description: v)),
              ),
            ],
          ),
        AddEntryButton(
          label: 'Add education',
          onPressed: () => edit((d) => d.copyWith(education: [...d.education, Education(id: newId())])),
        ),
      ],
    );
  }
}

class SkillsStep extends StatefulWidget {
  const SkillsStep({super.key, required this.draft, required this.edit});

  final Resume draft;
  final DraftEdit edit;

  @override
  State<SkillsStep> createState() => _SkillsStepState();
}

class _SkillsStepState extends State<SkillsStep> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _add() {
    final parts = _input.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
    if (parts.isEmpty) return;
    widget.edit((d) {
      final existing = d.skills.map((s) => s.toLowerCase()).toSet();
      return d.copyWith(skills: [
        ...d.skills,
        for (final p in parts)
          if (!existing.contains(p.toLowerCase())) p,
      ]);
    });
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final skills = widget.draft.skills;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepIntro('List tools, technologies and strengths you can show evidence of. '
            'Separate several with commas.'),
        TextField(
          key: const Key('skill_input'),
          controller: _input,
          onSubmitted: (_) => _add(),
          decoration: InputDecoration(
            labelText: 'Add a skill',
            suffixIcon: IconButton(
              key: const Key('skill_add'),
              tooltip: 'Add skill',
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _add,
            ),
          ),
        ),
        AppSpacing.gapLg,
        if (skills.isEmpty)
          Text('No skills yet.', style: Theme.of(context).textTheme.bodySmall)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in skills)
                InputChip(
                  label: Text(s),
                  onDeleted: () => widget.edit(
                    (d) => d.copyWith(skills: d.skills.where((x) => x != s).toList()),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class ProjectsStep extends EditorStep {
  const ProjectsStep({super.key, required super.draft, required super.edit, required super.newId});

  @override
  Widget build(BuildContext context) {
    final list = draft.projects;
    void set(int i, ResumeProject e) => edit((d) => d.copyWith(projects: _replace(d.projects, i, e)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepIntro('Projects show what you can do. Add personal, university or work projects.'),
        for (var i = 0; i < list.length; i++)
          EntryCard(
            key: ValueKey(list[i].id),
            title: list[i].name.isEmpty ? 'New project' : list[i].name,
            onDelete: () => edit((d) => d.copyWith(projects: _remove(d.projects, i))),
            children: [
              DraftField(
                label: 'Project name',
                initialValue: list[i].name,
                validator: (v) => Validators.required(v, field: 'Project name'),
                onChanged: (v) => set(i, draft.projects[i].copyWith(name: v)),
              ),
              DraftField(
                label: 'Description',
                initialValue: list[i].description,
                maxLines: 4,
                onChanged: (v) => set(i, draft.projects[i].copyWith(description: v)),
              ),
              DraftField(
                label: 'Link (optional)',
                initialValue: list[i].link,
                capitalization: TextCapitalization.none,
                validator: Validators.optionalUrl,
                onChanged: (v) => set(i, draft.projects[i].copyWith(link: v)),
              ),
            ],
          ),
        AddEntryButton(
          label: 'Add project',
          onPressed: () => edit((d) => d.copyWith(projects: [...d.projects, ResumeProject(id: newId())])),
        ),
      ],
    );
  }
}

class CertificationsStep extends EditorStep {
  const CertificationsStep({super.key, required super.draft, required super.edit, required super.newId});

  @override
  Widget build(BuildContext context) {
    final list = draft.certifications;
    void set(int i, Certification e) =>
        edit((d) => d.copyWith(certifications: _replace(d.certifications, i, e)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepIntro('Add certificates and licenses you actually hold.'),
        for (var i = 0; i < list.length; i++)
          EntryCard(
            key: ValueKey(list[i].id),
            title: list[i].name.isEmpty ? 'New certification' : list[i].name,
            onDelete: () => edit((d) => d.copyWith(certifications: _remove(d.certifications, i))),
            children: [
              DraftField(
                label: 'Certificate name',
                initialValue: list[i].name,
                validator: (v) => Validators.required(v, field: 'Certificate name'),
                onChanged: (v) => set(i, draft.certifications[i].copyWith(name: v)),
              ),
              FieldPair(
                left: DraftField(
                  label: 'Issuer',
                  initialValue: list[i].issuer,
                  onChanged: (v) => set(i, draft.certifications[i].copyWith(issuer: v)),
                ),
                right: DraftField(
                  label: 'Date',
                  initialValue: list[i].date,
                  onChanged: (v) => set(i, draft.certifications[i].copyWith(date: v)),
                ),
              ),
            ],
          ),
        AddEntryButton(
          label: 'Add certification',
          onPressed: () =>
              edit((d) => d.copyWith(certifications: [...d.certifications, Certification(id: newId())])),
        ),
      ],
    );
  }
}

class LanguagesStep extends EditorStep {
  const LanguagesStep({super.key, required super.draft, required super.edit, required super.newId});

  static const levels = ['Native', 'Fluent', 'Advanced', 'Intermediate', 'Basic'];

  @override
  Widget build(BuildContext context) {
    final list = draft.languages;
    void set(int i, LanguageSkill e) => edit((d) => d.copyWith(languages: _replace(d.languages, i, e)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepIntro('Which languages do you speak?'),
        for (var i = 0; i < list.length; i++)
          EntryCard(
            key: ValueKey(list[i].id),
            title: list[i].name.isEmpty ? 'New language' : list[i].name,
            onDelete: () => edit((d) => d.copyWith(languages: _remove(d.languages, i))),
            children: [
              DraftField(
                label: 'Language',
                initialValue: list[i].name,
                capitalization: TextCapitalization.words,
                validator: (v) => Validators.required(v, field: 'Language'),
                onChanged: (v) => set(i, draft.languages[i].copyWith(name: v)),
              ),
              DropdownButtonFormField<String>(
                initialValue: levels.contains(list[i].level) ? list[i].level : null,
                decoration: const InputDecoration(labelText: 'Level'),
                items: [for (final l in levels) DropdownMenuItem(value: l, child: Text(l))],
                onChanged: (v) => set(i, draft.languages[i].copyWith(level: v ?? '')),
              ),
            ],
          ),
        AddEntryButton(
          label: 'Add language',
          onPressed: () => edit((d) => d.copyWith(languages: [...d.languages, LanguageSkill(id: newId())])),
        ),
      ],
    );
  }
}
