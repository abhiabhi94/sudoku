/// Human solving techniques, ordered from easiest to hardest. The same code
/// powers two things: **rating** a puzzle (which techniques it requires) and
/// **hints** (the next cell a person could logically place). Pure Dart.
library;

import 'board.dart';

/// A solving technique, tagged with a difficulty tier (1 = easiest).
enum Technique {
  nakedSingle(1),
  hiddenSingle(2),
  lockedCandidates(3),
  nakedPair(4),
  hiddenPair(4),
  nakedTriple(5),
  hiddenTriple(5),
  xWing(6),
  xyWing(7);

  const Technique(this.tier);

  /// Difficulty tier, 1 (naked single) .. 7 (XY-Wing).
  final int tier;
}

/// A digit that can be placed in a cell.
class Placement {
  const Placement(this.index, this.digit);
  final int index;
  final int digit;

  @override
  String toString() => 'Placement(cell $index = $digit)';
}

/// A candidate digit that can be removed from a cell.
class Elimination {
  const Elimination(this.index, this.digit);
  final int index;
  final int digit;

  @override
  bool operator ==(Object other) =>
      other is Elimination && other.index == index && other.digit == digit;

  @override
  int get hashCode => Object.hash(index, digit);

  @override
  String toString() => 'Elimination(cell $index != $digit)';
}

/// One deduction produced by a technique: either placements or eliminations.
class SolveStep {
  const SolveStep(
    this.technique, {
    this.placements = const <Placement>[],
    this.eliminations = const <Elimination>[],
  });

  final Technique technique;
  final List<Placement> placements;
  final List<Elimination> eliminations;

  bool get isEmpty => placements.isEmpty && eliminations.isEmpty;
}

/// A single hint: the technique that justifies it plus the cell/digit to fill.
class Deduction {
  const Deduction(this.technique, this.index, this.digit);
  final Technique technique;
  final int index;
  final int digit;
}

/// The outcome of trying to solve a board with logic alone.
class LogicalResult {
  const LogicalResult({
    required this.solved,
    required this.hardestTier,
    required this.techniqueCounts,
    required this.board,
  });

  /// Whether the board was fully solved using the technique ladder.
  final bool solved;

  /// Highest technique tier used (0 if the board was already complete).
  final int hardestTier;

  /// How many times each technique fired.
  final Map<Technique, int> techniqueCounts;

  /// Final board state (solved, or as far as logic reached).
  final List<int> board;
}

/// Mutable solving state: current placements plus a candidate bitmask per cell.
class SolveState {
  SolveState.raw(this.cells, this.candidates);

  /// Builds a state from a [board], computing candidates for every empty cell.
  factory SolveState.fromBoard(List<int> board) {
    final cells = List<int>.of(board);
    final candidates = List<int>.filled(cellCount, 0);
    for (var i = 0; i < cellCount; i++) {
      if (cells[i] == 0) candidates[i] = candidateMask(cells, i);
    }
    return SolveState.raw(cells, candidates);
  }

  final List<int> cells;
  final List<int> candidates;

  /// Places [digit] at [index] and prunes it from every peer's candidates.
  void place(int index, int digit) {
    cells[index] = digit;
    candidates[index] = 0;
    final clear = ~(1 << (digit - 1));
    for (final p in peers[index]) {
      candidates[p] &= clear;
    }
  }

  /// Removes [digit] from the candidates of [index].
  void eliminate(int index, int digit) {
    candidates[index] &= ~(1 << (digit - 1));
  }
}

/// The technique ladder, tried in order by [nextStep].
const List<Technique> _ladder = <Technique>[
  Technique.nakedSingle,
  Technique.hiddenSingle,
  Technique.lockedCandidates,
  Technique.nakedPair,
  Technique.hiddenPair,
  Technique.nakedTriple,
  Technique.hiddenTriple,
  Technique.xWing,
  Technique.xyWing,
];

/// Returns the easiest technique step that makes progress, or null if stuck.
SolveStep? nextStep(SolveState s) {
  for (final technique in _ladder) {
    final step = _detect(technique, s);
    if (step != null && !step.isEmpty) return step;
  }
  return null;
}

