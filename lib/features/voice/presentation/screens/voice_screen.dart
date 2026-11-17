import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/labels.dart';
import '../../../../core/widgets/phase_label.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/data/sample/sample_ai.dart';
import '../../../ai/presentation/ai_providers.dart';
import '../voice_providers.dart';

/// Voice-to-resume: describe your background, then let AI organize it.
class VoiceScreen extends ConsumerStatefulWidget {
  const VoiceScreen({super.key});

  @override
  ConsumerState<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends ConsumerState<VoiceScreen> {
  final _transcript = TextEditingController();
  bool _usingSample = false;
  bool _busy = false;

  @override
  void dispose() {
    _transcript.dispose();
    super.dispose();
  }

  Future<void> _organize() async {
    final text = _transcript.text.trim();
    if (text.isEmpty) {
      showAppSnackBar(context, 'Say or type something about your background first.');
      return;
    }
    setState(() => _busy = true);
    final result = await ref.read(aiServiceProvider).structureVoiceTranscript(text);
    if (!mounted) return;
    setState(() => _busy = false);
    result.when(
      ok: (draft) {
        ref.read(voiceDraftProvider.notifier).set(draft);
        context.push(Routes.voiceReview);
      },
      err: (f) => showAppSnackBar(context, f.message, error: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Voice to resume')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          Text(
            'Describe your education, jobs, achievements and skills in your own words. '
            'AI organizes them into resume sections for you to review.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          AppSpacing.gapXl,
          Center(
            child: Column(
              children: [
                Material(
                  color: scheme.surfaceContainerHigh,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () =>
                        showAppSnackBar(context, 'Live recording is available in Phase 3.'),
                    child: const Padding(
                      padding: EdgeInsets.all(28),
                      child: Icon(Icons.mic_none_rounded, size: 44),
                    ),
                  ),
                ),
                AppSpacing.gapSm,
                const PhaseLabel(3),
              ],
            ),
          ),
          AppSpacing.gapXl,
          Row(
            children: [
              Expanded(child: Text('Transcript', style: Theme.of(context).textTheme.titleSmall)),
              if (_usingSample) const SampleBadge(),
            ],
          ),
          AppSpacing.gapSm,
          TextField(
            key: const Key('transcript_field'),
            controller: _transcript,
            maxLines: 8,
            minLines: 5,
            onChanged: (_) {
              if (_usingSample) setState(() => _usingSample = false);
            },
            decoration: const InputDecoration(
              hintText: 'Type here while live recording is not available…',
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() {
                _transcript.text = sampleTranscript;
                _usingSample = true;
              }),
              icon: const Icon(Icons.science_outlined),
              label: const Text('Use sample transcript'),
            ),
          ),
          AppSpacing.gapLg,
          PrimaryButton(
            key: const Key('organize_button'),
            label: 'Organize with AI',
            icon: Icons.auto_awesome,
            loading: _busy,
            onPressed: _organize,
          ),
        ],
      ),
    );
  }
}
