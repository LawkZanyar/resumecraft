import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

/// Text field bound to one draft value. [initialValue] is read once.
class DraftField extends StatelessWidget {
  const DraftField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.validator,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.capitalization = TextCapitalization.sentences,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization capitalization;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        validator: validator,
        maxLines: maxLines,
        minLines: maxLines > 1 ? 3 : 1,
        keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
        textCapitalization: capitalization,
        decoration: InputDecoration(labelText: label, hintText: hint, alignLabelWithHint: true),
      ),
    );
  }
}

/// Card wrapping one list entry (an experience, a degree, ...).
class EntryCard extends StatelessWidget {
  const EntryCard({
    super.key,
    required this.title,
    required this.onDelete,
    required this.children,
  });

  final String title;
  final VoidCallback onDelete;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Remove',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            AppSpacing.gapSm,
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Two fields side by side (start and end dates).
class FieldPair extends StatelessWidget {
  const FieldPair({super.key, required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Expanded(child: left), AppSpacing.gapMd, Expanded(child: right)],
      );
}

class AddEntryButton extends StatelessWidget {
  const AddEntryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded),
        label: Text(label),
      );
}

class StepIntro extends StatelessWidget {
  const StepIntro(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
}
