import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/screens/timer_setup_screen.dart';
import '../helpers/test_helpers.dart';

void _setPhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  group('TimerSetupScreen', () {
    testWidgets('shows "Set Lock Duration" title', (tester) async {
      _setPhoneSize(tester);
      await tester.pumpWidget(buildTestableWidget(const TimerSetupScreen()));
      await tester.pump();

      expect(find.text('Set Lock Duration'), findsOneWidget);
    });

    testWidgets('shows HOURS label', (tester) async {
      _setPhoneSize(tester);
      await tester.pumpWidget(buildTestableWidget(const TimerSetupScreen()));
      await tester.pump();

      expect(find.text('HOURS'), findsOneWidget);
    });

    testWidgets('shows MINUTES label', (tester) async {
      _setPhoneSize(tester);
      await tester.pumpWidget(buildTestableWidget(const TimerSetupScreen()));
      await tester.pump();

      expect(find.text('MINUTES'), findsOneWidget);
    });

    testWidgets('shows colon separator', (tester) async {
      _setPhoneSize(tester);
      await tester.pumpWidget(buildTestableWidget(const TimerSetupScreen()));
      await tester.pump();

      expect(find.text(':'), findsOneWidget);
    });

    testWidgets('shows preset buttons', (tester) async {
      _setPhoneSize(tester);
      await tester.pumpWidget(buildTestableWidget(const TimerSetupScreen()));
      await tester.pump();

      expect(find.text('1 hour'), findsOneWidget);
      expect(find.text('2 hours'), findsOneWidget);
      expect(find.text('4 hours'), findsOneWidget);
      expect(find.text('8 hours'), findsOneWidget);
    });

    testWidgets('shows start button when 0h 0m', (tester) async {
      _setPhoneSize(tester);
      await tester.pumpWidget(buildTestableWidget(const TimerSetupScreen()));
      await tester.pump();

      // The start button contains an ElevatedButton
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      _setPhoneSize(tester);
      await tester.pumpWidget(buildTestableWidget(const TimerSetupScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('shows clock and lock icons', (tester) async {
      _setPhoneSize(tester);
      await tester.pumpWidget(buildTestableWidget(const TimerSetupScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('has two ListWheelScrollView pickers', (tester) async {
      _setPhoneSize(tester);
      await tester.pumpWidget(buildTestableWidget(const TimerSetupScreen()));
      await tester.pump();

      expect(find.byType(ListWheelScrollView), findsNWidgets(2));
    });

    testWidgets('has ElevatedButton for starting focus lock', (tester) async {
      _setPhoneSize(tester);
      await tester.pumpWidget(buildTestableWidget(const TimerSetupScreen()));
      await tester.pump();

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders in light mode without errors', (tester) async {
      _setPhoneSize(tester);
      await tester.pumpWidget(
        buildTestableWidget(const TimerSetupScreen(), darkMode: false),
      );
      await tester.pump();

      expect(find.byType(TimerSetupScreen), findsOneWidget);
    });

    testWidgets('renders in dark mode without errors', (tester) async {
      _setPhoneSize(tester);
      await tester.pumpWidget(
        buildTestableWidget(const TimerSetupScreen(), darkMode: true),
      );
      await tester.pump();

      expect(find.byType(TimerSetupScreen), findsOneWidget);
    });
  });
}
