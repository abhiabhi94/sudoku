import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/engine/board.dart';
import 'package:sudoku/engine/hint_explainer.dart';

import '../support/fake_puzzle.dart';

void main() {
  test('naked single: the only candidate left in a cell', () {
    // Blanking one cell of a solved board leaves it with a single candidate.
    final board = List<int>.of(kFakeSolution)..[40] = 0;
    final e = explainHint(board, 40, kFakeSolution[40]);

    expect(e.kind, HintKind.nakedSingle);
    expect(e.digit, kFakeSolution[40]);
    expect(e.unit, HintUnit.none);
    // Every filled peer justifies it (20 peers, all filled here).
    expect(e.justifiers.length, 20);
  });

  test('hidden single: a digit fits only one spot in a row', () {
    // Empty board except one 5 in each of columns 1..8, in distinct boxes, so
    // 5 is blocked everywhere in row 0 except cell 0.
    final board = List<int>.filled(cellCount, 0);
    for (final i in [28, 56, 12, 40, 68, 24, 52, 80]) {
      board[i] = 5;
    }
    final e = explainHint(board, 0, 5);

    expect(e.kind, HintKind.hiddenSingle);
    expect(e.digit, 5);
    expect(e.unit, HintUnit.row);
    // The rest of row 0 is highlighted as the reason.
    expect(e.justifiers, containsAll(<int>[1, 2, 3, 4, 5, 6, 7, 8]));
    expect(e.justifiers, isNot(contains(0)));
  });

  test('advanced fallback when no simple single applies', () {
    final board = List<int>.filled(cellCount, 0);
    final e = explainHint(board, 0, 1);
    expect(e.kind, HintKind.advanced);
    expect(e.digit, 1);
  });
}
