import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/data/audio_credits.dart';
import 'package:sudoku/screens/credits_screen.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('renders the credits intro', (tester) async {
    await pumpApp(tester, const CreditsScreen(credits: []));
    await tester.pump();
    expect(find.textContaining('Creative Commons'), findsOneWidget);
  });

  testWidgets('renders a credit card per track', (tester) async {
    await pumpApp(
      tester,
      const CreditsScreen(
        credits: [
          TrackCredit(
            title: 'Sunny Days',
            artist: 'Test Artist',
            license: 'CC BY 4.0',
            sourceUrl: 'https://example.com/track',
          ),
        ],
      ),
    );
    await tester.pump();
    expect(find.text('Sunny Days'), findsOneWidget);
    expect(find.textContaining('Test Artist'), findsOneWidget);
    expect(find.textContaining('CC BY 4.0'), findsOneWidget);
  });
}
