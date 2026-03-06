import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/screens/stats_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('StatsScreen', () {
    testWidgets('shows "Focus Stats" title', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const StatsScreen()));
      await tester.pump();

      expect(find.text('Focus Stats'), findsOneWidget);
    });

    testWidgets('shows hours saved card with default value', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const StatsScreen()));
      await tester.pump();

      expect(find.text('Hours Saved'), findsOneWidget);
      expect(find.text('Past week'), findsOneWidget);
    });

    testWidgets('shows apps blocked stat box', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const StatsScreen()));
      await tester.pump();

      expect(find.text('APPS BLOCKED'), findsOneWidget);
    });

    testWidgets('shows focused stat box', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const StatsScreen()));
      await tester.pump();

      expect(find.text('FOCUSED'), findsOneWidget);
    });

    testWidgets('shows day streak stat box', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const StatsScreen()));
      await tester.pump();

      expect(find.text('DAY STREAK'), findsOneWidget);
    });

    testWidgets('shows total focus sessions card', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const StatsScreen()));
      await tester.pump();

      expect(find.text('Total Focus Sessions'), findsOneWidget);
    });

    testWidgets('shows blocked apps section when empty', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const StatsScreen()));
      await tester.pump();

      // When no blocked apps, the empty state shows instead
      expect(find.text('No blocked apps yet'), findsOneWidget);
    });

    testWidgets('shows empty state when no blocked apps', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const StatsScreen()));
      await tester.pump();

      expect(find.text('No blocked apps yet'), findsOneWidget);
    });

    testWidgets('renders in light mode without errors', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const StatsScreen(), darkMode: false),
      );
      await tester.pump();

      expect(find.byType(StatsScreen), findsOneWidget);
    });

    testWidgets('renders in dark mode without errors', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const StatsScreen(), darkMode: true),
      );
      await tester.pump();

      expect(find.byType(StatsScreen), findsOneWidget);
    });
  });
}
