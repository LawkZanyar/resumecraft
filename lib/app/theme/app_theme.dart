import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Material 3 light and dark themes built from the design tokens.
abstract final class AppTheme {
  static ThemeData get light => _build(
        const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: Colors.white,
          primaryContainer: Color(0xFFDCE6F5),
          onPrimaryContainer: AppColors.primary,
          secondary: AppColors.secondary,
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFE1ECFF),
          onSecondaryContainer: Color(0xFF0D3A86),
          tertiary: AppColors.accent,
          onTertiary: Colors.white,
          tertiaryContainer: Color(0xFFD4F4EE),
          onTertiaryContainer: Color(0xFF0B5246),
          error: AppColors.error,
          onError: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          onSurfaceVariant: AppColors.textSecondary,
          surfaceContainerLowest: AppColors.surface,
          surfaceContainerLow: Color(0xFFF9FAFC),
          surfaceContainer: AppColors.background,
          surfaceContainerHigh: Color(0xFFEDF1F6),
          surfaceContainerHighest: Color(0xFFE6EBF2),
          outline: AppColors.outline,
          outlineVariant: Color(0xFFE9EDF2),
        ),
        scaffold: AppColors.background,
      );

  static ThemeData get dark => _build(
        const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.darkPrimary,
          onPrimary: Color(0xFF0B1A2E),
          primaryContainer: Color(0xFF243A5C),
          onPrimaryContainer: Color(0xFFDCE6F5),
          secondary: AppColors.darkSecondary,
          onSecondary: Color(0xFF06204D),
          secondaryContainer: Color(0xFF1C3A6B),
          onSecondaryContainer: Color(0xFFDCE8FF),
          tertiary: AppColors.darkAccent,
          onTertiary: Color(0xFF00382F),
          tertiaryContainer: Color(0xFF0F4A41),
          onTertiaryContainer: Color(0xFFC9F5EC),
          error: AppColors.darkError,
          onError: Color(0xFF5C0A06),
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          onSurfaceVariant: AppColors.darkTextSecondary,
          surfaceContainerLowest: AppColors.darkBackground,
          surfaceContainerLow: Color(0xFF131C2A),
          surfaceContainer: AppColors.darkSurface,
          surfaceContainerHigh: AppColors.darkSurfaceHigh,
          surfaceContainerHighest: Color(0xFF263449),
          outline: AppColors.darkOutline,
          outlineVariant: Color(0xFF223047),
        ),
        scaffold: AppColors.darkBackground,
      );

  static ThemeData _build(ColorScheme scheme, {required Color scaffold}) {
    final text = AppTextStyles.textTheme(scheme);
    final radius = BorderRadius.circular(AppSpacing.radiusMd);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: text,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.secondary, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape: RoundedRectangleBorder(borderRadius: radius),
          side: BorderSide(color: scheme.outline),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: text.labelLarge),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        side: BorderSide(color: scheme.outline),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(text.labelSmall),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
