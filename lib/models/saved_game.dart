/// A serializable snapshot of an in-progress game, so a player can leave
/// mid-puzzle and resume later. Pure Dart (no Flutter). Persisted as JSON via
/// [ActiveGameRepository]; there is a single "active game" slot (the game the
/// player last made a move in).
library;

import '../engine/puzzle_factory.dart';

class SavedGame {
  const SavedGame({
    required this.globalLevel,
    required this.puzzle,
    required this.board,
    required this.mistakes,
    required this.elapsedMs,
    required this.hintsUsed,
    required this.hintCells,
    required this.errorCells,
  });

  final int globalLevel;

  /// The exact puzzle in play (givens + solution), so resume restores the same
  /// board rather than generating a new one.
  final GeneratedPuzzle puzzle;

  final List<int> board;
  final int mistakes;
  final int elapsedMs;
  final int hintsUsed;
  final Set<int> hintCells;
  final Set<int> errorCells;

  /// Blank cells in the original puzzle (the cells the player must fill).
  int get _blankCount {
    var n = 0;
    for (final g in puzzle.givens) {
      if (g == 0) n++;
    }
    return n;
  }

  /// Blanks the player has since filled with a value.
  int get _filledCount {
    var n = 0;
    for (var i = 0; i < board.length; i++) {
      if (puzzle.givens[i] == 0 && board[i] != 0) n++;
    }
    return n;
  }

  /// Completion as a whole-number percent (0..100) of blanks filled.
  int get percentComplete {
    final blanks = _blankCount;
    if (blanks == 0) return 100;
    return (_filledCount * 100 / blanks).round();
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'level': globalLevel,
        'givens': puzzle.givens,
        'solution': puzzle.solution,
        'tier': puzzle.tier,
        'plevel': puzzle.level,
        'clues': puzzle.clueCount,
        'hardest': puzzle.hardestTier,
        'score': puzzle.score,
        'inBand': puzzle.inBand,
        'board': board,
        'mistakes': mistakes,
        'elapsedMs': elapsedMs,
        'hintsUsed': hintsUsed,
        'hintCells': hintCells.toList(),
        'errorCells': errorCells.toList(),
      };

  factory SavedGame.fromJson(Map<String, dynamic> json) {
    List<int> ints(String key) =>
        (json[key] as List).map((e) => e as int).toList();
    return SavedGame(
      globalLevel: json['level'] as int,
      puzzle: GeneratedPuzzle(
        givens: ints('givens'),
        solution: ints('solution'),
        tier: json['tier'] as int,
        level: json['plevel'] as int,
        clueCount: json['clues'] as int,
        hardestTier: json['hardest'] as int,
        score: json['score'] as int,
        inBand: json['inBand'] as bool,
      ),
      board: ints('board'),
      mistakes: json['mistakes'] as int,
      elapsedMs: json['elapsedMs'] as int,
      hintsUsed: json['hintsUsed'] as int,
      hintCells: ints('hintCells').toSet(),
      errorCells: ints('errorCells').toSet(),
    );
  }
}
