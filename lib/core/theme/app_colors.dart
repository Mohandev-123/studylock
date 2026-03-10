import 'package:flutter/material.dart';

/// Centralized theme-aware color provider for the app.
class AppColors {
  final bool isDark;

  const AppColors._(this.isDark);
  const AppColors.testDark() : isDark = true;
  const AppColors.testLight() : isDark = false;

  factory AppColors.of(BuildContext context) =>
      AppColors._(Theme.of(context).brightness == Brightness.dark);

  // Brand palette (light-blue + white direction)
  static const Color primary = Color(0xFF2D9CFF);
  static const Color primaryLight = Color(0xFF78C8FF);
  static const Color accent = Color(0xFF54B4FF);
  static const Color error = Color(0xFFD14343);
  static const Color success = Color(0xFF2FBF8F);

  List<Color> get scaffoldGradient => isDark
      ? const [Color(0xFF0B1D35), Color(0xFF0E2746), Color(0xFF123057)]
      : const [Color(0xFFF2FAFF), Color(0xFFE8F4FF), Color(0xFFF8FCFF)];

  BoxDecoration get scaffoldGradientDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: scaffoldGradient,
      stops: const [0.0, 0.55, 1.0],
    ),
  );

  Color get card =>
      isDark ? const Color(0xFF143354).withAlpha(214) : Colors.white;
  Color get cardBorder => isDark
      ? Colors.white.withAlpha(26)
      : const Color(0xFF2D9CFF).withAlpha(48);

  Color get surface =>
      isDark ? const Color(0xFF163B60) : const Color(0xFFEDF6FF);
  Color get surfaceHigh =>
      isDark ? const Color(0xFF193F66).withAlpha(196) : Colors.white;
  Color get surfaceVariant =>
      isDark ? const Color(0xFF21507A) : const Color(0xFFDBEEFF);

  Color get dialogBg => isDark ? const Color(0xFF163B60) : Colors.white;
  Color get snackBarBg =>
      isDark ? const Color(0xFF163B60) : const Color(0xFF1E4E7F);

  Color get textPrimary =>
      isDark ? const Color(0xFFE9F5FF) : const Color(0xFF153A60);
  Color get textSecondary =>
      isDark ? Colors.white.withAlpha(186) : const Color(0xFF2E5A84);
  Color get textTertiary =>
      isDark ? Colors.white.withAlpha(150) : const Color(0xFF5A7EA3);
  Color get textQuaternary =>
      isDark ? Colors.white.withAlpha(112) : const Color(0xFF7898BA);
  Color get textHint =>
      isDark ? Colors.white.withAlpha(133) : const Color(0xFF6B8DAF);

  Color get bottomNavBg => isDark ? const Color(0xFF0F2B49) : Colors.white;
  Color get bottomNavBorder => isDark
      ? Colors.white.withAlpha(23)
      : const Color(0xFF2D9CFF).withAlpha(41);
  Color get unselectedNavItem =>
      isDark ? Colors.white.withAlpha(128) : const Color(0xFF6B8FB3);

  Color get searchFill => isDark
      ? Colors.white.withAlpha(23)
      : const Color(0xFF2D9CFF).withAlpha(18);
  Color get searchBorder => isDark
      ? Colors.white.withAlpha(38)
      : const Color(0xFF2D9CFF).withAlpha(56);

  Color get switchInactiveTrack =>
      isDark ? Colors.white.withAlpha(56) : const Color(0xFFAAC7E4);
  Color get switchInactiveThumb =>
      isDark ? Colors.white.withAlpha(242) : Colors.white;

  Color get avatarBorder => isDark ? const Color(0xFF102B49) : Colors.white;
  Color get timerTrack =>
      isDark ? const Color(0xFF25537D) : const Color(0xFFCCE5FF);
  Color get outlinedBtnBorder => isDark
      ? Colors.white.withAlpha(66)
      : const Color(0xFF2D9CFF).withAlpha(102);
  Color get outlinedBtnBg => isDark
      ? const Color(0xFF173D62).withAlpha(163)
      : Colors.white.withAlpha(240);
  Color get iconPlaceholderBg => isDark
      ? Colors.white.withAlpha(28)
      : const Color(0xFF2D9CFF).withAlpha(20);
  Color get chipBg => isDark ? primary.withAlpha(56) : primary.withAlpha(24);
  Color get progressBarBg => isDark
      ? Colors.white.withAlpha(31)
      : const Color(0xFF2D9CFF).withAlpha(28);
  Color get selectionHighlight => isDark
      ? Colors.white.withAlpha(26)
      : const Color(0xFF2D9CFF).withAlpha(20);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: Color(0xFF163B60),
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFFE9F5FF),
    ),
    scaffoldBackgroundColor: const Color(0xFF0B1D35),
    cardColor: const Color(0xFF143354),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Color(0xFF163B60),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      surface: Color(0xFFF1F8FF),
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF153A60),
    ),
    scaffoldBackgroundColor: const Color(0xFFF7FCFF),
    cardColor: Colors.white,
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Color(0xFF1E4E7F),
    ),
  );
}
