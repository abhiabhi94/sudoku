import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/widgets/hint_progress_bar.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('lights one bulb per hint used', (tester) async {
    await pumpApp(tester, const HintProgressBar(hintsUsed: 2, shownMax: 4));
    expect(find.byIcon(Icons.lightbulb_rounded), findsNWidgets(4));
    expect(find.textContaining('+'), findsNothing);
  });

  testWidgets('shows an overflow badge past the shown maximum', (tester) async {
    await pumpApp(tester, const HintProgressBar(hintsUsed: 6, shownMax: 4));
    expect(find.text('+2'), findsOneWidget);
  });
}
