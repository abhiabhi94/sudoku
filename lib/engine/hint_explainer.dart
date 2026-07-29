/// Explains *why* a hinted digit belongs in a cell, given the current board —
/// so the UI can show the player the logic (and highlight the justifying cells)
/// instead of a number appearing from nowhere. Pure Dart (no Flutter).
library;

import 'board.dart';

/// Which unit makes a hidden single the only choice.
enum HintUnit { row, column, box, none }

/// The shape of the justification for a hint placement.
enum HintKind {
  /// This cell's row, column and box already use every other digit.
  nakedSingle,

  /// The digit fits in only this empty cell of a row, column or box.
  hiddenSingle,

  /// Needed earlier eliminations; a generic board-aware note.
  advanced,
}

class HintExplanation {
  const HintExplanation({
    required this.kind,
    required this.digit,
    required this.unit,
    required this.justifiers,
  });

  final HintKind kind;
  final int digit;

  /// The unit that pins a [HintKind.hiddenSingle] (else [HintUnit.none]).
  final HintUnit unit;

  /// Cells to highlight as the reason: the filled peers (naked single / advanced)
  /// or the rest of the unit (hidden single).
  final List<int> justifiers;
}

/// Builds an explanation for placing [digit] at [index] on [board] (the board
/// *before* the digit is placed).
HintExplanation explainHint(List<int> board, int index, int digit) {
  // Naked single: this cell has exactly one candidate.
  if (isSingleBit(candidateMask(board, index))) {
    return HintExplanation(
      kind: HintKind.nakedSingle,
      digit: digit,
      unit: HintUnit.none,
      justifiers: _filledPeers(board, index),
    );
  }

  // Hidden single: the digit fits in no other empty cell of some unit.
  final units = <(HintUnit, List<int>)>[
    (HintUnit.row, rowUnits[rowOf(index)]),
    (HintUnit.column, colUnits[colOf(index)]),
    (HintUnit.box, boxUnits[boxOf(index)]),
  ];
  for (final (kind, unit) in units) {
    if (_onlySpotInUnit(board, unit, index, digit)) {
      return HintExplanation(
        kind: HintKind.hiddenSingle,
        digit: digit,
        unit: kind,
        justifiers: <int>[for (final c in unit) if (c != index) c],
      );
    }
  }

  // Rare: the placement needed earlier eliminations (locked candidates, etc.).
  return HintExplanation(
    kind: HintKind.advanced,
    digit: digit,
    unit: HintUnit.none,
    justifiers: _filledPeers(board, index),
  );
}

List<int> _filledPeers(List<int> board, int index) =>
    <int>[for (final p in peers[index]) if (board[p] != 0) p];

/// Whether [index] is the only empty cell of [unit] that can hold [digit].
bool _onlySpotInUnit(List<int> board, List<int> unit, int index, int digit) {
  final bit = maskForDigit(digit);
  if ((candidateMask(board, index) & bit) == 0) return false;
  for (final c in unit) {
    if (c == index || board[c] != 0) continue;
    if ((candidateMask(board, c) & bit) != 0) return false;
  }
  return true;
}
