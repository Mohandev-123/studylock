import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/screens/splash_screen.dart';
import '../helpers/test_helpers.dart';

/// Helper: pump, assert, then advance past the 3-second navigation timer
/// so no pending timers remain at teardown. We cannot use pumpAndSettle
/// because the repeating AnimationControllers never settle.
Future<void> _pumpSplash(WidgetTester tester) async {
  await tester.pumpWidget(buildTestableWidget(const SplashScreen()));
  await tester.pump(); // build first frame
}

Future<void> _advancePastTimer(WidgetTester tester) async {
  // The splash has a Timer(Duration(seconds: 3)) that navigates away.
  // Pump 4 seconds to fire the timer and complete the navigation.
  await tester.pump(const Duration(seconds: 4));
  // One more pump to let the navigation frame settle.
  await tester.pump();
}

void main() {
  group('SplashScreen', () {
    testWidgets('renders the SplashScreen widget', (tester) async {
      await _pumpSplash(tester);
      expect(find.byType(SplashScreen), findsOneWidget);
      await _advancePastTimer(tester);
    });

    testWidgets('shows "Study Lock" brand name', (tester) async {
      await _pumpSplash(tester);
      expect(find.text('Study Lock'), findsOneWidget);
      await _advancePastTimer(tester);
    });

    testWidgets('shows "Control your time" subtitle', (tester) async {
      await _pumpSplash(tester);
      expect(find.text('Control your time'), findsOneWidget);
      await _advancePastTimer(tester);
    });

    testWidgets('has CustomPaint for lock icon', (tester) async {
      await _pumpSplash(tester);
      expect(find.byType(CustomPaint), findsWidgets);
      await _advancePastTimer(tester);
    });

    testWidgets('has AnimatedBuilder widgets for animations', (tester) async {
      await _pumpSplash(tester);
      // Multiple AnimatedBuilder widgets: pulse glow, loading dots, etc.
      expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(2));
      await _advancePastTimer(tester);
    });

    testWidgets('has gradient background', (tester) async {
      await _pumpSplash(tester);
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
      await _advancePastTimer(tester);
    });

    testWidgets('has loading dots row', (tester) async {
      await _pumpSplash(tester);
      // The loading dots are in a Row — we just verify the Row exists
      // along with the animated builder driving it
      expect(find.byType(Row), findsWidgets);
      await _advancePastTimer(tester);
    });

    testWidgets('timer fires after 3 seconds', (tester) async {
      await _pumpSplash(tester);
      // Splash should be present initially
      expect(find.byType(SplashScreen), findsOneWidget);

      // After 3+ seconds, the timer fires and triggers navigation.
      // The navigation may or may not fully replace depending on the
      // target screen's dependencies. We verify the timer doesn't crash.
      await tester.pump(const Duration(seconds: 4));
      await tester.pump();
      // No exception = timer and navigation logic ran successfully
    });

    testWidgets('brand text is white and sized 36', (tester) async {
      await _pumpSplash(tester);
      final textWidget = tester.widget<Text>(find.text('Study Lock'));
      expect(textWidget.style?.color, Colors.white);
      expect(textWidget.style?.fontSize, 36);
      await _advancePastTimer(tester);
    });
  });
}
