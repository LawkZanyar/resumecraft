import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/domain/domain.dart';
import '../../domain/resume_templates.dart';
import '../resume_providers.dart';
import '../templates/resume_document.dart';

/// Customization panel: colors, fonts, layout and sections, with live preview.
class CustomizeScreen extends ConsumerStatefulWidget {
  const CustomizeScreen({super.key, required this.resumeId});

  final String resumeId;

  @override
  ConsumerState<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends ConsumerState<CustomizeScreen> {
  Resume? _draft;
  bool _saving = false;

  void _set(ResumeCustomization Function(ResumeCustomization c) f) => setState(
        () => _draft = _draft!.copyWith(customization: f(_draft!.customization)),
      );

  Future<void> _save() async {
    setState(() => _saving = true);
    final r = await ref.read(resumeRepositoryProvider).saveResume(_draft!);
    if (!mounted) return;
    setState(() => _saving = false);
    showAppSnackBar(context, r.isOk ? 'Customization saved' : 'Could not save', error: !r.isOk);
    if (r.isOk) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final source = ref.watch(resumeByIdProvider(widget.resumeId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize'),
        actions: [
          TextButton(
            onPressed: _draft == null || _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: AsyncValueView(
        value: source,
        data: (r) {
          if (r == null) {
            return const EmptyView(icon: Icons.search_off_rounded, title: 'Resume not found');
          }
          _draft ??= r;
          final draft = _draft!;
          final c = draft.customization;
          return Column(
            children: [
              Container(
                height: 230,
                width: double.infinity,
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: a4Width / a4Height,
                    child: Material(
                      elevation: 2,
                      child: ResumeDocument(resume: draft, fixedPage: true),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: AppSpacing.page,
                  children: [
                    const SectionHeader('Template'),
                    SegmentedButton<String>(
                      segments: [
                        for (final t in ResumeTemplates.all)
                          ButtonSegment(value: t.id, label: Text(t.name)),
                      ],
                      selected: {draft.templateId},
                      onSelectionChanged: (s) =>
                          setState(() => _draft = draft.copyWith(templateId: s.first)),
                    ),
                    const SectionHeader('Accent color'),
                    Wrap(
                      spacing: 12,
                      children: [
                        for (final color in ResumeTemplates.accentColors)
                          Semantics(
                            label: 'Accent color',
                            selected: color == c.accentColor,
                            child: GestureDetector(
                              onTap: () => _set((c) => c.copyWith(accentColor: color)),
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Color(color),
                                child: color == c.accentColor
                                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                                    : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SectionHeader('Font'),
                    SegmentedButton<ResumeFont>(
                      segments: [
                        for (final f in ResumeFont.values) ButtonSegment(value: f, label: Text(f.label)),
                      ],
                      selected: {c.font},
                      onSelectionChanged: (s) => _set((c) => c.copyWith(font: s.first)),
                    ),
                    const SectionHeader('Layout'),
                    SegmentedButton<ResumeLayout>(
                      segments: [
                        for (final l in ResumeLayout.values) ButtonSegment(value: l, label: Text(l.label)),
                      ],
                      selected: {c.layout},
                      onSelectionChanged: (s) => _set((c) => c.copyWith(layout: s.first)),
                    ),
                    const SectionHeader('Sections'),
                    Text(
                      'Drag to reorder. Switch off sections you do not want to show.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    AppSpacing.gapSm,
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: ReorderableListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        onReorder: (from, to) => _set((c) {
                          final order = [...c.sectionOrder];
                          final item = order.removeAt(from);
                          order.insert(to > from ? to - 1 : to, item);
                          return c.copyWith(sectionOrder: order);
                        }),
                        children: [
                          for (var i = 0; i < c.sectionOrder.length; i++)
                            SwitchListTile(
                              key: ValueKey(c.sectionOrder[i]),
                              secondary: ReorderableDragStartListener(
                                index: i,
                                child: const Icon(Icons.drag_indicator_rounded),
                              ),
                              title: Text(c.sectionOrder[i].label),
                              value: !c.hiddenSections.contains(c.sectionOrder[i]),
                              onChanged: (on) => _set((c) {
                                final hidden = {...c.hiddenSections};
                                on ? hidden.remove(c.sectionOrder[i]) : hidden.add(c.sectionOrder[i]);
                                return c.copyWith(hiddenSections: hidden);
                              }),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
