import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/labels.dart';
import '../../domain/ai_models.dart';

/// "Sample AI result" label shown whenever the offline engine produced a result.
class SampleAiLabel extends StatelessWidget {
  const SampleAiLabel({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Sample AI result',
    child: const Pill(
      text: 'Sample AI result',
      color: AppColors.warning,
      icon: Icons.science_outlined,
    ),
  );
}

/// Loading state for AI calls.
class AiLoadingView extends StatelessWidget {
  const AiLoadingView({super.key, this.message = 'AI is working on it…'});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(strokeWidth: 3, color: scheme.tertiary),
              ),
              Icon(Icons.auto_awesome, color: scheme.tertiary),
            ],
          ),
          AppSpacing.gapLg,
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Animated circular score out of 100.
class ScoreGauge extends StatelessWidget {
  const ScoreGauge({super.key, required this.score, this.size = 120, this.label});

  final int score;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.scoreColor(score);
    return Semantics(
      label: '${label ?? 'Score'} $score out of 100',
      child: SizedBox(
        width: size,
        height: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: score / 100),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, t, _) => Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: t,
                strokeWidth: size / 12,
                strokeCap: StrokeCap.round,
                color: color,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(t * 100).round()}',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(fontSize: size / 3.6),
                    ),
                    Text('/ 100', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A horizontal bar for a sub-score.
class ScoreBar extends StatelessWidget {
  const ScoreBar({super.key, required this.label, required this.value, required this.max});

  final String label;
  final int value;
  final int max;

  @override
  Widget build(BuildContext context) {
    final pct = max == 0 ? 0 : (value / max * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: max == 0 ? 0 : value / max,
                minHeight: 8,
                color: AppColors.scoreColor(pct),
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '$value/$max',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Titled list of recommendations, strengths or weaknesses.
class RecommendationList extends StatelessWidget {
  const RecommendationList({
    super.key,
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });

  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            AppSpacing.gapSm,
            for (final item in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 18, color: color),
                    AppSpacing.gapSm,
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shows an AI suggestion next to the original text with accept, edit and
/// reject actions. Nothing is saved until the user accepts.
class SuggestionCard extends StatefulWidget {
  const SuggestionCard({
    super.key,
    required this.suggestion,
    required this.onAccept,
    required this.onReject,
    this.isSample = true,
  });

  final TextSuggestion suggestion;
  final ValueChanged<String> onAccept;
  final VoidCallback onReject;
  final bool isSample;

  @override
  State<SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<SuggestionCard> {
  late final TextEditingController _edit = TextEditingController(
    text: widget.suggestion.suggestion,
  );
  bool _editing = false;

  @override
  void dispose() {
    _edit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.suggestion;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return AppCard(
      color: scheme.tertiaryContainer.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: scheme.tertiary),
              AppSpacing.gapSm,
              Expanded(child: Text('Suggestion', style: text.titleSmall)),
              if (widget.isSample) const SampleAiLabel(),
            ],
          ),
          AppSpacing.gapMd,
          if (_editing)
            TextField(
              key: const Key('suggestion_edit_field'),
              controller: _edit,
              maxLines: null,
              decoration: const InputDecoration(labelText: 'Edit before accepting'),
            )
          else
            SelectableText(s.suggestion.isEmpty ? '(No change suggested)' : s.suggestion),
          if (s.flags.isNotEmpty) ...[
            AppSpacing.gapMd,
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Check these details: they were not in your text',
                    style: text.labelLarge?.copyWith(color: AppColors.warning),
                  ),
                  for (final f in s.flags) Text('• "${f.text}": ${f.reason}'),
                ],
              ),
            ),
          ],
          if (s.notes != null) ...[AppSpacing.gapSm, Text(s.notes!, style: text.bodySmall)],
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('Show original', style: text.bodySmall),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(s.original, style: text.bodySmall),
              ),
            ],
          ),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: AppSpacing.sm,
            children: [
              TextButton.icon(
                key: const Key('suggestion_reject'),
                onPressed: widget.onReject,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Reject'),
              ),
              TextButton.icon(
                key: const Key('suggestion_edit'),
                onPressed: () => setState(() => _editing = !_editing),
                icon: const Icon(Icons.edit_outlined),
                label: Text(_editing ? 'Done editing' : 'Edit'),
              ),
              FilledButton.icon(
                key: const Key('suggestion_accept'),
                onPressed: () => widget.onAccept(_editing ? _edit.text : s.suggestion),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Accept'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
