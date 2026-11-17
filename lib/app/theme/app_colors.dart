import 'package:flutter/material.dart';

/// Design tokens from the master prompt (A.3), plus derived dark values.
abstract final class AppColors {
  // Light tokens.
  static const Color primary = Color(0xFF142B4A); // Deep navy blue
  static const Color secondary = Color(0xFF3478F6); // Bright blue
  static const Color background = Color(0xFFF5F7FA); // Light gray
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color accent = Color(0xFF24B8A0); // Teal

  static const Color textPrimary = Color(0xFF142B4A);
  static const Color textSecondary = Color(0xFF5B6B82);
  static const Color outline = Color(0xFFDCE2EA);
  static const Color error = Color(0xFFD64545);
  static const Color warning = Color(0xFFE8A33D);
  static const Color success = Color(0xFF24B8A0);

  // Dark values derived from the light tokens, checked for readable contrast.
  static const Color darkPrimary = Color(0xFFA9C4EB); // navy lifted for text
  static const Color darkSecondary = Color(0xFF6EA1FF);
  static const Color darkBackground = Color(0xFF0D1522);
  static const Color darkSurface = Color(0xFF16202F);
  static const Color darkSurfaceHigh = Color(0xFF1E2A3C);
  static const Color darkAccent = Color(0xFF4FD1BA);
  static const Color darkTextPrimary = Color(0xFFE7EDF5);
  static const Color darkTextSecondary = Color(0xFFA3B1C4);
  static const Color darkOutline = Color(0xFF2C3A4F);
  static const Color darkError = Color(0xFFFF8A80);

  /// Colors used to show score bands consistently across the app.
  static Color scoreColor(int score) {
    if (score >= 80) return success;
    if (score >= 60) return secondary;
    if (score >= 40) return warning;
    return error;
  }
}