SolveStep? _detect(Technique technique, SolveState s) {
  switch (technique) {
    case Technique.nakedSingle:
      return detectNakedSingle(s);
    case Technique.hiddenSingle:
      return detectHiddenSingle(s);
    case Technique.lockedCandidates:
      return detectLockedCandidates(s);
    case Technique.nakedPair:
      return detectNakedSubset(s, 2);
    case Technique.hiddenPair:
      return detectHiddenSubset(s, 2);
    case Technique.nakedTriple:
      return detectNakedSubset(s, 3);
    case Technique.hiddenTriple:
      return detectHiddenSubset(s, 3);
    case Technique.xWing:
      return detectXWing(s);
    case Technique.xyWing:
      return detectXYWing(s);
  }
}

/// Solves [board] with logic alone, recording which techniques were needed.
LogicalResult solveLogically(List<int> board) {
  final s = SolveState.fromBoard(board);
  final counts = <Technique, int>{};
  var hardest = 0;

  while (!isFilled(s.cells)) {
    final step = nextStep(s);
    if (step == null) break;
    counts[step.technique] = (counts[step.technique] ?? 0) + 1;
    if (step.technique.tier > hardest) hardest = step.technique.tier;
    _apply(s, step);
  }

  return LogicalResult(
    solved: isSolved(s.cells),
    hardestTier: hardest,
    techniqueCounts: counts,
    board: s.cells,
  );
}

/// The next cell a player could logically place on [board], or null if the
/// board cannot be advanced by the technique ladder (caller should fall back
/// to the stored solution).
Deduction? firstHint(List<int> board) {
  final s = SolveState.fromBoard(board);
  while (true) {
    final step = nextStep(s);
    if (step == null) return null;
    for (final p in step.placements) {
      if (s.cells[p.index] == 0 &&
          (s.candidates[p.index] & (1 << (p.digit - 1))) != 0) {
        return Deduction(step.technique, p.index, p.digit);
      }
    }
    // Only elimination-only steps reach here; apply them and continue.
    _apply(s, step);
  }
}

void _apply(SolveState s, SolveStep step) {
  for (final p in step.placements) {
    if (s.cells[p.index] == 0 &&
        (s.candidates[p.index] & (1 << (p.digit - 1))) != 0) {
      s.place(p.index, p.digit);
    }
  }
  for (final e in step.eliminations) {
    s.eliminate(e.index, e.digit);
  }
}

// ---------------------------------------------------------------------------
// Technique detectors. Each returns a step only when it changes something.
// ---------------------------------------------------------------------------

/// A cell with a single remaining candidate.
SolveStep? detectNakedSingle(SolveState s) {
  final placements = <Placement>[];
  for (var i = 0; i < cellCount; i++) {
    if (s.cells[i] != 0) continue;
    final mask = s.candidates[i];
    if (isSingleBit(mask)) placements.add(Placement(i, digitOfSingleMask(mask)));
  }
  return placements.isEmpty
      ? null
      : SolveStep(Technique.nakedSingle, placements: placements);
}

/// A digit that has only one possible home within some unit.
SolveStep? detectHiddenSingle(SolveState s) {
  final placements = <Placement>[];
  final claimed = <int>{};
  for (final unit in allUnits) {
    for (var d = 1; d <= boardSize; d++) {
      final bit = 1 << (d - 1);
      var found = -1;
      var count = 0;
      for (final idx in unit) {
        if (s.cells[idx] == 0 && (s.candidates[idx] & bit) != 0) {
          found = idx;
          if (++count > 1) break;
        }
      }
      if (count == 1 && claimed.add(found)) {
        placements.add(Placement(found, d));
      }
    }
  }
  return placements.isEmpty
      ? null
      : SolveStep(Technique.hiddenSingle, placements: placements);
}

