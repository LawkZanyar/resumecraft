import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/domain/domain.dart';
import '../../../ai/domain/ai_models.dart';
import '../../../ai/presentation/ai_providers.dart';
import '../../../ai/presentation/widgets/ai_widgets.dart';
import '../../../resume/presentation/resume_providers.dart';
import '../widgets/resume_picker.dart';

/// One piece of resume text the AI can improve.
class ImproveItem {
  const ImproveItem({
    required this.key,
    required this.label,
    required this.text,
    required this.apply,
    this.role = '',
    this.company = '',
  });

  final String key;
  final String label;
  final String text;
  final Resume Function(Resume resume, String newText) apply;
  final String role;
  final String company;

  bool get isExperience => role.isNotEmpty || company.isNotEmpty;
}

List<ImproveItem> improveItemsFor(Resume r) => [
  ImproveItem(
    key: 'summary',
    label: 'Professional summary',
    text: r.personalInformation.summary,
    apply: (r, t) => r.copyWith(personalInformation: r.personalInformation.copyWith(summary: t)),
  ),
  for (final e in r.experience)
    ImproveItem(
      key: 'exp-${e.id}',
      label: [e.role, e.company].where((s) => s.isNotEmpty).join(' at '),
      text: e.description,
      role: e.role,
      company: e.company,
      apply: (r, t) => r.copyWith(
        experience: [for (final x in r.experience) x.id == e.id ? x.copyWith(description: t) : x],
      ),
    ),
  for (final p in r.projects)
    ImproveItem(
      key: 'proj-${p.id}',
      label: 'Project: ${p.name}',
      text: p.description,
      apply: (r, t) => r.copyWith(
        projects: [for (final x in r.projects) x.id == p.id ? x.copyWith(description: t) : x],
      ),
    ),
];

enum _Action { rewrite, grammar, generate }

/// Rewrite, grammar correction and description generation, with review.
class ImproveResumeScreen extends ConsumerStatefulWidget {
  const ImproveResumeScreen({super.key});

  @override
  ConsumerState<ImproveResumeScreen> createState() => _ImproveResumeScreenState();
}

class _ImproveResumeScreenState extends ConsumerState<ImproveResumeScreen> {
  Resume? _resume;
  final Map<String, AsyncValue<TextSuggestion>> _results = {};

  Future<void> _run(ImproveItem item, _Action action) async {
    final ai = ref.read(aiServiceProvider);
    var notes = item.text;
    if (action == _Action.generate) {
      final typed = await _askNotes(item);
      if (typed == null || typed.trim().isEmpty) return;
      notes = typed;
    }
    setState(() => _results[item.key] = const AsyncLoading());
    final out = switch (action) {
      _Action.rewrite => await ai.rewriteText(item.text, context: item.label),
      _Action.grammar => await ai.correctGrammar(item.text),
      _Action.generate => await ai.generateDescription(
        role: item.role,
        company: item.company,
        notes: notes,
      ),
    };
    if (!mounted) return;
    setState(() {
      _results[item.key] = out.when(
        ok: AsyncData.new,
        err: (f) => AsyncError(f, StackTrace.current),
      );
    });
  }

  Future<String?> _askNotes(ImproveItem item) {
    final c = TextEditingController(text: item.text);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('What did you do in this role?'),
        content: TextField(
          controller: c,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Rough notes are fine, e.g. "answered customer emails, made weekly reports"',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Generate')),
        ],
      ),
    );
  }

  Future<void> _accept(ImproveItem item, String text) async {
    final r = _resume;
    if (r == null) return;
    final result = await ref.read(resumeRepositoryProvider).saveResume(item.apply(r, text));
    if (!mounted) return;
    result.when(
      ok: (saved) {
        setState(() {
          _resume = saved;
          _results.remove(item.key);
        });
        showAppSnackBar(context, 'Change saved to your resume');
      },
      err: (f) => showAppSnackBar(context, f.message, error: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSample = ref.watch(aiServiceProvider).isSample;
    final r = _resume;
    return Scaffold(
      appBar: AppBar(title: const Text('Improve resume')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          ResumePicker(
            selectedId: r?.resumeId,
            onChanged: (x) => setState(() {
              _resume = x;
              _results.clear();
            }),
          ),
          AppSpacing.gapLg,
          if (r != null)
            for (final item in improveItemsFor(r))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(item.label, style: Theme.of(context).textTheme.titleSmall),
                      AppSpacing.gapSm,
                      Text(
                        item.text.isEmpty ? 'Nothing written yet.' : item.text,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      AppSpacing.gapSm,
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: [
                          if (item.text.isNotEmpty) ...[
                            ActionChip(
                              key: Key('rewrite_${item.key}'),
                              avatar: const Icon(Icons.auto_fix_high_rounded, size: 18),
                              label: const Text('Rewrite'),
                              onPressed: () => _run(item, _Action.rewrite),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.spellcheck_rounded, size: 18),
                              label: const Text('Fix grammar'),
                              onPressed: () => _run(item, _Action.grammar),
                            ),
                          ],
                          if (item.isExperience)
                            ActionChip(
                              avatar: const Icon(Icons.edit_note_rounded, size: 18),
                              label: const Text('Generate from notes'),
                              onPressed: () => _run(item, _Action.generate),
                            ),
                        ],
                      ),
                      if (_results[item.key] case final res?)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: res.when(
                            loading: () => const AiLoadingView(),
                            error: (e, _) => ErrorView(error: e),
                            data: (s) => SuggestionCard(
                              key: ValueKey(s.suggestion),
                              suggestion: s,
                              isSample: isSample,
                              onAccept: (t) => _accept(item, t),
                              onReject: () => setState(() => _results.remove(item.key)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
