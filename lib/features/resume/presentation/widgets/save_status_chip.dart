import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/labels.dart';
import '../resume_editor_controller.dart';

/// Shows whether the draft is saved, saving, unsaved or failed.
class SaveStatusChip extends StatelessWidget {
  const SaveStatusChip({super.key, required this.state});

  final ResumeEditorState state;

  @override
  Widget build(BuildContext context) {
    final (text, color, icon) = switch (state.status) {
      SaveStatus.saving => ('Saving…', AppColors.secondary, Icons.sync_rounded),
      SaveStatus.error => ('Not saved', AppColors.error, Icons.error_outline_rounded),
      _ when state.dirty => ('Unsaved changes', AppColors.warning, Icons.edit_rounded),
      SaveStatus.saved => ('Saved', AppColors.success, Icons.cloud_done_outlined),
      SaveStatus.idle => state.isNew
          ? ('Not saved yet', AppColors.textSecondary, Icons.edit_rounded)
          : ('Saved', AppColors.success, Icons.cloud_done_outlined),
    };
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Center(child: Pill(text: text, color: color, icon: icon)),
    );
  }
}
