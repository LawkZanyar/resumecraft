import 'package:flutter/widgets.dart';

/// Consistent spacing scale (4-point grid) and corner radii.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double radiusSm = 8;
  static const double radiusMd = 14;
  static const double radiusLg = 20;

  static const EdgeInsets page = EdgeInsets.fromLTRB(lg, lg, lg, xl);
  static const SizedBox gapXs = SizedBox(height: xs, width: xs);
  static const SizedBox gapSm = SizedBox(height: sm, width: sm);
  static const SizedBox gapMd = SizedBox(height: md, width: md);
  static const SizedBox gapLg = SizedBox(height: lg, width: lg);
  static const SizedBox gapXl = SizedBox(height: xl, width: xl);

  static const Duration animFast = Duration(milliseconds: 180);
  static const Duration animMedium = Duration(milliseconds: 320);
}
