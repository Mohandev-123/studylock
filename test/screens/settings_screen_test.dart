import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/screens/settings_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('SettingsScreen', () {
    testWidgets('shows "Settings" title', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const SettingsScreen()));
      await tester.pump();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows PREFERENCES section label', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const SettingsScreen()));
      await tester.pump();

      expect(find.text('PREFERENCES'), findsOneWidget);
    });

    testWidgets('shows DATA & SUPPORT section label', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const SettingsScreen()));
      await tester.pump();

      expect(find.text('DATA & SUPPORT'), findsOneWidget);
    });

    testWidgets('shows Change Timer Limits tile', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const SettingsScreen()));
      await tester.pump();

      expect(find.text('Change Timer Limits'), findsOneWidget);
    });

    testWidgets('shows Dark Mode toggle', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const SettingsScreen()));
      await tester.pump();

      expect(find.text('Dark Mode'), findsOneWidget);
    });

    testWidgets('shows Notification Reminders toggle', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const SettingsScreen()));
      await tester.pump();

      expect(find.text('Notification Reminders'), findsOneWidget);
    });

    testWidgets('shows App Usage History tile', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const SettingsScreen()));
      await tester.pump();

      expect(find.text('App Usage History'), findsOneWidget);
    });

    testWidgets('shows About Study Lock tile', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const SettingsScreen()));
      await tester.pump();

      expect(find.text('About Study Lock'), findsOneWidget);
    });

    testWidgets('has switch widgets for toggles', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const SettingsScreen()));
      await tester.pump();

      // Dark Mode and Notification Reminders should have switches
      expect(find.byType(Switch), findsNWidgets(2));
    });

    testWidgets('tapping About Study Lock shows dialog', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const SettingsScreen()));
      await tester.pump();

      await tester.tap(find.text('About Study Lock'));
      await tester.pumpAndSettle();

      expect(find.text('Study Lock v1.0.0'), findsOneWidget);
      expect(
        find.textContaining('Study Lock helps you stay focused'),
        findsOneWidget,
      );
    });

    testWidgets('about dialog has Close button', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const SettingsScreen()));
      await tester.pump();

      await tester.tap(find.text('About Study Lock'));
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('close button dismisses about dialog', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const SettingsScreen()));
      await tester.pump();

      await tester.tap(find.text('About Study Lock'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Study Lock v1.0.0'), findsNothing);
    });

    testWidgets('has correct icons for each tile', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const SettingsScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.access_time_filled), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('renders in light mode without errors', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const SettingsScreen(), darkMode: false),
      );
      await tester.pump();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('renders in dark mode without errors', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const SettingsScreen(), darkMode: true),
      );
      await tester.pump();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });
}
