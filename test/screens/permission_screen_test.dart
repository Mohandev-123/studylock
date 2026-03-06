import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/screens/permission_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('PermissionScreen', () {
    testWidgets('shows "Study Lock needs accessibility" title', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const PermissionScreen()));
      await tester.pump();

      expect(
        find.textContaining('Study Lock needs accessibility'),
        findsOneWidget,
      );
    });

    testWidgets('shows "Grant Permission" button', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const PermissionScreen()));
      await tester.pump();

      expect(find.text('Grant Permission'), findsOneWidget);
    });

    testWidgets('shows "Why this is needed?" link', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const PermissionScreen()));
      await tester.pump();

      expect(find.text('Why this is needed?'), findsOneWidget);
    });

    testWidgets('shows Skip button in app bar', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const PermissionScreen()));
      await tester.pump();

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('shows lock icon', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const PermissionScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const PermissionScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('tapping "Why this is needed?" shows bottom sheet', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const PermissionScreen()));
      await tester.pump();

      await tester.tap(find.text('Why this is needed?'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Study Lock uses the Accessibility Service'),
        findsOneWidget,
      );
    });

    testWidgets('bottom sheet shows why needed explanation', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const PermissionScreen()));
      await tester.pump();

      await tester.tap(find.text('Why this is needed?'));
      await tester.pumpAndSettle();

      expect(find.text('Why is this needed?'), findsOneWidget);
    });

    testWidgets('renders in light mode without errors', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const PermissionScreen(), darkMode: false),
      );
      await tester.pump();

      expect(find.byType(PermissionScreen), findsOneWidget);
    });

    testWidgets('renders in dark mode without errors', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const PermissionScreen(), darkMode: true),
      );
      await tester.pump();

      expect(find.byType(PermissionScreen), findsOneWidget);
    });
  });
}
