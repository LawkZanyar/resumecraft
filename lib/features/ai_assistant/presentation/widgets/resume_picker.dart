import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../shared/domain/domain.dart';
import '../../../resume/presentation/resume_providers.dart';

/// Dropdown of the user's resumes. Calls [onChanged] with the chosen resume,
/// and picks the most recent one automatically.
class ResumePicker extends ConsumerWidget {
  const ResumePicker({
    super.key,
    required this.selectedId,
    required this.onChanged,
    this.label = 'Resume',
    this.allowNone = false,
  });

  final String? selectedId;
  final ValueChanged<Resume?> onChanged;
  final String label;
  final bool allowNone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumes = ref.watch(userResumesProvider);
    return resumes.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(ErrorView.messageFor(e)),
      data: (list) {
        if (list.isEmpty) {
          return EmptyView(
            icon: Icons.description_outlined,
            title: 'No resumes yet',
            message: 'Create a resume first, then come back.',
            action: FilledButton(
              onPressed: () => context.push(Routes.resumeNew),
              child: const Text('Create resume'),
            ),
          );
        }
        final valid = list.any((r) => r.resumeId == selectedId);
        if (!valid && !allowNone) {
          WidgetsBinding.instance.addPostFrameCallback((_) => onChanged(list.first));
        }
        return DropdownButtonFormField<String?>(
          key: ValueKey('picker_${valid ? selectedId : 'none'}'),
          initialValue: valid ? selectedId : null,
          isExpanded: true,
          decoration: InputDecoration(labelText: label),
          items: [
            if (allowNone) const DropdownMenuItem(value: null, child: Text('None')),
            for (final r in list)
              DropdownMenuItem(
                value: r.resumeId,
                child: Text(r.title, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (id) => onChanged(list.where((r) => r.resumeId == id).firstOrNull),
        );
      },
    );
  }
}
