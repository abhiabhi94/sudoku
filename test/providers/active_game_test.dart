import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/engine/puzzle_factory.dart';
import 'package:sudoku/models/game_state.dart';
import 'package:sudoku/models/saved_game.dart';
import 'package:sudoku/models/stroke.dart';
import 'package:sudoku/providers/active_game_provider.dart';
import 'package:sudoku/providers/game_provider.dart';

import '../support/fake_puzzle.dart';

SavedGame _sample() {
  final puzzle = fakePuzzle(blanks: const [0, 1, 2]);
  final board = List<int>.of(puzzle.givens)..[0] = kFakeSolution[0];
  return SavedGame(
    globalLevel: 7,
    puzzle: puzzle,
    board: board,
    mistakes: 2,
    elapsedMs: 42_000,
    hintsUsed: 1,
    hintCells: const <int>{1},
    errorCells: const <int>{2},
  );
}

Future<ActiveGameRepository> _repo() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  return ActiveGameRepository(prefs);
}

void main() {
  group('SavedGame', () {
    test('survives a JSON round-trip', () {
      final restored = SavedGame.fromJson(_sample().toJson());
      final original = _sample();
      expect(restored.globalLevel, original.globalLevel);
      expect(restored.board, original.board);
      expect(restored.puzzle.solution, original.puzzle.solution);
      expect(restored.mistakes, 2);
      expect(restored.elapsedMs, 42_000);
      expect(restored.hintsUsed, 1);
      expect(restored.hintCells, {1});
      expect(restored.errorCells, {2});
    });

    test('percentComplete reflects filled blanks', () {
      // 3 blanks, 1 filled -> 33%.
      expect(_sample().percentComplete, 33);
    });

    test('round-trips per-cell scribble notes', () {
      final puzzle = fakePuzzle(blanks: const [0, 1, 2]);
      final game = SavedGame(
        globalLevel: 7,
        puzzle: puzzle,
        board: List<int>.of(puzzle.givens),
        mistakes: 0,
        elapsedMs: 0,
        hintsUsed: 0,
        hintCells: const <int>{},
        errorCells: const <int>{},
        cellNotes: const {
          0: [Stroke([Offset(0.1, 0.2), Offset(0.3, 0.4)])],
          5: [
            Stroke([Offset(0.5, 0.5), Offset(0.9, 0.1)]),
            Stroke([Offset(0.2, 0.8), Offset(0.7, 0.3)]),
          ],
        },
      );
      final restored = SavedGame.fromJson(game.toJson());
      expect(restored.cellNotes.keys.toSet(), {0, 5});
      expect(restored.cellNotes[0]!.single.points,
          [const Offset(0.1, 0.2), const Offset(0.3, 0.4)]);
      expect(restored.cellNotes[5], hasLength(2));
      expect(restored.cellNotes[5]![1].points.last, const Offset(0.7, 0.3));
    });

    test('a legacy save without the notes key loads with empty notes', () {
      final json = _sample().toJson()..remove('cellNotes');
      expect(SavedGame.fromJson(json).cellNotes, isEmpty);
    });
  });

  group('ActiveGameRepository', () {
    test('load returns null when nothing is stored', () async {
      final repo = await _repo();
      expect(repo.load(), isNull);
    });

    test('save then load returns an equivalent game', () async {
      final repo = await _repo();
      await repo.save(_sample());
      final loaded = repo.load();
      expect(loaded, isNotNull);
      expect(loaded!.globalLevel, 7);
      expect(loaded.board, _sample().board);
    });

    test('clear removes the stored game', () async {
      final repo = await _repo();
      await repo.save(_sample());
      await repo.clear();
      expect(repo.load(), isNull);
    });
  });

  group('ActiveGameNotifier', () {
    test('save and clear update state and storage', () async {
      final repo = await _repo();
      final notifier = ActiveGameNotifier(repo);
      addTearDown(notifier.dispose);

      notifier.save(_sample());
      expect(notifier.state?.globalLevel, 7);
      expect(repo.load(), isNotNull);

      notifier.clear();
      expect(notifier.state, isNull);
      expect(repo.load(), isNull);
    });
  });

  group('GameNotifier persistence', () {
    GameNotifier build({
      SavedGame? restore,
      void Function(SavedGame)? onPersist,
      void Function()? onFinish,
    }) {
      Future<GeneratedPuzzle> gen(int t, int l, int s) async =>
          fakePuzzle(blanks: const [0, 1]);
      return GameNotifier(
        globalLevel: 1,
        generator: gen,
        restore: restore,
        onPersist: onPersist,
        onFinish: onFinish,
        seedSource: () => 0,
        autoTick: false,
      );
    }

    test('persists a snapshot after each move', () async {
      final snapshots = <SavedGame>[];
      final n = build(onPersist: snapshots.add);
      addTearDown(n.dispose);
      await n.ready;

      n.selectCell(1);
      n.inputDigit(kFakeSolution[1] == 1 ? 2 : 1); // a wrong move
      expect(snapshots, isNotEmpty);
      expect(snapshots.last.mistakes, 1);
    });

    test('clears (not persists) once the puzzle is solved', () async {
      var cleared = false;
      final snapshots = <SavedGame>[];
      final n = build(onPersist: snapshots.add, onFinish: () => cleared = true);
      addTearDown(n.dispose);
      await n.ready;

      // Only cell 0 is blank in a [0]-blank puzzle; but we used [0,1] blanks,
      // so fill both correctly to win.
      n.selectCell(0);
      n.inputDigit(kFakeSolution[0]);
      n.selectCell(1);
      n.inputDigit(kFakeSolution[1]);

      expect(n.state.phase, GamePhase.solved);
      expect(cleared, isTrue);
    });

    test('restores a saved game instead of generating', () async {
      final n = build(restore: _sample());
      addTearDown(n.dispose);
      await n.ready;
      expect(n.state.phase, GamePhase.playing);
      expect(n.state.mistakes, 2);
      expect(n.state.elapsedMs, 42_000);
      expect(n.state.hintCells, {1});
    });

    test('newPuzzle after a restore deals a fresh board (no re-restore)',
        () async {
      final n = build(restore: _sample());
      addTearDown(n.dispose);
      await n.ready;
      expect(n.state.mistakes, 2);

      await n.newPuzzle();
      expect(n.state.phase, GamePhase.playing);
      expect(n.state.mistakes, 0);
      expect(n.state.elapsedMs, 0);
    });
  });
}
