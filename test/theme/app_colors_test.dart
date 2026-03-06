import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/core/theme/app_colors.dart';

void main() {
  group('AppColors - Static constants', () {
    test('primary is blue', () {
      expect(AppColors.primary, const Color(0xFF2244FF));
    });

    test('primaryLight is lighter blue', () {
      expect(AppColors.primaryLight, const Color(0xFF4466FF));
    });

    test('accent is orange', () {
      expect(AppColors.accent, const Color(0xFFFF8C00));
    });

    test('error is red', () {
      expect(AppColors.error, const Color(0xFFE53935));
    });

    test('success is green', () {
      expect(AppColors.success, const Color(0xFF4CAF50));
    });
  });

  group('AppColors - Dark mode', () {
    late AppColors colors;

    setUp(() {
      colors = const AppColors.testDark();
    });

    test('isDark is true', () {
      expect(colors.isDark, isTrue);
    });

    test('scaffoldGradient has 3 dark colors', () {
      final gradient = colors.scaffoldGradient;
      expect(gradient.length, 3);
      expect(gradient[0], const Color(0xFF0A0E21));
    });

    test('textPrimary is white', () {
      expect(colors.textPrimary, Colors.white);
    });

    test('textSecondary is white with alpha', () {
      expect(colors.textSecondary, Colors.white.withAlpha(153));
    });

    test('card is dark', () {
      expect(colors.card, const Color(0xFF141832).withAlpha(179));
    });

    test('bottomNavBg is dark', () {
      expect(colors.bottomNavBg, const Color(0xFF0D1130));
    });

    test('dialogBg is dark', () {
      expect(colors.dialogBg, const Color(0xFF1A1E35));
    });

    test('scaffoldGradientDecoration returns BoxDecoration with gradient', () {
      final decoration = colors.scaffoldGradientDecoration;
      expect(decoration, isA<BoxDecoration>());
      expect(decoration.gradient, isA<LinearGradient>());
    });
  });

  group('AppColors - Light mode', () {
    late AppColors colors;

    setUp(() {
      colors = const AppColors.testLight();
    });

    test('isDark is false', () {
      expect(colors.isDark, isFalse);
    });

    test('scaffoldGradient has 3 light colors', () {
      final gradient = colors.scaffoldGradient;
      expect(gradient.length, 3);
      expect(gradient[0], const Color(0xFFF2F4F8));
    });

    test('textPrimary is dark', () {
      expect(colors.textPrimary, const Color(0xFF1A1A2E));
    });

    test('card is white', () {
      expect(colors.card, Colors.white);
    });

    test('bottomNavBg is white', () {
      expect(colors.bottomNavBg, Colors.white);
    });

    test('dialogBg is white', () {
      expect(colors.dialogBg, Colors.white);
    });
  });

  group('AppColors - ThemeData', () {
    test('darkTheme has dark brightness', () {
      expect(AppColors.darkTheme.brightness, Brightness.dark);
    });

    test('lightTheme has light brightness', () {
      expect(AppColors.lightTheme.brightness, Brightness.light);
    });

    test('darkTheme uses primary color', () {
      expect(AppColors.darkTheme.colorScheme.primary, AppColors.primary);
    });

    test('lightTheme uses primary color', () {
      expect(AppColors.lightTheme.colorScheme.primary, AppColors.primary);
    });

    test('darkTheme uses accent as secondary', () {
      expect(AppColors.darkTheme.colorScheme.secondary, AppColors.accent);
    });

    test('lightTheme uses accent as secondary', () {
      expect(AppColors.lightTheme.colorScheme.secondary, AppColors.accent);
    });

    test('darkTheme has useMaterial3 true', () {
      expect(AppColors.darkTheme.useMaterial3, isTrue);
    });

    test('lightTheme has useMaterial3 true', () {
      expect(AppColors.lightTheme.useMaterial3, isTrue);
    });

    test('darkTheme error color matches', () {
      expect(AppColors.darkTheme.colorScheme.error, AppColors.error);
    });

    test('lightTheme error color matches', () {
      expect(AppColors.lightTheme.colorScheme.error, AppColors.error);
    });
  });

  group('AppColors.of(context)', () {
    testWidgets('returns dark AppColors when theme is dark', (tester) async {
      late AppColors colors;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppColors.darkTheme,
          home: Builder(
            builder: (context) {
              colors = AppColors.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(colors.isDark, isTrue);
    });

    testWidgets('returns light AppColors when theme is light', (tester) async {
      late AppColors colors;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppColors.lightTheme,
          home: Builder(
            builder: (context) {
              colors = AppColors.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(colors.isDark, isFalse);
    });
  });

  group('AppColors - Color property consistency', () {
    test('dark and light modes have different textPrimary', () {
      final dark = const AppColors.testDark();
      final light = const AppColors.testLight();
      expect(dark.textPrimary, isNot(equals(light.textPrimary)));
    });

    test('dark and light modes have different card colors', () {
      final dark = const AppColors.testDark();
      final light = const AppColors.testLight();
      expect(dark.card, isNot(equals(light.card)));
    });

    test('dark and light modes have different surface colors', () {
      final dark = const AppColors.testDark();
      final light = const AppColors.testLight();
      expect(dark.surface, isNot(equals(light.surface)));
    });

    test('dark and light modes have different bottomNavBg', () {
      final dark = const AppColors.testDark();
      final light = const AppColors.testLight();
      expect(dark.bottomNavBg, isNot(equals(light.bottomNavBg)));
    });
  });
}
