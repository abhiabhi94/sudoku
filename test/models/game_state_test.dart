import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/models/game_state.dart';

import '../support/fake_puzzle.dart';

void main() {
  test('loading state has no puzzle and empty board', () {
    final s = GameState.loading(7);
    expect(s.globalLevel, 7);
    expect(s.puzzle, isNull);
    expect(s.isLoading, isTrue);
    expect(s.board, isEmpty);
  });

  test('playing state copies givens into the board', () {
    final puzzle = fakePuzzle(blanks: const [0, 1]);
    final s = GameState.playing(1, puzzle);
    expect(s.phase, GamePhase.playing);
    expect(s.board, puzzle.givens);
    expect(identical(s.board, puzzle.givens), isFalse);
  });

  group('cellKind', () {
    final puzzle = fakePuzzle(blanks: const [0, 1]);
    final base = GameState.playing(1, puzzle);

    test('classifies given, empty, user-filled, hint and error cells', () {
      expect(base.cellKind(2), CellKind.given); // a given
      expect(base.cellKind(0), CellKind.empty); // a blank

      final filled = base.copyWith(board: List<int>.of(base.board)..[0] = 5);
      expect(filled.cellKind(0), CellKind.userFilled);

      final hinted = filled.copyWith(hintCells: {0});
      expect(hinted.cellKind(0), CellKind.hint);

      final errored = base.copyWith(
        board: List<int>.of(base.board)..[0] = 9,
        errorCells: {0},
      );
      expect(errored.cellKind(0), CellKind.error);
    });

    test('loading state reports every cell as empty', () {
      expect(GameState.loading(1).cellKind(0), CellKind.empty);
    });
  });

  test('isLocked / isEditable respect givens and hints', () {
    final puzzle = fakePuzzle(blanks: const [0, 1]);
    final s = GameState.playing(1, puzzle).copyWith(hintCells: {1});
    expect(s.isLocked(2), isTrue); // given
    expect(s.isLocked(1), isTrue); // hint
    expect(s.isEditable(0), isTrue); // blank
    expect(s.isEditable(2), isFalse);
  });

  test('remainingForDigit counts placements left', () {
    final puzzle = fakePuzzle(blanks: const [0, 1]); // 0->5 and 1->3 missing
    final s = GameState.playing(1, puzzle);
    // Solution has nine 5s; one (cell 0) is blanked, so eight are placed.
    expect(s.remainingForDigit(5), 1);
    expect(GameState.loading(1).remainingForDigit(5), 9);
  });
}
