/// Per-level gameplay state: puzzle generation (on a background isolate),
/// cell input, the 3-mistake lockout, the timer, hints and win detection.
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/board.dart';
import '../engine/hint_explainer.dart';
import '../engine/puzzle_factory.dart';
import '../engine/techniques.dart';
import '../models/game_state.dart';
import '../models/saved_game.dart';
import '../models/stroke.dart';
import '../services/haptics_service.dart';
import 'active_game_provider.dart';
import 'progress_provider.dart';

/// Builds a puzzle for a band; the default runs on a background isolate.
typedef PuzzleGenerator = Future<GeneratedPuzzle> Function(
    int tier, int level, int seed);

// coverage:ignore-start
Future<GeneratedPuzzle> defaultPuzzleGenerator(int tier, int level, int seed) =>
    compute(generatePuzzleTask, PuzzleRequest(tier, level, seed));
// coverage:ignore-end

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier({
    required this.globalLevel,
    this.onSolved,
    this.onPersist,
    this.onFinish,
    SavedGame? restore,
    this.haptics,
    this.generator = defaultPuzzleGenerator,
    Random? random,
    int Function()? seedSource,
    this.autoTick = true,
  })  : _random = random ?? Random(),
        _seedSource = seedSource ?? (() => DateTime.now().microsecondsSinceEpoch),
        super(GameState.loading(globalLevel)) {
    _restore = restore;
    _load();
  }

  final int globalLevel;
  final void Function(int level, int elapsedMs)? onSolved;

  /// Persists a snapshot after each move so the game can be resumed later.
  final void Function(SavedGame snapshot)? onPersist;

  /// Clears the persisted snapshot once the game is over (solved).
  final void Function()? onFinish;
  final HapticsService? haptics;
  final PuzzleGenerator generator;
  final Random _random;
  final int Function() _seedSource;
  final bool autoTick;

  /// A snapshot to restore into instead of generating; consumed once on load.
  SavedGame? _restore;

  Timer? _timer;
  final Completer<void> _ready = Completer<void>();

  /// Completes once the first puzzle has been generated (useful in tests).
  Future<void> get ready => _ready.future;

  int get _tier => (globalLevel - 1) ~/ 10 + 1;
  int get _level => (globalLevel - 1) % 10 + 1;

  Future<void> _load() async {
    // Resume a persisted game if one was handed in (consumed once, so a later
    // "new puzzle" regenerates instead of restoring the same board).
    final restore = _restore;
    _restore = null;
    if (restore != null) {
      state = GameState.restored(restore);
      _startTimer();
      if (!_ready.isCompleted) _ready.complete();
      return;
    }

    final seed = _seedSource() ^ (globalLevel * 2654435761);
    final puzzle = await generator(_tier, _level, seed);
    if (!mounted) return;
    state = GameState.playing(globalLevel, puzzle);
    _startTimer();
    if (!_ready.isCompleted) _ready.complete();
  }

  /// Persists the current play so it can be resumed after the app is closed.
  void _persist() {
    final persist = onPersist;
    if (persist == null || state.puzzle == null) return;
    persist(state.toSavedGame());
  }

  void _startTimer() {
    _timer?.cancel();
    // coverage:ignore-start
    if (autoTick) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => tickSecond());
    }
    // coverage:ignore-end
  }

  /// Advances the clock by one second (or the lockout countdown). Public so the
  /// timer callback and tests can drive it.
  void tickSecond() {
    switch (state.phase) {
      case GamePhase.playing:
        state = state.copyWith(elapsedMs: state.elapsedMs + 1000);
      case GamePhase.lockedOut:
        final remaining = state.lockoutRemainingMs - 1000;
        state = remaining <= 0
            ? state.copyWith(phase: GamePhase.playing, lockoutRemainingMs: 0)
            : state.copyWith(lockoutRemainingMs: remaining);
      case GamePhase.loading:
      case GamePhase.solved:
        break;
    }
  }

  void selectCell(int index) {
    if (state.phase != GamePhase.playing) return;
    state = state.copyWith(selectedIndex: index, clearHint: true);
    haptics?.tap();
  }

  /// Dismisses the "Why here?" hint explanation card.
  void dismissHint() {
    if (state.lastHint != null) state = state.copyWith(clearHint: true);
  }

  /// Persists the current game immediately (e.g. when the app is backgrounded),
  /// capturing the up-to-the-second elapsed time.
  void persistNow() {
    if (state.phase == GamePhase.playing || state.phase == GamePhase.lockedOut) {
      _persist();
    }
  }

  void inputDigit(int digit) {
    if (state.phase != GamePhase.playing) return;
    final index = state.selectedIndex;
    if (index < 0 || !state.isEditable(index)) return;

    final puzzle = state.puzzle!;
    final board = List<int>.of(state.board)..[index] = digit;
    final errors = Set<int>.of(state.errorCells);

    if (puzzle.solution[index] == digit) {
      errors.remove(index);
      haptics?.correct();
      final solved = _isBoardSolved(board, puzzle);
      state = state.copyWith(
        board: board,
        errorCells: errors,
        phase: solved ? GamePhase.solved : GamePhase.playing,
        clearHint: true,
      );
      if (solved) {
        _handleSolved();
      } else {
        _persist();
      }
    } else {
      errors.add(index);
      final mistakes = state.mistakes + 1;
      haptics?.wrong();
      if (mistakes > maxFreeMistakes) {
        final seconds = 3 + _random.nextInt(3); // 3..5 seconds
        state = state.copyWith(
          board: board,
          errorCells: errors,
          mistakes: mistakes,
          phase: GamePhase.lockedOut,
          lockoutRemainingMs: seconds * 1000,
          clearHint: true,
        );
        haptics?.lockout();
      } else {
        state = state.copyWith(
          board: board,
          errorCells: errors,
          mistakes: mistakes,
          clearHint: true,
        );
      }
      _persist();
    }
  }

  /// Replaces the scribble notes for [index]. The panel owns the stroke list,
  /// so undo/clear are just list edits reported here; an empty list drops the
  /// entry. Notes are inert to the mistakes/solve logic.
  void setCellNotes(int index, List<Stroke> strokes) {
    if (state.phase != GamePhase.playing) return;
    if (index < 0 || !state.isEditable(index)) return;
    final notes = Map<int, List<Stroke>>.of(state.cellNotes);
    if (strokes.isEmpty) {
      notes.remove(index);
    } else {
      notes[index] = List<Stroke>.of(strokes);
    }
    state = state.copyWith(cellNotes: notes);
    _persist();
  }

  void erase() {
    if (state.phase != GamePhase.playing) return;
    final index = state.selectedIndex;
    if (index < 0 || !state.isEditable(index) || state.board[index] == 0) return;
    state = state.copyWith(
      board: List<int>.of(state.board)..[index] = 0,
      errorCells: Set<int>.of(state.errorCells)..remove(index),
      clearHint: true,
    );
    _persist();
  }

  /// Reveals one logically-deducible cell (fallback: the next empty cell from
  /// the stored solution). Stage 5 gates this behind the hint riddle.
  void applyHint() {
    if (state.phase != GamePhase.playing) return;
    final puzzle = state.puzzle!;
    final deduction = firstHint(state.board);

    final int index;
    final int digit;
    if (deduction != null) {
      index = deduction.index;
      digit = deduction.digit;
    } else {
      final empty = _firstEmpty(state.board);
      if (empty < 0) return;
      index = empty;
      digit = puzzle.solution[empty];
    }

    // Explain the placement from the board *before* the digit lands.
    final explanation = explainHint(state.board, index, digit);
    final board = List<int>.of(state.board)..[index] = digit;
    final solved = _isBoardSolved(board, puzzle);
    state = state.copyWith(
      board: board,
      selectedIndex: index,
      errorCells: Set<int>.of(state.errorCells)..remove(index),
      hintCells: Set<int>.of(state.hintCells)..add(index),
      hintsUsed: state.hintsUsed + 1,
      phase: solved ? GamePhase.solved : GamePhase.playing,
      lastHint: explanation,
    );
    if (solved) {
      _handleSolved();
    } else {
      _persist();
    }
  }

  /// Regenerates a fresh puzzle for the same level.
  Future<void> newPuzzle() async {
    _timer?.cancel();
    state = GameState.loading(globalLevel);
    await _load();
  }

  void _handleSolved() {
    _timer?.cancel();
    haptics?.victory();
    // A finished game isn't resumable — drop the saved snapshot.
    onFinish?.call();
    onSolved?.call(globalLevel, state.elapsedMs);
  }

  static bool _isBoardSolved(List<int> board, GeneratedPuzzle puzzle) {
    for (var i = 0; i < cellCount; i++) {
      if (board[i] != puzzle.solution[i]) return false;
    }
    return true;
  }

  static int _firstEmpty(List<int> board) {
    for (var i = 0; i < board.length; i++) {
      if (board[i] == 0) return i;
    }
    return -1;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Family key for [gameProvider]: which level, and whether to resume the saved
/// game (true only from the home "Continue" card) or deal a fresh puzzle.
typedef GameArgs = ({int level, bool resume});

// coverage:ignore-start
final gameProvider =
    StateNotifierProvider.autoDispose.family<GameNotifier, GameState, GameArgs>(
  (ref, args) {
    final active = ref.read(activeGameProvider.notifier);
    final saved = args.resume ? ref.read(activeGameProvider) : null;
    return GameNotifier(
      globalLevel: args.level,
      restore: saved != null && saved.globalLevel == args.level ? saved : null,
      haptics: ref.read(hapticsProvider),
      onPersist: active.save,
      onFinish: active.clear,
      onSolved: (level, ms) =>
          ref.read(progressProvider.notifier).recordCompletion(level, ms),
    );
  },
);
// coverage:ignore-end
