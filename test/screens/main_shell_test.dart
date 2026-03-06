import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/screens/main_shell.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('MainShell', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const MainShell()));
      await tester.pump();
      expect(find.byType(MainShell), findsOneWidget);
    });

    testWidgets('shows BottomNavigationBar', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const MainShell()));
      await tester.pump();
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('has 4 navigation items', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const MainShell()));
      await tester.pump();
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Apps'), findsOneWidget);
      expect(find.text('Stats'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('has correct nav icons', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const MainShell()));
      await tester.pump();
      expect(find.byIcon(Icons.home_filled), findsOneWidget);
      expect(find.byIcon(Icons.apps), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('starts on Home tab (index 0)', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const MainShell()));
      await tester.pump();
      // Home screen should be visible as the first tab
      expect(find.text('Focus Mode'), findsOneWidget);
    });

    testWidgets('tap Apps tab shows app selection', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const MainShell()));
      await tester.pump();

      await tester.tap(find.text('Apps'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Apps to Lock'), findsOneWidget);
    });

    testWidgets('tap Stats tab shows stats screen', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const MainShell()));
      await tester.pump();

      await tester.tap(find.text('Stats'));
      await tester.pumpAndSettle();

      expect(find.text('Focus Stats'), findsOneWidget);
    });

    testWidgets('tap Settings tab shows settings screen', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const MainShell()));
      await tester.pump();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsAtLeast(1));
    });

    testWidgets('uses IndexedStack for tab persistence', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const MainShell()));
      await tester.pump();
      expect(find.byType(IndexedStack), findsOneWidget);
    });

    testWidgets('renders in light mode', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const MainShell(), darkMode: false),
      );
      await tester.pump();
      expect(find.byType(MainShell), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
