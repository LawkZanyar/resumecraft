import 'package:flutter/material.dart';

/// Professional type scale. Uses the platform font (Roboto on Android) so no
/// font download is needed.
abstract final class AppTextStyles {
  static TextTheme textTheme(ColorScheme scheme) {
    final base = Typography.material2021(platform: TargetPlatform.android)
        .black
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    return base.copyWith(
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.4),
      bodySmall: base.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
