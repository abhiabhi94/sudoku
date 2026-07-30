/// Immutable gameplay state for a single puzzle. Pure Dart (no Flutter).
library;

import '../engine/board.dart';
import '../engine/hint_explainer.dart';
import '../engine/puzzle_factory.dart';
import 'saved_game.dart';
import 'stroke.dart';

/// Free wrong placements before the "you're guessing" lockout kicks in.
const int maxFreeMistakes = 3;

enum GamePhase { loading, playing, lockedOut, solved }

/// What a cell currently is, for rendering.
enum CellKind { given, userFilled, hint, error, empty }

class GameState {
  const GameState({
    required this.globalLevel,
    required this.puzzle,
    required this.board,
    required this.selectedIndex,
    required this.mistakes,
    required this.phase,
    required this.elapsedMs,
    required this.hintsUsed,
    required this.hintCells,
    required this.errorCells,
    required this.lockoutRemainingMs,
    this.cellNotes = const <int, List<Stroke>>{},
    this.lastHint,
  });

  final int globalLevel;

  /// The generated puzzle, or null while loading.
  final GeneratedPuzzle? puzzle;

  /// Current player values (81 cells, 0 = empty). Empty list while loading.
  final List<int> board;

  /// Selected cell (0..80), or -1 for none.
  final int selectedIndex;

  /// Total wrong placements made.
  final int mistakes;

  final GamePhase phase;

  /// Elapsed play time in milliseconds (paused during lockout).
  final int elapsedMs;

  final int hintsUsed;

  /// Cells revealed via hints (non-editable).
  final Set<int> hintCells;

  /// Cells currently holding a wrong value.
  final Set<int> errorCells;

  /// Remaining lockout time in milliseconds (>0 only while locked out).
  final int lockoutRemainingMs;

  /// Freehand scribble notes per cell (points normalised 0..1 within the cell).
  /// A cell with a placed value hides its notes but keeps them (erasing the
  /// value shows them again). Inert to mistakes/solve logic.
  final Map<int, List<Stroke>> cellNotes;

  /// The most recent hint's justification (for the "Why here?" card). Transient
  /// UI state — not persisted, cleared on the next move or selection.
  final HintExplanation? lastHint;

  /// Initial loading state for [level].
  factory GameState.loading(int level) => GameState(
        globalLevel: level,
        puzzle: null,
        board: const <int>[],
        selectedIndex: -1,
        mistakes: 0,
        phase: GamePhase.loading,
        elapsedMs: 0,
        hintsUsed: 0,
        hintCells: const <int>{},
        errorCells: const <int>{},
        lockoutRemainingMs: 0,
      );

  /// Fresh playing state for a generated [puzzle].
  factory GameState.playing(int level, GeneratedPuzzle puzzle) => GameState(
        globalLevel: level,
        puzzle: puzzle,
        board: List<int>.of(puzzle.givens),
        selectedIndex: -1,
        mistakes: 0,
        phase: GamePhase.playing,
        elapsedMs: 0,
        hintsUsed: 0,
        hintCells: <int>{},
        errorCells: <int>{},
        lockoutRemainingMs: 0,
      );

  /// Restores a playing state from a persisted [SavedGame]. A transient lockout
  /// is not restored (resume always drops back into normal play).
  factory GameState.restored(SavedGame saved) => GameState(
        globalLevel: saved.globalLevel,
        puzzle: saved.puzzle,
        board: List<int>.of(saved.board),
        selectedIndex: -1,
        mistakes: saved.mistakes,
        phase: GamePhase.playing,
        elapsedMs: saved.elapsedMs,
        hintsUsed: saved.hintsUsed,
        hintCells: Set<int>.of(saved.hintCells),
        errorCells: Set<int>.of(saved.errorCells),
        lockoutRemainingMs: 0,
        cellNotes: Map<int, List<Stroke>>.of(saved.cellNotes),
      );

  /// Snapshots the current play for persistence. Only valid once [puzzle] loaded.
  SavedGame toSavedGame() => SavedGame(
        globalLevel: globalLevel,
        puzzle: puzzle!,
        board: board,
        mistakes: mistakes,
        elapsedMs: elapsedMs,
        hintsUsed: hintsUsed,
        hintCells: hintCells,
        errorCells: errorCells,
        cellNotes: cellNotes,
      );

  /// The scribble strokes stored for [index] (empty when the cell has none).
  List<Stroke> notesFor(int index) =>
      cellNotes[index] ?? const <Stroke>[];

  bool get isLoading => phase == GamePhase.loading;
  bool get isSolved => phase == GamePhase.solved;
  bool get isLockedOut => phase == GamePhase.lockedOut;

  /// Whether the digit at [index] is fixed (a given or a revealed hint).
  bool isLocked(int index) =>
      puzzle != null && (puzzle!.givens[index] != 0 || hintCells.contains(index));

  bool isEditable(int index) => puzzle != null && !isLocked(index);

  CellKind cellKind(int index) {
    if (puzzle == null) return CellKind.empty;
    if (puzzle!.givens[index] != 0) return CellKind.given;
    if (hintCells.contains(index)) return CellKind.hint;
    if (errorCells.contains(index)) return CellKind.error;
    if (board[index] != 0) return CellKind.userFilled;
    return CellKind.empty;
  }

  /// How many of digit [d] (1..9) still need placing (for the number pad).
  int remainingForDigit(int d) {
    if (puzzle == null) return boardSize;
    var placed = 0;
    for (final v in board) {
      if (v == d) placed++;
    }
    return boardSize - placed;
  }

  GameState copyWith({
    GeneratedPuzzle? puzzle,
    List<int>? board,
    int? selectedIndex,
    int? mistakes,
    GamePhase? phase,
    int? elapsedMs,
    int? hintsUsed,
    Set<int>? hintCells,
    Set<int>? errorCells,
    int? lockoutRemainingMs,
    Map<int, List<Stroke>>? cellNotes,
    HintExplanation? lastHint,
    bool clearHint = false,
  }) {
    return GameState(
      globalLevel: globalLevel,
      puzzle: puzzle ?? this.puzzle,
      board: board ?? this.board,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      mistakes: mistakes ?? this.mistakes,
      phase: phase ?? this.phase,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      hintCells: hintCells ?? this.hintCells,
      errorCells: errorCells ?? this.errorCells,
      lockoutRemainingMs: lockoutRemainingMs ?? this.lockoutRemainingMs,
      cellNotes: cellNotes ?? this.cellNotes,
      lastHint: clearHint ? null : (lastHint ?? this.lastHint),
    );
  }
}
