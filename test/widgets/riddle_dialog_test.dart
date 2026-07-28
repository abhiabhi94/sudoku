import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/data/riddle_bank.dart';
import 'package:sudoku/widgets/riddle_dialog.dart';

import '../support/pump_app.dart';

void main() {
  final riddles = riddlesFor('en'); // first answer is "echo"

  Future<bool?> openDialog(WidgetTester tester) async {
    bool? result;
    await pumpApp(
      tester,
      Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () async {
              result = await showRiddleDialog(context,
                  riddles: riddles, startIndex: 0);
            },
            child: const Text('go'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('correct answer resolves to true', (tester) async {
    await openDialog(tester);
    expect(find.text('Solve to earn a hint'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ECHO');
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    // Dialog dismissed with success (no error text remaining).
    expect(find.text('Solve to earn a hint'), findsNothing);
  });

  testWidgets('a wrong answer can be retried on the same riddle', (tester) async {
    await openDialog(tester);
    expect(find.text(riddles[0].prompt), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'definitely wrong');
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    expect(find.text('Not quite — try again!'), findsOneWidget);
    // Same riddle stays so the player can try again (unlimited).
    expect(find.text(riddles[0].prompt), findsOneWidget);
  });

  testWidgets('"New riddle" swaps to a different riddle', (tester) async {
    await openDialog(tester);
    expect(find.text(riddles[0].prompt), findsOneWidget);

    await tester.tap(find.text('New riddle'));
    await tester.pumpAndSettle();

    expect(find.text(riddles[0].prompt), findsNothing);
    expect(find.text(riddles[1].prompt), findsOneWidget);
  });

  testWidgets('the close icon cancels', (tester) async {
    await openDialog(tester);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
  });
}
