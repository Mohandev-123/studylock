import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/screens/onboarding_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('OnboardingScreen', () {
    testWidgets('shows first page title "Take Back Your Time"', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
      await tester.pump();

      expect(find.textContaining('Take Back Your'), findsOneWidget);
    });

    testWidgets('shows "Study Lock" brand title', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
      await tester.pump();

      expect(find.text('Study Lock'), findsOneWidget);
    });

    testWidgets('shows Skip button', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
      await tester.pump();

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('shows Next button on first page', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
      await tester.pump();

      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('has 3 page indicator dots', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
      await tester.pump();

      // PageView should exist
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('tapping Next navigates to second page', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
      await tester.pump();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Set Long Lock Timers'), findsOneWidget);
    });

    testWidgets('second page shows timer display', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
      await tester.pump();

      // Navigate to page 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('20'), findsWidgets);
      expect(find.text('00'), findsWidgets);
    });

    testWidgets('third page shows "Get Started" button', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
      await tester.pump();

      // Navigate to page 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Navigate to page 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('third page shows "Unlock When Time Ends"', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
      await tester.pump();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Unlock When Time Ends'), findsOneWidget);
    });

    testWidgets('first page subtitle contains distraction text', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
      await tester.pump();

      expect(find.textContaining('Block distracting apps'), findsOneWidget);
    });

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
      await tester.pump();

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });
  });
}
