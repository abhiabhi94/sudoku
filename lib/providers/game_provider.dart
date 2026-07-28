/// Per-level gameplay state: puzzle generation (on a background isolate),
/// cell input, the 3-mistake lockout, the timer, hints and win detection.
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/board.dart';
import '../engine/puzzle_factory.dart';
import '../engine/techniques.dart';
import '../models/game_state.dart';
import '../services/haptics_service.dart';
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
    this.haptics,
    this.generator = defaultPuzzleGenerator,
    Random? random,
    int Function()? seedSource,
    this.autoTick = true,
  })  : _random = random ?? Random(),
        _seedSource = seedSource ?? (() => DateTime.now().microsecondsSinceEpoch),
        super(GameState.loading(globalLevel)) {
    _load();
  }

  final int globalLevel;
  final void Function(int level, int elapsedMs)? onSolved;
  final HapticsService? haptics;
  final PuzzleGenerator generator;
  final Random _random;
  final int Function() _seedSource;
  final bool autoTick;

  Timer? _timer;
  final Completer<void> _ready = Completer<void>();

  /// Completes once the first puzzle has been generated (useful in tests).
  Future<void> get ready => _ready.future;

  int get _tier => (globalLevel - 1) ~/ 10 + 1;
  int get _level => (globalLevel - 1) % 10 + 1;

  Future<void> _load() async {
    final seed = _seedSource() ^ (globalLevel * 2654435761);
    final puzzle = await generator(_tier, _level, seed);
    if (!mounted) return;
    state = GameState.playing(globalLevel, puzzle);
    _startTimer();
    if (!_ready.isCompleted) _ready.complete();
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
    state = state.copyWith(selectedIndex: index);
    haptics?.tap();
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
      );
      if (solved) _handleSolved();
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
        );
        haptics?.lockout();
      } else {
        state = state.copyWith(
          board: board,
          errorCells: errors,
          mistakes: mistakes,
        );
      }
    }
  }

  void erase() {
    if (state.phase != GamePhase.playing) return;
    final index = state.selectedIndex;
    if (index < 0 || !state.isEditable(index) || state.board[index] == 0) return;
    state = state.copyWith(
      board: List<int>.of(state.board)..[index] = 0,
      errorCells: Set<int>.of(state.errorCells)..remove(index),
    );
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

    final board = List<int>.of(state.board)..[index] = digit;
    final solved = _isBoardSolved(board, puzzle);
    state = state.copyWith(
      board: board,
      selectedIndex: index,
      errorCells: Set<int>.of(state.errorCells)..remove(index),
      hintCells: Set<int>.of(state.hintCells)..add(index),
      hintsUsed: state.hintsUsed + 1,
      phase: solved ? GamePhase.solved : GamePhase.playing,
    );
    if (solved) _handleSolved();
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

// coverage:ignore-start
final gameProvider =
    StateNotifierProvider.autoDispose.family<GameNotifier, GameState, int>(
  (ref, globalLevel) => GameNotifier(
    globalLevel: globalLevel,
    haptics: ref.read(hapticsProvider),
    onSolved: (level, ms) =>
        ref.read(progressProvider.notifier).recordCompletion(level, ms),
  ),
);
// coverage:ignore-end