/// Pointing (box -> line) and claiming (line -> box) candidate eliminations.
SolveStep? detectLockedCandidates(SolveState s) {
  final elims = <Elimination>{};

  // Pointing: within a box, if a digit's candidates all share one row/column,
  // remove that digit elsewhere in the row/column.
  for (final box in boxUnits) {
    for (var d = 1; d <= boardSize; d++) {
      final bit = 1 << (d - 1);
      final positions =
          box.where((i) => s.cells[i] == 0 && (s.candidates[i] & bit) != 0);
      if (positions.length < 2) continue;
      final rows = positions.map(rowOf).toSet();
      final cols = positions.map(colOf).toSet();
      if (rows.length == 1) {
        for (final i in rowUnits[rows.first]) {
          if (!box.contains(i) &&
              s.cells[i] == 0 &&
              (s.candidates[i] & bit) != 0) {
            elims.add(Elimination(i, d));
          }
        }
      } else if (cols.length == 1) {
        for (final i in colUnits[cols.first]) {
          if (!box.contains(i) &&
              s.cells[i] == 0 &&
              (s.candidates[i] & bit) != 0) {
            elims.add(Elimination(i, d));
          }
        }
      }
    }
  }

  // Claiming: within a row/column, if a digit's candidates all share one box,
  // remove that digit elsewhere in the box.
  for (final line in <List<int>>[...rowUnits, ...colUnits]) {
    for (var d = 1; d <= boardSize; d++) {
      final bit = 1 << (d - 1);
      final positions =
          line.where((i) => s.cells[i] == 0 && (s.candidates[i] & bit) != 0);
      if (positions.length < 2) continue;
      final boxes = positions.map(boxOf).toSet();
      if (boxes.length == 1) {
        for (final i in boxUnits[boxes.first]) {
          if (!line.contains(i) &&
              s.cells[i] == 0 &&
              (s.candidates[i] & bit) != 0) {
            elims.add(Elimination(i, d));
          }
        }
      }
    }
  }

  return elims.isEmpty
      ? null
      : SolveStep(Technique.lockedCandidates, eliminations: elims.toList());
}

/// Naked pair/triple: [size] cells in a unit sharing exactly [size] candidates.
SolveStep? detectNakedSubset(SolveState s, int size) {
  final technique = size == 2 ? Technique.nakedPair : Technique.nakedTriple;
  for (final unit in allUnits) {
    final cells = unit
        .where((i) =>
            s.cells[i] == 0 &&
            bitCount(s.candidates[i]) >= 2 &&
            bitCount(s.candidates[i]) <= size)
        .toList();
    if (cells.length < size) continue;

    for (final combo in _combinations(cells, size)) {
      var union = 0;
      for (final i in combo) {
        union |= s.candidates[i];
      }
      if (bitCount(union) != size) continue;

      final elims = <Elimination>[];
      for (final i in unit) {
        if (s.cells[i] != 0 || combo.contains(i)) continue;
        for (final d in digitsOfMask(s.candidates[i] & union)) {
          elims.add(Elimination(i, d));
        }
      }
      if (elims.isNotEmpty) {
        return SolveStep(technique, eliminations: elims);
      }
    }
  }
  return null;
}

/// Hidden pair/triple: [size] digits confined to the same [size] cells in a
/// unit, letting all other candidates be stripped from those cells.
SolveStep? detectHiddenSubset(SolveState s, int size) {
  final technique = size == 2 ? Technique.hiddenPair : Technique.hiddenTriple;
  for (final unit in allUnits) {
    final positionsByDigit = <int, List<int>>{};
    for (var d = 1; d <= boardSize; d++) {
      final bit = 1 << (d - 1);
      final cells = unit
          .where((i) => s.cells[i] == 0 && (s.candidates[i] & bit) != 0)
          .toList();
      if (cells.length >= 2 && cells.length <= size) {
        positionsByDigit[d] = cells;
      }
    }
    final digits = positionsByDigit.keys.toList();
    if (digits.length < size) continue;

    for (final combo in _combinations(digits, size)) {
      final cellUnion = <int>{};
      var digitMask = 0;
      for (final d in combo) {
        cellUnion.addAll(positionsByDigit[d]!);
        digitMask |= 1 << (d - 1);
      }
      if (cellUnion.length != size) continue;

      final elims = <Elimination>[];
      for (final i in cellUnion) {
        for (final d in digitsOfMask(s.candidates[i] & ~digitMask)) {
          elims.add(Elimination(i, d));
        }
      }
      if (elims.isNotEmpty) {
        return SolveStep(technique, eliminations: elims);
      }
    }
  }
  return null;
}

