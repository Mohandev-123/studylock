import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/core/models/models.dart';
import 'package:study_lock/core/providers/providers.dart';
import 'package:study_lock/screens/home_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('shows "Focus Mode" title when timer is inactive', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const HomeScreen()));
      await tester.pump();

      expect(find.text('Focus Mode'), findsOneWidget);
    });

    testWidgets('shows "Focus Active" title when timer is active', (
      tester,
    ) async {
      final timer = FocusTimer.start(hours: 1, minutes: 0);
      await tester.pumpWidget(
        buildTestableWidget(
          const Scaffold(body: HomeScreen()),
          overrides: defaultOverrides(
            timerState: TimerState(
              timer: timer,
              isActive: true,
              remaining: timer.remainingTime,
              progress: 0.1,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Focus Active'), findsOneWidget);
    });

    testWidgets('shows "Ready to Focus" in timer ring when idle', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const HomeScreen()));
      await tester.pump();

      expect(find.text('Ready to Focus'), findsOneWidget);
    });

    testWidgets('shows "No Apps Locked" when blocked apps list empty', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const HomeScreen()));
      await tester.pump();

      expect(find.text('No Apps Locked'), findsOneWidget);
    });

    testWidgets('shows "Select Apps" button when timer is inactive', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const HomeScreen()));
      await tester.pump();

      expect(find.text('Select Apps'), findsOneWidget);
    });

    testWidgets('shows "Set Timer" button when timer is inactive', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const HomeScreen()));
      await tester.pump();

      expect(find.text('Set Timer'), findsOneWidget);
    });

    testWidgets('shows "View Lock" button when timer is active', (
      tester,
    ) async {
      final timer = FocusTimer.start(hours: 1, minutes: 0);
      await tester.pumpWidget(
        buildTestableWidget(
          const Scaffold(body: HomeScreen()),
          overrides: defaultOverrides(
            timerState: TimerState(
              timer: timer,
              isActive: true,
              remaining: timer.remainingTime,
              progress: 0.1,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('View Lock'), findsOneWidget);
    });

    testWidgets('shows focus streak card', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const HomeScreen()));
      await tester.pump();

      expect(find.text('Focus Streak'), findsOneWidget);
    });

    testWidgets('shows "Set Timer" snackbar when no apps blocked', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(const Scaffold(body: HomeScreen())),
      );
      await tester.pump();

      // Find and tap the "Set Timer" button
      final setTimerButton = find.text('Set Timer');
      if (setTimerButton.evaluate().isNotEmpty) {
        await tester.tap(setTimerButton);
        await tester.pump();
        expect(find.text('Please select apps to block first'), findsOneWidget);
      }
    });

    testWidgets('renders in light mode without errors', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const HomeScreen(), darkMode: false),
      );
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('renders in dark mode without errors', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const HomeScreen(), darkMode: true),
      );
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
