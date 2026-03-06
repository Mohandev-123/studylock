// Smoke test for the Study Lock app.

import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/screens/splash_screen.dart';
import 'helpers/test_helpers.dart';

void main() {
  testWidgets('App launches and shows splash screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestableWidget(const SplashScreen()));
    await tester.pump();

    expect(find.text('Study Lock'), findsOneWidget);

    // Advance past the 3-second navigation timer
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
  });
}
