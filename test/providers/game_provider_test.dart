import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/engine/puzzle_factory.dart';
import 'package:sudoku/models/game_state.dart';
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

  test('a wrong digit records a mistake and marks the cell', () async {
    final n = makeNotifier();
    addTearDown(n.dispose);
    await n.ready;

    n.selectCell(0);
    final wrong = kFakeSolution[0] == 1 ? 2 : 1;
    n.inputDigit(wrong);
    expect(n.state.mistakes, 1);
    expect(n.state.errorCells, contains(0));
    expect(n.state.cellKind(0), CellKind.error);
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
    final n = makeNotifier();
    addTearDown(n.dispose);
    await n.ready;
    n.selectCell(0);
    n.inputDigit(kFakeSolution[0] == 1 ? 2 : 1); // wrong
    n.erase();
    expect(n.state.board[0], 0);
    expect(n.state.errorCells, isEmpty);
  });

  test('a fourth wrong placement triggers the lockout', () async {
    final n = makeNotifier();
    addTearDown(n.dispose);
    await n.ready;

    n.selectCell(0);
    final wrong = kFakeSolution[0] == 1 ? 2 : 1;
    for (var i = 0; i < 4; i++) {
      n.inputDigit(wrong);
    }
    expect(n.state.mistakes, 4);
    expect(n.state.phase, GamePhase.lockedOut);
    expect(n.state.lockoutRemainingMs, inInclusiveRange(3000, 5000));

    // Input is ignored while locked out.
    n.inputDigit(wrong);
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

  test('newPuzzle regenerates and resets state', () async {
    final n = makeNotifier();
    addTearDown(n.dispose);
    await n.ready;
    n.selectCell(0);
    n.inputDigit(kFakeSolution[0] == 1 ? 2 : 1); // a mistake
    expect(n.state.mistakes, 1);

    await n.newPuzzle();
    expect(n.state.phase, GamePhase.playing);
    expect(n.state.mistakes, 0);
    expect(n.state.selectedIndex, -1);
  });
}
