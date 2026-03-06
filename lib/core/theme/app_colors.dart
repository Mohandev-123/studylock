import 'package:flutter/material.dart';

/// Centralized theme-aware color provider for the app.
/// Usage: `final colors = AppColors.of(context);`
class AppColors {
  final bool isDark;

  const AppColors._(this.isDark);

  /// Named constructors for unit tests (no BuildContext needed).
  const AppColors.testDark() : isDark = true;
  const AppColors.testLight() : isDark = false;

  factory AppColors.of(BuildContext context) {
    return AppColors._(Theme.of(context).brightness == Brightness.dark);
  }

  // ─── Constants (same in both modes) ────────────────────────────────
  static const Color primary = Color(0xFF2244FF);
  static const Color primaryLight = Color(0xFF4466FF);
  static const Color accent = Color(0xFFFF8C00);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF4CAF50);

  // ─── Scaffold Gradient ─────────────────────────────────────────────
  List<Color> get scaffoldGradient => isDark
      ? const [Color(0xFF0A0E21), Color(0xFF0D1333), Color(0xFF070B1A)]
      : const [Color(0xFFF2F4F8), Color(0xFFE8EBF2), Color(0xFFF5F6FA)];

  BoxDecoration get scaffoldGradientDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: scaffoldGradient,
      stops: const [0.0, 0.5, 1.0],
    ),
  );

  // ─── Card / Surface ────────────────────────────────────────────────
  Color get card =>
      isDark ? const Color(0xFF141832).withAlpha(179) : Colors.white;

  Color get cardBorder =>
      isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(20);

  Color get surface =>
      isDark ? const Color(0xFF1A1E35) : const Color(0xFFF0F1F7);

  Color get surfaceHigh =>
      isDark ? const Color(0xFF1A1E35).withAlpha(179) : Colors.white;

  Color get surfaceVariant =>
      isDark ? const Color(0xFF2A2E45) : const Color(0xFFE2E4ED);

  // ─── Dialog / Popup ────────────────────────────────────────────────
  Color get dialogBg => isDark ? const Color(0xFF1A1E35) : Colors.white;

  Color get snackBarBg =>
      isDark ? const Color(0xFF1A1E35) : const Color(0xFF323644);

  // ─── Text ──────────────────────────────────────────────────────────
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF1A1A2E);

  Color get textSecondary =>
      isDark ? Colors.white.withAlpha(153) : Colors.black.withAlpha(140);

  Color get textTertiary =>
      isDark ? Colors.white.withAlpha(102) : Colors.black.withAlpha(97);

  Color get textQuaternary =>
      isDark ? Colors.white.withAlpha(77) : Colors.black.withAlpha(64);

  Color get textHint =>
      isDark ? Colors.white.withAlpha(115) : Colors.black.withAlpha(89);

  // ─── Bottom Navigation ─────────────────────────────────────────────
  Color get bottomNavBg => isDark ? const Color(0xFF0D1130) : Colors.white;

  Color get bottomNavBorder =>
      isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(20);

  Color get unselectedNavItem =>
      isDark ? Colors.white.withAlpha(89) : Colors.black.withAlpha(115);

  // ─── Input / Search ────────────────────────────────────────────────
  Color get searchFill =>
      isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10);

  Color get searchBorder =>
      isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(20);

  // ─── Switch ────────────────────────────────────────────────────────
  Color get switchInactiveTrack =>
      isDark ? Colors.white.withAlpha(38) : Colors.black.withAlpha(31);

  Color get switchInactiveThumb =>
      isDark ? Colors.white.withAlpha(230) : Colors.white;

  // ─── Misc ──────────────────────────────────────────────────────────
  Color get avatarBorder => isDark ? const Color(0xFF0D1333) : Colors.white;

  Color get timerTrack =>
      isDark ? const Color(0xFF1A1E40) : const Color(0xFFD8DAE8);

  Color get outlinedBtnBorder =>
      isDark ? Colors.white.withAlpha(38) : Colors.black.withAlpha(31);

  Color get outlinedBtnBg => isDark
      ? const Color(0xFF1A1E35).withAlpha(128)
      : Colors.white.withAlpha(204);

  Color get iconPlaceholderBg =>
      isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(13);

  Color get chipBg => isDark ? primary.withAlpha(38) : primary.withAlpha(26);

  Color get progressBarBg =>
      isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15);

  Color get selectionHighlight =>
      isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10);

  // ─── ThemeData ─────────────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: Color(0xFF141832),
      error: error,
    ),
    scaffoldBackgroundColor: const Color(0xFF0A0E21),
    useMaterial3: true,
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      surface: Color(0xFFF0F1F7),
      error: error,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F6FA),
    useMaterial3: true,
  );
}
