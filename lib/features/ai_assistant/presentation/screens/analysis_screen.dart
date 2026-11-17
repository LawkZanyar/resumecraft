import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/phase_label.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/domain/domain.dart';
import '../../../ai/domain/ai_models.dart';
import '../../../ai/presentation/ai_providers.dart';
import '../../../ai/presentation/widgets/ai_widgets.dart';
import '../widgets/resume_picker.dart';

/// The 100-point resume analysis.
class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  Resume? _resume;
  AsyncValue<ResumeAnalysis>? _result;

  Future<void> _analyze() async {
    final r = _resume;
    if (r == null) return;
    setState(() => _result = const AsyncLoading());
    final out = await ref.read(aiServiceProvider).analyzeResume(r);
    if (!mounted) return;
    setState(() {
      _result = out.when(ok: AsyncData.new, err: (f) => AsyncError(f, StackTrace.current));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSample = ref.watch(aiServiceProvider).isSample;
    return Scaffold(
      appBar: AppBar(title: const Text('Resume analysis')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          ResumePicker(
            selectedId: _resume?.resumeId,
            onChanged: (r) => setState(() {
              _resume = r;
              _result = null;
            }),
          ),
          AppSpacing.gapLg,
          FilledButton.icon(
            key: const Key('analyze_button'),
            onPressed: _resume == null || _result is AsyncLoading ? null : _analyze,
            icon: const Icon(Icons.insights_rounded),
            label: const Text('Analyze resume'),
          ),
          AppSpacing.gapLg,
          if (_result != null)
            _result!.when(
              loading: () => const AiLoadingView(message: 'Analyzing your resume…'),
              error: (e, _) => ErrorView(error: e, onRetry: _analyze),
              data: (a) => _AnalysisView(analysis: a, isSample: isSample),
            ),
        ],
      ),
    );
  }
}

class _AnalysisView extends StatelessWidget {
  const _AnalysisView({required this.analysis, required this.isSample});

  final ResumeAnalysis analysis;
  final bool isSample;

  static const _max = {
    'Contact': 10,
    'Summary': 10,
    'Experience': 30,
    'Education': 15,
    'Skills': 15,
    'Extras': 10,
    'Writing': 10,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            children: [
              if (isSample) const Align(alignment: Alignment.centerRight, child: SampleAiLabel()),
              ScoreGauge(key: const Key('analysis_score'), score: analysis.score, size: 140),
              AppSpacing.gapMd,
              Text(analysis.summary, textAlign: TextAlign.center),
              AppSpacing.gapLg,
              for (final e in analysis.sectionScores.entries)
                ScoreBar(label: e.key, value: e.value, max: _max[e.key] ?? 10),
            ],
          ),
        ),
        AppSpacing.gapMd,
        RecommendationList(
          title: 'Strengths',
          items: analysis.strengths,
          icon: Icons.check_circle_outline,
          color: AppColors.success,
        ),
        RecommendationList(
          title: 'Weaknesses',
          items: analysis.weaknesses,
          icon: Icons.error_outline,
          color: AppColors.error,
        ),
        RecommendationList(
          title: 'Recommendations',
          items: analysis.recommendations,
          icon: Icons.lightbulb_outline,
          color: AppColors.secondary,
        ),
        const PhaseLockedButton(phase: 2, label: 'Save score to resume', icon: Icons.save_outlined),
      ],
    );
  }
}