/// X-Wing: a digit locked to the same two columns across two rows (or the same
/// two rows across two columns) lets that digit be removed from those lines
/// elsewhere.
SolveStep? detectXWing(SolveState s) {
  for (var d = 1; d <= boardSize; d++) {
    final bit = 1 << (d - 1);

    final rowStep = _xWingForLines(
      s,
      d,
      bit,
      lines: rowUnits,
      crossOf: colOf,
      crossLine: (c) => colUnits[c],
    );
    if (rowStep != null) return rowStep;

    final colStep = _xWingForLines(
      s,
      d,
      bit,
      lines: colUnits,
      crossOf: rowOf,
      crossLine: (r) => rowUnits[r],
    );
    if (colStep != null) return colStep;
  }
  return null;
}

SolveStep? _xWingForLines(
  SolveState s,
  int digit,
  int bit, {
  required List<List<int>> lines,
  required int Function(int index) crossOf,
  required List<int> Function(int cross) crossLine,
}) {
  // Cross-coordinates where the digit is a candidate, per line with exactly 2.
  final pairByLine = <int, List<int>>{};
  for (var l = 0; l < lines.length; l++) {
    final crosses = <int>[];
    for (final i in lines[l]) {
      if (s.cells[i] == 0 && (s.candidates[i] & bit) != 0) crosses.add(crossOf(i));
    }
    if (crosses.length == 2) pairByLine[l] = crosses;
  }

  final entries = pairByLine.entries.toList();
  for (var a = 0; a < entries.length; a++) {
    for (var b = a + 1; b < entries.length; b++) {
      final ca = entries[a].value;
      final cb = entries[b].value;
      if (ca[0] != cb[0] || ca[1] != cb[1]) continue;

      final la = entries[a].key;
      final lb = entries[b].key;
      final elims = <Elimination>[];
      for (final cross in ca) {
        for (final i in crossLine(cross)) {
          final line = crossOf == colOf ? rowOf(i) : colOf(i);
          if (line == la || line == lb) continue;
          if (s.cells[i] == 0 && (s.candidates[i] & bit) != 0) {
            elims.add(Elimination(i, digit));
          }
        }
      }
      if (elims.isNotEmpty) {
        return SolveStep(Technique.xWing, eliminations: elims);
      }
    }
  }
  return null;
}

/// XY-Wing: a pivot cell with candidates {x, y} and two pincer cells it sees
/// with candidates {x, z} and {y, z}. Whichever way the pivot resolves, one
/// pincer becomes z, so z can be removed from every cell that sees both
/// pincers.
SolveStep? detectXYWing(SolveState s) {
  bool bivalue(int i) => s.cells[i] == 0 && bitCount(s.candidates[i]) == 2;

  for (var pivot = 0; pivot < cellCount; pivot++) {
    if (!bivalue(pivot)) continue;
    final pivotMask = s.candidates[pivot];

    // Bivalue peers sharing exactly one candidate with the pivot.
    final wings = <int>[
      for (final p in peers[pivot])
        if (bivalue(p) && isSingleBit(s.candidates[p] & pivotMask)) p,
    ];

    for (var a = 0; a < wings.length; a++) {
      for (var b = a + 1; b < wings.length; b++) {
        final maskA = s.candidates[wings[a]];
        final maskB = s.candidates[wings[b]];
        final shared = maskA & maskB;
        // The pincers must share exactly the digit the pivot lacks, and
        // between them cover both pivot digits.
        if (!isSingleBit(shared) || (shared & pivotMask) != 0) continue;
        if ((maskA | maskB) != (pivotMask | shared)) continue;

        final z = digitOfSingleMask(shared);
        final elims = <Elimination>[];
        for (final i in peers[wings[a]]) {
          if (i == wings[b] || i == pivot || s.cells[i] != 0) continue;
          if ((s.candidates[i] & shared) == 0) continue;
          if (peers[wings[b]].contains(i)) elims.add(Elimination(i, z));
        }
        if (elims.isNotEmpty) {
          return SolveStep(Technique.xyWing, eliminations: elims);
        }
      }
    }
  }
  return null;
}

/// All size-[k] combinations of [items] (order-independent).
Iterable<List<T>> _combinations<T>(List<T> items, int k) sync* {
  if (k > items.length) return;
  final indices = List<int>.generate(k, (i) => i);
  while (true) {
    yield [for (final i in indices) items[i]];
    var pos = k - 1;
    while (pos >= 0 && indices[pos] == items.length - k + pos) {
      pos--;
    }
    if (pos < 0) return;
    indices[pos]++;
    for (var j = pos + 1; j < k; j++) {
      indices[j] = indices[j - 1] + 1;
    }
  }
}
