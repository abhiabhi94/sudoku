import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/engine/puzzle_factory.dart';
import 'package:sudoku/models/game_state.dart';
import 'package:sudoku/models/saved_game.dart';
import 'package:sudoku/models/stroke.dart';
import 'package:sudoku/providers/game_provider.dart';

import '../support/fake_puzzle.dart';

/// Builds a notifier with a synchronous generator and no real timer.
GameNotifier makeNotifier({
  List<int> blanks = const [0, 1],
  void Function(int level, int ms)? onSolved,
  int randomSeed = 0,
}) {
  Future<GeneratedPuzzle> gen(int t, int l, int s) async =>
      fakePuzzle(blanks: blanks);
  return GameNotifier(
    globalLevel: 1,
    generator: gen,
    onSolved: onSolved,
    random: Random(randomSeed),
    seedSource: () => 0,
    autoTick: false,
  );
}

void main() {
  test('loads a puzzle and enters playing', () async {
    final n = makeNotifier();
    addTearDown(n.dispose);
    await n.ready;
    expect(n.state.phase, GamePhase.playing);
    expect(n.state.board, fakePuzzle().givens);
  });

  test('selecting and entering a correct digit places it without a mistake',
      () async {
    final n = makeNotifier();
    addTearDown(n.dispose);
    await n.ready;

    n.selectCell(0);
    expect(n.state.selectedIndex, 0);
    n.inputDigit(kFakeSolution[0]);
    expect(n.state.board[0], kFakeSolution[0]);
    expect(n.state.mistakes, 0);
    expect(n.state.errorCells, isEmpty);
  });

  group('moveSelection', () {
    test('walks the selection and clamps at the edges', () async {
      final n = makeNotifier();
      addTearDown(n.dispose);
      await n.ready;

      n.selectCell(40); // row 4, col 4
      n.moveSelection(-1, 0);
      expect(n.state.selectedIndex, 31);
      n.moveSelection(1, 1);
      expect(n.state.selectedIndex, 41);
      n.moveSelection(0, -1);
      expect(n.state.selectedIndex, 40);

      n.selectCell(0);
      n.moveSelection(-1, -1);
      expect(n.state.selectedIndex, 0, reason: 'clamped at the top-left');
      n.selectCell(80);
      n.moveSelection(1, 1);
      expect(n.state.selectedIndex, 80, reason: 'clamped at the bottom-right');
    });

    test('the first press with nothing selected lands on the first cell',
        () async {
      final n = makeNotifier();
      addTearDown(n.dispose);
      await n.ready;
      expect(n.state.selectedIndex, -1);

      n.moveSelection(1, 0);
      expect(n.state.selectedIndex, 0);
    });

    test('does nothing while the game is not playing', () async {
      final n = makeNotifier(blanks: kWrongBlanks);
      addTearDown(n.dispose);
      await n.ready;
      n.selectCell(kWrongCell);
      for (var i = 0; i < 4; i++) {
        n.inputDigit(kWrongDigit);
      }
      expect(n.state.phase, GamePhase.lockedOut);

      n.moveSelection(1, 0);
      expect(n.state.selectedIndex, kWrongCell);
    });
  });

  test('a wrong digit records a mistake and marks the cell', () async {
    final n = makeNotifier(blanks: kWrongBlanks);
    addTearDown(n.dispose);
    await n.ready;

    n.selectCell(kWrongCell);
    n.inputDigit(kWrongDigit);
    expect(n.state.mistakes, 1);
    expect(n.state.errorCells, contains(kWrongCell));
    expect(n.state.cellKind(kWrongCell), CellKind.error);
  });

  test('cannot edit a given cell', () async {
    final n = makeNotifier();
    addTearDown(n.dispose);
    await n.ready;
    n.selectCell(2); // a given
    n.inputDigit(1);
    expect(n.state.board[2], fakePuzzle().givens[2]);
    expect(n.state.mistakes, 0);
  });

  test('erase clears a filled editable cell', () async {
    final n = makeNotifier(blanks: kWrongBlanks);
    addTearDown(n.dispose);
    await n.ready;
    n.selectCell(kWrongCell);
    n.inputDigit(kWrongDigit); // wrong
    expect(n.state.board[kWrongCell], kWrongDigit);
    n.erase();
    expect(n.state.board[kWrongCell], 0);
    expect(n.state.errorCells, isEmpty);
  });

  test('a fourth wrong placement triggers the lockout', () async {
    final n = makeNotifier(blanks: kWrongBlanks);
    addTearDown(n.dispose);
    await n.ready;

    n.selectCell(kWrongCell);
    for (var i = 0; i < 4; i++) {
      n.inputDigit(kWrongDigit);
    }
    expect(n.state.mistakes, 4);
    expect(n.state.phase, GamePhase.lockedOut);
    expect(n.state.lockoutRemainingMs, inInclusiveRange(3000, 5000));

    // Placement is ignored while locked out (the tap only highlights).
    n.inputDigit(kWrongDigit);
    expect(n.state.mistakes, 4);

    // Ticking counts the lockout down, not the play clock.
    final lockSeconds = n.state.lockoutRemainingMs ~/ 1000;
    final start = n.state.elapsedMs;
    for (var i = 0; i < lockSeconds; i++) {
      n.tickSecond();
    }
    expect(n.state.phase, GamePhase.playing);
    expect(n.state.lockoutRemainingMs, 0);
    expect(n.state.elapsedMs, start);
  });

  test('tickSecond advances the clock only while playing', () async {
    final n = makeNotifier();
    addTearDown(n.dispose);
    await n.ready;
    n.tickSecond();
    n.tickSecond();
    expect(n.state.elapsedMs, 2000);
  });

  test('solving the board records completion', () async {
    var solvedLevel = -1;
    var solvedMs = -1;
    final n = makeNotifier(
      blanks: const [0, 1],
      onSolved: (level, ms) {
        solvedLevel = level;
        solvedMs = ms;
      },
    );
    addTearDown(n.dispose);
    await n.ready;

    n.tickSecond(); // 1s on the clock
    n.selectCell(0);
    n.inputDigit(kFakeSolution[0]);
    expect(n.state.phase, GamePhase.playing);
    n.selectCell(1);
    n.inputDigit(kFakeSolution[1]);

    expect(n.state.phase, GamePhase.solved);
    expect(n.state.isSolved, isTrue);
    expect(solvedLevel, 1);
    expect(solvedMs, 1000);
  });

  group('hints', () {
    test('applyHint reveals a correct, locked cell', () async {
      final n = makeNotifier(blanks: const [0, 1]);
      addTearDown(n.dispose);
      await n.ready;

      n.applyHint();
      expect(n.state.hintsUsed, 1);
      expect(n.state.hintCells, isNotEmpty);
      final revealed = n.state.hintCells.first;
      expect(n.state.board[revealed], kFakeSolution[revealed]);
      expect(n.state.isLocked(revealed), isTrue);
    });

    test('applyHint falls back to the solution when logic is stuck', () async {
      // An all-empty board gives firstHint nothing to deduce, exercising the
      // solution fallback.
      final n = makeNotifier(blanks: List<int>.generate(81, (i) => i));
      addTearDown(n.dispose);
      await n.ready;

      n.applyHint();
      expect(n.state.hintsUsed, 1);
      final cell = n.state.hintCells.first;
      expect(n.state.board[cell], kFakeSolution[cell]);
    });

    test('a hint can complete the puzzle', () async {
      var solved = false;
      final n = makeNotifier(blanks: const [0], onSolved: (_, _) => solved = true);
      addTearDown(n.dispose);
      await n.ready;
      n.applyHint(); // fills the single remaining cell
      expect(n.state.phase, GamePhase.solved);
      expect(solved, isTrue);
    });
  });

  group('same-digit highlight', () {
    test('a pad tap with nothing selected highlights instead of placing',
        () async {
      final n = makeNotifier(blanks: kWrongBlanks);
      addTearDown(n.dispose);
      await n.ready;

      expect(n.state.selectedIndex, -1);
      n.inputDigit(kWrongDigit);
      expect(n.state.highlightDigit, kWrongDigit);
      expect(n.state.activeDigit, kWrongDigit);
      expect(n.state.mistakes, 0);
      expect(n.state.board, fakePuzzle(blanks: kWrongBlanks).givens);
    });

    test('tapping the same digit again toggles the highlight off', () async {
      final n = makeNotifier(blanks: kWrongBlanks);
      addTearDown(n.dispose);
      await n.ready;

      n.inputDigit(4);
      expect(n.state.highlightDigit, 4);
      n.inputDigit(4);
      expect(n.state.highlightDigit, 0);
      // A different digit replaces rather than clears.
      n.inputDigit(4);
      n.inputDigit(6);
      expect(n.state.highlightDigit, 6);
    });

    test('selecting a cell hands the highlight back to the selection',
        () async {
      final n = makeNotifier(blanks: kWrongBlanks);
      addTearDown(n.dispose);
      await n.ready;

      n.inputDigit(4);
      expect(n.state.highlightDigit, 4);
      n.selectCell(2); // a given holding 4's neighbour
      expect(n.state.highlightDigit, 0);
      expect(n.state.activeDigit, kFakeSolution[2]);
    });

    test('a fully-placed digit highlights rather than becoming a mistake',
        () async {
      // The default fixture leaves every digit but 5 and 3 fully placed.
      final n = makeNotifier(blanks: const [0, 1]);
      addTearDown(n.dispose);
      await n.ready;

      n.selectCell(0); // empty and editable
      expect(n.state.remainingForDigit(1), 0);
      n.inputDigit(1);
      expect(n.state.mistakes, 0);
      expect(n.state.board[0], 0);
      expect(n.state.highlightDigit, 1);
    });

    test('stays available during the lockout — looking is not playing',
        () async {
      final n = makeNotifier(blanks: kWrongBlanks);
      addTearDown(n.dispose);
      await n.ready;

      n.selectCell(kWrongCell);
      for (var i = 0; i < 4; i++) {
        n.inputDigit(kWrongDigit);
      }
      expect(n.state.phase, GamePhase.lockedOut);

      n.inputDigit(6);
      expect(n.state.highlightDigit, 6);
      expect(n.state.mistakes, 4); // still no new mistake
    });

    test('placing a digit clears a stale highlight', () async {
      final n = makeNotifier(blanks: kWrongBlanks);
      addTearDown(n.dispose);
      await n.ready;

      n.inputDigit(4); // highlight, nothing selected
      n.selectCell(kWrongCell);
      n.inputDigit(kFakeSolution[kWrongCell]);
      expect(n.state.highlightDigit, 0);
    });

    test('a pad tap overrides the digit a filled selection was showing',
        () async {
      final n = makeNotifier(blanks: kWrongBlanks);
      addTearDown(n.dispose);
      await n.ready;

      n.selectCell(2); // a given, so nothing can be placed here
      expect(n.state.activeDigit, kFakeSolution[2]);

      n.inputDigit(6);
      expect(n.state.activeDigit, 6);
    });

    test('is ignored once the puzzle is solved', () async {
      final n = makeNotifier(blanks: const [0]);
      addTearDown(n.dispose);
      await n.ready;

      n.selectCell(0);
      n.inputDigit(kFakeSolution[0]);
      expect(n.state.phase, GamePhase.solved);
      n.inputDigit(7);
      expect(n.state.highlightDigit, 0);
    });
  });

  test('newPuzzle regenerates and resets state', () async {
    final n = makeNotifier(blanks: kWrongBlanks);
    addTearDown(n.dispose);
    await n.ready;
    n.selectCell(kWrongCell);
    n.inputDigit(kWrongDigit); // a mistake
    expect(n.state.mistakes, 1);

    await n.newPuzzle();
    expect(n.state.phase, GamePhase.playing);
    expect(n.state.mistakes, 0);
    expect(n.state.selectedIndex, -1);
  });

  group('hint explanation', () {
    test('applyHint attaches a "why here" explanation', () async {
      final n = makeNotifier(blanks: const [0, 1]);
      addTearDown(n.dispose);
      await n.ready;

      n.applyHint();
      expect(n.state.lastHint, isNotNull);
      expect(n.state.lastHint!.digit, isPositive);
    });

    test('selecting a cell clears the explanation', () async {
      final n = makeNotifier(blanks: const [0, 1]);
      addTearDown(n.dispose);
      await n.ready;

      n.applyHint();
      expect(n.state.lastHint, isNotNull);
      n.selectCell(1);
      expect(n.state.lastHint, isNull);
    });

    test('dismissHint clears the explanation', () async {
      final n = makeNotifier(blanks: const [0, 1]);
      addTearDown(n.dispose);
      await n.ready;

      n.applyHint();
      expect(n.state.lastHint, isNotNull);
      n.dismissHint();
      expect(n.state.lastHint, isNull);
    });
  });

  group('cell notes', () {
    const stroke = Stroke([Offset(0.1, 0.2), Offset(0.4, 0.5)]);

    test('setCellNotes stores strokes for an editable cell and persists',
        () async {
      final snapshots = <SavedGame>[];
      final n = GameNotifier(
        globalLevel: 1,
        generator: (t, l, s) async => fakePuzzle(blanks: const [0, 1]),
        seedSource: () => 0,
        autoTick: false,
        onPersist: snapshots.add,
      );
      addTearDown(n.dispose);
      await n.ready;

      n.setCellNotes(0, const [stroke]);
      expect(n.state.notesFor(0), const [stroke]);
      expect(snapshots.last.cellNotes[0], const [stroke]);
    });

    test('an empty stroke list drops the cell entry', () async {
      final n = makeNotifier();
      addTearDown(n.dispose);
      await n.ready;

      n.setCellNotes(0, const [stroke]);
      expect(n.state.cellNotes.containsKey(0), isTrue);
      n.setCellNotes(0, const []);
      expect(n.state.cellNotes.containsKey(0), isFalse);
    });

    test('notes are rejected on a given (non-editable) cell', () async {
      final n = makeNotifier();
      addTearDown(n.dispose);
      await n.ready;
      n.setCellNotes(2, const [stroke]); // cell 2 is a given
      expect(n.state.notesFor(2), isEmpty);
    });
  });

  test('persistNow snapshots the current game', () async {
    final snapshots = <int>[];
    final n = GameNotifier(
      globalLevel: 1,
      generator: (t, l, s) async => fakePuzzle(blanks: const [0, 1]),
      seedSource: () => 0,
      autoTick: false,
      onPersist: (snap) => snapshots.add(snap.elapsedMs),
    );
    addTearDown(n.dispose);
    await n.ready;

    n.persistNow();
    expect(snapshots, isNotEmpty);
  });
}
