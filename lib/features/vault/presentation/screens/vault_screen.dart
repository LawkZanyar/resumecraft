import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/phase_label.dart';

/// Locked entry to the secure resume vault. Unlocking arrives in Phase 3.
class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Secure vault')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: scheme.primaryContainer,
                child: Icon(Icons.lock_rounded, size: 44, color: scheme.primary),
              ),
              AppSpacing.gapXl,
              Text('Your vault is locked', style: Theme.of(context).textTheme.titleLarge),
              AppSpacing.gapSm,
              Text(
                'Saved resume versions are encrypted on this device and open only '
                'after fingerprint or face authentication.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              AppSpacing.gapXl,
              const PhaseLockedButton(
                phase: 3,
                label: 'Unlock with biometrics',
                icon: Icons.fingerprint_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
