/// Puzzle generation: build a random complete solution, then carve it into a
/// puzzle with a unique solution. Pure Dart, no Flutter.
library;

import 'dart:math';

import 'board.dart';
import 'solver.dart';

/// Generates a random, complete, valid Sudoku solution using randomized MRV
/// backtracking. With an empty starting grid this effectively never
/// backtracks, so it returns in well under a millisecond.
List<int> generateFullSolution(Random rng) {
  final cells = List<int>.filled(cellCount, 0);
  final ok = _fill(cells, rng);
  assert(ok, 'An empty grid is always solvable.');
  return cells;
}

bool _fill(List<int> cells, Random rng) {
  var bestIndex = -1;
  var bestMask = 0;
  var bestCount = boardSize + 1;
  for (var i = 0; i < cellCount; i++) {
    if (cells[i] != 0) continue;
    final mask = candidateMask(cells, i);
    final count = bitCount(mask);
    if (count == 0) return false;
    if (count < bestCount) {
      bestCount = count;
      bestIndex = i;
      bestMask = mask;
      if (count == 1) break;
    }
  }
  if (bestIndex == -1) return true;

  final digits = digitsOfMask(bestMask)..shuffle(rng);
  for (final digit in digits) {
    cells[bestIndex] = digit;
    if (_fill(cells, rng)) return true;
    cells[bestIndex] = 0;
  }
  return false;
}

/// Result of carving a full solution into a puzzle.
class DiggingResult {
  const DiggingResult({required this.givens, required this.clueCount});

  /// The puzzle board (81 cells, 0 for blanks). Guaranteed unique solution.
  final List<int> givens;

  /// Number of remaining clues.
  final int clueCount;
}

/// Removes clues from a complete [solution] while preserving a unique solution,
/// stopping once [targetClues] is reached (or no further clue can be removed).
///
/// When [symmetric] is true, clues are removed in rotationally-symmetric pairs
/// (idx and 80-idx) for the classic Sudoku look; a removal is kept only if the
/// board still solves uniquely afterwards.
DiggingResult digHoles(
  List<int> solution,
  Random rng, {
  required int targetClues,
  bool symmetric = true,
}) {
  final puzzle = List<int>.of(solution);
  var clues = cellCount;
  final order = List<int>.generate(cellCount, (i) => i)..shuffle(rng);

  for (final idx in order) {
    if (clues <= targetClues) break;
    if (puzzle[idx] == 0) continue;

    final partner = symmetric ? cellCount - 1 - idx : idx;
    final savedA = puzzle[idx];
    final savedB = puzzle[partner];
    final removingTwo = partner != idx && savedB != 0;

    puzzle[idx] = 0;
    if (partner != idx) puzzle[partner] = 0;

    if (hasUniqueSolution(puzzle)) {
      clues -= removingTwo ? 2 : 1;
    } else {
      puzzle[idx] = savedA;
      if (partner != idx) puzzle[partner] = savedB;
    }
  }

  return DiggingResult(givens: puzzle, clueCount: clues);
}
