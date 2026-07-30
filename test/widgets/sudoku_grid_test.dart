import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/models/game_state.dart';
import 'package:sudoku/models/stroke.dart';
import 'package:sudoku/widgets/sudoku_grid.dart';

import '../support/fake_puzzle.dart';

Future<void> _pumpGrid(WidgetTester tester, GameState state) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SudokuGrid(state: state, onCellTap: (_) {}),
      ),
    ),
  );
}

/// Counts the CustomPaint widgets whose painter is the private notes-thumbnail
/// painter (matched by its runtime type name).
int _thumbnailCount(WidgetTester tester) {
  return tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .where((c) => c.painter?.runtimeType.toString() == '_NotesThumbnailPainter')
      .length;
}

void main() {
  const stroke = Stroke([Offset(0.2, 0.2), Offset(0.8, 0.8)]);

  testWidgets('an empty cell with notes paints a thumbnail', (tester) async {
    final state = GameState.playing(1, fakePuzzle(blanks: const [0, 1]))
        .copyWith(cellNotes: {0: const [stroke]});
    await _pumpGrid(tester, state);
    expect(_thumbnailCount(tester), 1);
  });

  testWidgets('no notes anywhere paints no thumbnail', (tester) async {
    await _pumpGrid(tester, GameState.playing(1, fakePuzzle(blanks: const [0])));
    expect(_thumbnailCount(tester), 0);
  });

  testWidgets('a placed value hides the thumbnail (digit wins the cell)',
      (tester) async {
    final puzzle = fakePuzzle(blanks: const [0, 1]);
    // Cell 0 has both a value and notes -> the digit shows, thumbnail hidden.
    final state = GameState.playing(1, puzzle).copyWith(
      board: List<int>.of(puzzle.givens)..[0] = 5,
      cellNotes: {0: const [stroke]},
    );
    await _pumpGrid(tester, state);
    expect(_thumbnailCount(tester), 0);
    expect(find.text('5'), findsWidgets);
  });
}
