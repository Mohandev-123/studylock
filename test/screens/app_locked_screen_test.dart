import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/screens/app_locked_screen.dart';
import '../helpers/test_helpers.dart';

void _setPhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
}

void main() {
  group('AppLockedScreen', () {
    testWidgets('shows "App Locked" title', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(buildTestableWidget(const AppLockedScreen()));
      await tester.pump();
      expect(find.text('App Locked'), findsOneWidget);
    });

    testWidgets('shows "Stay focused." text', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(buildTestableWidget(const AppLockedScreen()));
      await tester.pump();
      expect(find.text('Stay focused.'), findsOneWidget);
    });

    testWidgets('shows "REMAINING" label', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(buildTestableWidget(const AppLockedScreen()));
      await tester.pump();
      expect(find.text('REMAINING'), findsOneWidget);
    });

    testWidgets('shows subtitle about timer', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(buildTestableWidget(const AppLockedScreen()));
      await tester.pump();
      expect(
        find.textContaining('You can open this app after the timer'),
        findsOneWidget,
      );
    });

    testWidgets('shows "View Focus Dashboard" button', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(buildTestableWidget(const AppLockedScreen()));
      await tester.pump();
      expect(find.text('View Focus Dashboard'), findsOneWidget);
    });

    testWidgets('shows lock icon', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(buildTestableWidget(const AppLockedScreen()));
      await tester.pump();
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('does NOT show emergency unlock button', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(buildTestableWidget(const AppLockedScreen()));
      await tester.pump();
      expect(find.text('Emergency Unlock'), findsNothing);
    });

    testWidgets('does NOT show end session button', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(buildTestableWidget(const AppLockedScreen()));
      await tester.pump();
      expect(find.text('End Session'), findsNothing);
    });

    testWidgets('displays timer from constructor params', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(
        buildTestableWidget(const AppLockedScreen(hours: 2, minutes: 30)),
      );
      await tester.pump();
      expect(find.text('2'), findsWidgets);
      expect(find.text('30'), findsWidgets);
    });

    testWidgets('renders in light mode', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(
        buildTestableWidget(const AppLockedScreen(), darkMode: false),
      );
      await tester.pump();
      expect(find.byType(AppLockedScreen), findsOneWidget);
    });

    testWidgets('renders in dark mode', (tester) async {
      _setPhoneSize(tester);
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(
        buildTestableWidget(const AppLockedScreen(), darkMode: true),
      );
      await tester.pump();
      expect(find.byType(AppLockedScreen), findsOneWidget);
    });
  });
}
