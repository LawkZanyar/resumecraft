import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/labels.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/domain/domain.dart';
import '../../../ai/presentation/ai_providers.dart';
import '../../../ai/presentation/widgets/ai_widgets.dart';
import '../interview_providers.dart';
import '../widgets/answer_feedback.dart';

/// Final performance report for a saved session.
class InterviewReportScreen extends ConsumerWidget {
  const InterviewReportScreen({super.key, required this.sessionId});

  final String? sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(interviewSessionsProvider);
    final isSample = ref.watch(aiServiceProvider).isSample;
    return Scaffold(
      appBar: AppBar(title: const Text('Interview report')),
      body: AsyncValueView<List<InterviewSession>>(
        value: sessions,
        data: (list) {
          final s = list.where((x) => x.sessionId == sessionId).firstOrNull;
          if (s == null) {
            return const EmptyView(icon: Icons.search_off_rounded, title: 'Session not found');
          }
          final report = s.evaluation;
          return ListView(
            padding: AppSpacing.page,
            children: [
              AppCard(
                child: Column(
                  children: [
                    if (isSample)
                      const Align(alignment: Alignment.centerRight, child: SampleAiLabel()),
                    Text(s.jobTitle, style: Theme.of(context).textTheme.titleLarge),
                    Text(
                      '${s.category} · ${Formatters.dateTime(s.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    AppSpacing.gapLg,
                    ScoreGauge(
                      key: const Key('report_score'),
                      score: s.overallScore ?? 0,
                      size: 140,
                    ),
                    AppSpacing.gapMd,
                    if (report != null) Text(report.summary, textAlign: TextAlign.center),
                  ],
                ),
              ),
              AppSpacing.gapMd,
              if (report != null) ...[
                RecommendationList(
                  title: 'Strengths',
                  items: report.strengths,
                  icon: Icons.star_outline_rounded,
                  color: AppColors.success,
                ),
                RecommendationList(
                  title: 'Focus next time on',
                  items: report.improvements,
                  icon: Icons.flag_outlined,
                  color: AppColors.secondary,
                ),
              ],
              const SectionHeader('Answers'),
              for (final q in s.questions)
                if (s.answers.where((a) => a.questionId == q.id).firstOrNull case final a?)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      padding: EdgeInsets.zero,
                      child: ExpansionTile(
                        title: Text(q.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text(q.type.label),
                        trailing: a.evaluation == null
                            ? null
                            : Pill(
                                text: '${a.evaluation!.score}',
                                color: AppColors.scoreColor(a.evaluation!.score),
                              ),
                        childrenPadding: const EdgeInsets.all(AppSpacing.md),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('You said: ${a.text}'),
                          ),
                          AppSpacing.gapMd,
                          if (a.evaluation != null)
                            AnswerFeedback(evaluation: a.evaluation!, isSample: isSample),
                        ],
                      ),
                    ),
                  ),
              AppSpacing.gapLg,
              FilledButton.icon(
                onPressed: () {
                  ref.read(interviewControllerProvider.notifier).reset();
                  context.go(Routes.interview);
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Practice again'),
              ),
            ],
          );
        },
      ),
    );
  }
}
