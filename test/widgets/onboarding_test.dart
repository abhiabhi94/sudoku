import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/providers/settings_provider.dart';
import 'package:sudoku/screens/onboarding_screen.dart';

import '../support/pump_app.dart';

void main() {
  // The mascot animation loops forever, so pumpAndSettle can't be used; pump a
  // few fixed frames to let the PageView animation and onPageChanged rebuild.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('shows the first slide and advances through all three', (tester) async {
    await pumpApp(tester, const OnboardingScreen());

    expect(find.text('Welcome, puzzle friend!'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await settle(tester);
    expect(find.text('Four tiers, forty levels'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await settle(tester);
    expect(find.text('Stuck? Earn a hint!'), findsOneWidget);
    expect(find.text("Let's play!"), findsOneWidget);
  });

  testWidgets('finishing marks onboarding done and opens home', (tester) async {
    final container = await pumpApp(tester, const OnboardingScreen());

    // Skip straight to the end.
    await tester.tap(find.text('Skip'));
    expect(container.read(settingsProvider).onboardingDone, isTrue);

    // Let the pushReplacement route transition to home finish (can't
    // pumpAndSettle because the mascot animation loops forever).
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Numbers, but make it fun'), findsOneWidget); // home tagline
  });
}
