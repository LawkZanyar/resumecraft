import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/domain/domain.dart';
import '../../../ai/presentation/widgets/ai_widgets.dart';

/// Per-answer scores, what went well, what to improve and a stronger example.
class AnswerFeedback extends StatelessWidget {
  const AnswerFeedback({super.key, required this.evaluation, this.isSample = true});

  final AnswerEvaluation evaluation;
  final bool isSample;

  @override
  Widget build(BuildContext context) {
    final e = evaluation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            children: [
              if (isSample) const Align(alignment: Alignment.centerRight, child: SampleAiLabel()),
              Row(
                children: [
                  ScoreGauge(key: const Key('answer_score'), score: e.score, size: 86),
                  AppSpacing.gapLg,
                  Expanded(
                    child: Column(
                      children: [
                        ScoreBar(label: 'Relevance', value: e.relevance, max: 10),
                        ScoreBar(label: 'Clarity', value: e.clarity, max: 10),
                        ScoreBar(label: 'Confidence*', value: e.confidence, max: 10),
                        ScoreBar(label: 'Completeness', value: e.completeness, max: 10),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.gapSm,
              Text(
                '*Confidence is judged from wording only (for example hedging words), '
                'not from your voice or emotions.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        AppSpacing.gapMd,
        RecommendationList(
          title: 'What went well',
          items: e.wentWell,
          icon: Icons.thumb_up_alt_outlined,
          color: AppColors.success,
        ),
        RecommendationList(
          title: 'What to improve',
          items: e.toImprove,
          icon: Icons.trending_up_rounded,
          color: AppColors.secondary,
        ),
        if (e.strongerAnswer.isNotEmpty)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A stronger structure, using your own words',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                AppSpacing.gapSm,
                Text(e.strongerAnswer),
                AppSpacing.gapSm,
                Text(
                  'Replace any [bracketed] part with something true from your experience.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
