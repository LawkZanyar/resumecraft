import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';

/// Shared layout for the access screens: logo, title, subtitle, form.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBack = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: showBack ? AppBar() : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(alignment: Alignment.centerLeft, child: AppLogo()),
                  AppSpacing.gapXl,
                  Text(title, style: text.headlineMedium),
                  AppSpacing.gapSm,
                  Text(subtitle, style: text.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
                  AppSpacing.gapXl,
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Brand mark used on splash and access screens.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.description_rounded, color: scheme.onPrimary, size: size * 0.52),
          Positioned(
            right: size * 0.14,
            top: size * 0.14,
            child: Icon(Icons.auto_awesome, color: scheme.tertiary, size: size * 0.26),
          ),
        ],
      ),
    );
  }
}
