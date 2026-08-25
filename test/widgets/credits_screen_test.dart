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

  testWidgets('credits the bundled track, as CC-BY requires', (tester) async {
    await pumpApp(tester, const CreditsScreen());
    await tester.pump();
    expect(find.text('Permafrost'), findsOneWidget);
    expect(find.textContaining('Scott Buckley'), findsOneWidget);
    expect(find.textContaining('CC BY 4.0'), findsOneWidget);
    expect(find.textContaining('scottbuckley.com.au'), findsOneWidget);
  });

  test('every bundled track carries a full attribution', () {
    expect(audioCredits, isNotEmpty);
    for (final credit in audioCredits) {
      expect(credit.title, isNotEmpty);
      expect(credit.artist, isNotEmpty);
      expect(credit.license, isNotEmpty);
      expect(credit.sourceUrl, isNotEmpty);
    }
  });
}
