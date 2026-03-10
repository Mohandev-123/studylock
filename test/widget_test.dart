import 'package:flutter_test/flutter_test.dart';
import 'package:study_lock/screens/onboarding_screen.dart';
import 'helpers/test_helpers.dart';

void main() {
  testWidgets('Onboarding screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget(const OnboardingScreen()));
    await tester.pump();

    expect(find.textContaining('Take Back Your'), findsOneWidget);
  });
}
