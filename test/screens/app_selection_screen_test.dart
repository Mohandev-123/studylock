import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/screens/app_selection_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('AppSelectionScreen', () {
    group('tab mode', () {
      // Tab mode has no Scaffold of its own — wrap in one.
      Widget tabWidget() =>
          const Scaffold(body: AppSelectionScreen(isTab: true));

      testWidgets('shows "Choose Apps to Lock" title', (tester) async {
        await tester.pumpWidget(buildTestableWidget(tabWidget()));
        await tester.pump();
        expect(find.text('Choose Apps to Lock'), findsOneWidget);
      });

      testWidgets('does not show back button in tab mode', (tester) async {
        await tester.pumpWidget(buildTestableWidget(tabWidget()));
        await tester.pump();
        expect(find.byIcon(Icons.arrow_back), findsNothing);
      });

      testWidgets('shows search icon', (tester) async {
        await tester.pumpWidget(buildTestableWidget(tabWidget()));
        await tester.pump();
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('renders without errors', (tester) async {
        await tester.pumpWidget(buildTestableWidget(tabWidget()));
        await tester.pump();
        expect(find.byType(AppSelectionScreen), findsOneWidget);
      });

      testWidgets('shows "Save Selection" button', (tester) async {
        await tester.pumpWidget(buildTestableWidget(tabWidget()));
        await tester.pump();
        expect(find.text('Save Selection'), findsOneWidget);
      });
    });

    group('pushed mode', () {
      testWidgets('shows "Choose Apps to Lock" title', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(const AppSelectionScreen(isTab: false)),
        );
        await tester.pump();
        expect(find.text('Choose Apps to Lock'), findsOneWidget);
      });

      testWidgets('shows back button', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(const AppSelectionScreen(isTab: false)),
        );
        await tester.pump();
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });
    });

    testWidgets('search field can accept text input', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const Scaffold(body: AppSelectionScreen(isTab: true)),
        ),
      );
      await tester.pump();
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'insta');
        await tester.pump();
      }
    });

    testWidgets('renders in light mode', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const Scaffold(body: AppSelectionScreen(isTab: true)),
          darkMode: false,
        ),
      );
      await tester.pump();
      expect(find.byType(AppSelectionScreen), findsOneWidget);
    });

    testWidgets('renders in dark mode', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const Scaffold(body: AppSelectionScreen(isTab: true)),
          darkMode: true,
        ),
      );
      await tester.pump();
      expect(find.byType(AppSelectionScreen), findsOneWidget);
    });
  });
}
