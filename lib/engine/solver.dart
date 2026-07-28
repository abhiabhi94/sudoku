/// Backtracking solver and solution counter for Sudoku boards.
///
/// Uses MRV (minimum remaining values) cell selection so both solving and
/// uniqueness checking stay fast even on hard boards. Pure Dart, no Flutter.
library;

import 'board.dart';

/// Counts the solutions of [cells], stopping early once [cap] is reached.
///
/// For uniqueness testing pass the default `cap: 2` — the search never
/// enumerates beyond the second solution, so it returns `1` for a proper
/// puzzle and `2` the moment ambiguity is found.
int countSolutions(List<int> cells, {int cap = 2}) {
  if (!isConsistent(cells)) return 0;
  final work = List<int>.of(cells);
  return _count(work, cap);
}

/// Whether [cells] has exactly one solution.
bool hasUniqueSolution(List<int> cells) => countSolutions(cells, cap: 2) == 1;

/// Solves [cells] and returns a filled board, or `null` if unsolvable.
/// Does not mutate the input.
List<int>? solve(List<int> cells) {
  if (!isConsistent(cells)) return null;
  final work = List<int>.of(cells);
  return _solve(work) ? work : null;
}

int _count(List<int> cells, int cap) {
  final pick = _mostConstrainedCell(cells);
  if (pick.index == -1) {
    // No empty cell with the search still alive means either solved
    // (index -1, mask 0 after a full scan) — distinguish via a fill check.
    return pick.dead ? 0 : 1;
  }
  var total = 0;
  var mask = pick.mask;
  while (mask != 0) {
    final bit = mask & (-mask);
    mask ^= bit;
    cells[pick.index] = bit.bitLength;
    total += _count(cells, cap);
    cells[pick.index] = 0;
    if (total >= cap) return total;
  }
  return total;
}

bool _solve(List<int> cells) {
  final pick = _mostConstrainedCell(cells);
  if (pick.index == -1) return !pick.dead;
  var mask = pick.mask;
  while (mask != 0) {
    final bit = mask & (-mask);
    mask ^= bit;
    cells[pick.index] = bit.bitLength;
    if (_solve(cells)) return true;
    cells[pick.index] = 0;
  }
  return false;
}

/// Result of scanning for the next cell to branch on.
class _Pick {
  const _Pick(this.index, this.mask, this.dead);

  /// Cell to branch on, or -1 when none remain (solved) or a dead end was hit.
  final int index;

  /// Candidate mask of [index].
  final int mask;

  /// True when an empty cell has no candidates (unsolvable branch).
  final bool dead;
}

/// Finds the empty cell with the fewest candidates (MRV). Returns a dead pick
/// if any empty cell has zero candidates, or an index of -1 when the board is
/// already full.
_Pick _mostConstrainedCell(List<int> cells) {
  var bestIndex = -1;
  var bestMask = 0;
  var bestCount = boardSize + 1;
  for (var i = 0; i < cellCount; i++) {
    if (cells[i] != 0) continue;
    final mask = candidateMask(cells, i);
    final count = bitCount(mask);
    if (count == 0) return const _Pick(-1, 0, true);
    if (count < bestCount) {
      bestCount = count;
      bestIndex = i;
      bestMask = mask;
      if (count == 1) break;
    }
  }
  return _Pick(bestIndex, bestMask, false);
}
