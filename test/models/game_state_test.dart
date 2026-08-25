import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/models/game_state.dart';
import 'package:sudoku/models/stroke.dart';

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

  test('cell notes default empty and survive copyWith', () {
    final s = GameState.playing(1, fakePuzzle(blanks: const [0, 1]));
    expect(s.cellNotes, isEmpty);
    expect(s.notesFor(0), isEmpty);

    const stroke = Stroke([Offset(0.1, 0.2), Offset(0.3, 0.4)]);
    final noted = s.copyWith(cellNotes: {
      0: const [stroke],
    });
    expect(noted.notesFor(0), const [stroke]);
    // Unrelated copyWith calls preserve the notes.
    expect(noted.copyWith(selectedIndex: 5).notesFor(0), const [stroke]);
  });

  group('activeDigit', () {
    test('is 0 when nothing is selected or highlighted', () {
      final s = GameState.playing(1, fakePuzzle(blanks: const [0, 1]));
      expect(s.highlightDigit, 0);
      expect(s.activeDigit, 0);
    });

    test('follows the selected cell when it holds a value', () {
      final s = GameState.playing(1, fakePuzzle(blanks: const [0, 1]));
      // Cell 2 is a given holding 4.
      expect(s.copyWith(selectedIndex: 2).activeDigit, kFakeSolution[2]);
    });

    test('falls back to the pad highlight when the selection is empty', () {
      final s = GameState.playing(1, fakePuzzle(blanks: const [0, 1]));
      // Cell 0 is blank, so the selection contributes nothing.
      final withHighlight =
          s.copyWith(selectedIndex: 0, highlightDigit: 7);
      expect(withHighlight.activeDigit, 7);
    });

    test('a deliberate pad tap outranks a filled selection', () {
      // selectCell clears the highlight, so a surviving one means the pad was
      // the player's most recent word — it should win.
      final s = GameState.playing(1, fakePuzzle(blanks: const [0, 1]));
      final both = s.copyWith(selectedIndex: 2, highlightDigit: 7);
      expect(both.activeDigit, 7);
    });

    test('is 0 while loading, with no board to index into', () {
      expect(GameState.loading(1).copyWith(selectedIndex: 4).activeDigit, 0);
    });

    test('copyWith carries the highlight, and 0 clears it', () {
      final s = GameState.playing(1, fakePuzzle(blanks: const [0, 1]))
          .copyWith(highlightDigit: 6);
      expect(s.copyWith(selectedIndex: 0).highlightDigit, 6);
      expect(s.copyWith(highlightDigit: 0).highlightDigit, 0);
    });

    test('is transient — not carried into a saved game', () {
      final s = GameState.playing(1, fakePuzzle(blanks: const [0, 1]))
          .copyWith(highlightDigit: 6);
      expect(GameState.restored(s.toSavedGame()).highlightDigit, 0);
    });
  });

  test('remainingForDigit counts placements left', () {
    final puzzle = fakePuzzle(blanks: const [0, 1]); // 0->5 and 1->3 missing
    final s = GameState.playing(1, puzzle);
    // Solution has nine 5s; one (cell 0) is blanked, so eight are placed.
    expect(s.remainingForDigit(5), 1);
    expect(GameState.loading(1).remainingForDigit(5), 9);
  });
}
