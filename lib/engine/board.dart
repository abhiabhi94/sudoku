/// Pure-Dart Sudoku board primitives — geometry, candidate bitmasks and
/// validity checks shared by the generator, solver and technique layers.
///
/// This library has **zero Flutter imports** so it can run inside a background
/// isolate (`compute`) and be exhaustively unit-tested as plain Dart.
///
/// A board is a flat `List<int>` of length 81. Cell `index = row * 9 + col`.
/// A value of `0` means empty; `1..9` is a placed digit.
library;

/// Side length of the grid.
const int boardSize = 9;

/// Side length of a box (3x3).
const int boxSize = 3;

/// Total number of cells (9 * 9).
const int cellCount = 81;

/// Bitmask with all nine candidate bits set (digits 1..9 -> bits 0..8).
const int allCandidatesMask = 0x1FF; // 511

/// Row of a flat cell [index].
int rowOf(int index) => index ~/ boardSize;

/// Column of a flat cell [index].
int colOf(int index) => index % boardSize;

/// Box number (0..8) of a flat cell [index].
int boxOf(int index) =>
    (rowOf(index) ~/ boxSize) * boxSize + colOf(index) ~/ boxSize;

/// Flat index for [row], [col].
int indexOf(int row, int col) => row * boardSize + col;

/// The single candidate bit for [digit] (1..9).
int maskForDigit(int digit) => 1 << (digit - 1);

/// The nine row units, each a list of nine cell indices.
final List<List<int>> rowUnits = List<List<int>>.generate(
  boardSize,
  (r) => List<int>.generate(boardSize, (c) => indexOf(r, c)),
  growable: false,
);

/// The nine column units.
final List<List<int>> colUnits = List<List<int>>.generate(
  boardSize,
  (c) => List<int>.generate(boardSize, (r) => indexOf(r, c)),
  growable: false,
);

/// The nine box units.
final List<List<int>> boxUnits = List<List<int>>.generate(boardSize, (b) {
  final startRow = (b ~/ boxSize) * boxSize;
  final startCol = (b % boxSize) * boxSize;
  return <int>[
    for (var dr = 0; dr < boxSize; dr++)
      for (var dc = 0; dc < boxSize; dc++) indexOf(startRow + dr, startCol + dc),
  ];
}, growable: false);

/// All 27 units (9 rows, 9 columns, 9 boxes).
final List<List<int>> allUnits = List<List<int>>.unmodifiable(
  <List<int>>[...rowUnits, ...colUnits, ...boxUnits],
);

/// For each cell, the three units (row, column, box) it belongs to.
final List<List<List<int>>> unitsForCell = List<List<List<int>>>.generate(
  cellCount,
  (i) => <List<int>>[rowUnits[rowOf(i)], colUnits[colOf(i)], boxUnits[boxOf(i)]],
  growable: false,
);

/// For each cell, its 20 peers (cells sharing a row, column or box), excluding
/// the cell itself.
final List<List<int>> peers = _buildPeers();

List<List<int>> _buildPeers() {
  return List<List<int>>.generate(cellCount, (i) {
    final set = <int>{}
      ..addAll(rowUnits[rowOf(i)])
      ..addAll(colUnits[colOf(i)])
      ..addAll(boxUnits[boxOf(i)])
      ..remove(i);
    return List<int>.unmodifiable(set);
  }, growable: false);
}

/// Number of set bits in [mask] (only the low bits matter here).
int bitCount(int mask) {
  var count = 0;
  var m = mask;
  while (m != 0) {
    m &= m - 1;
    count++;
  }
  return count;
}

/// Whether [mask] has exactly one bit set.
bool isSingleBit(int mask) => mask != 0 && (mask & (mask - 1)) == 0;

/// The digit (1..9) for a single-bit [mask]. Undefined for multi-bit masks.
int digitOfSingleMask(int mask) => mask.bitLength;

/// The list of digits (1..9) present in [mask].
List<int> digitsOfMask(int mask) {
  final digits = <int>[];
  var m = mask;
  while (m != 0) {
    final bit = m & (-m);
    digits.add(bit.bitLength);
    m ^= bit;
  }
  return digits;
}

/// Candidate bitmask for empty cell [index] given the current [cells]: every
/// digit not already used by one of the cell's peers.
int candidateMask(List<int> cells, int index) {
  var used = 0;
  for (final p in peers[index]) {
    final v = cells[p];
    if (v != 0) used |= 1 << (v - 1);
  }
  return allCandidatesMask & ~used;
}

/// Whether placing [digit] at [index] breaks no row/column/box constraint.
/// Ignores whatever currently sits at [index].
bool isValidPlacement(List<int> cells, int index, int digit) {
  for (final p in peers[index]) {
    if (cells[p] == digit) return false;
  }
  return true;
}

/// Whether [cells] has no empty cells.
bool isFilled(List<int> cells) {
  for (var i = 0; i < cellCount; i++) {
    if (cells[i] == 0) return false;
  }
  return true;
}

/// Whether every filled cell respects Sudoku constraints (empties allowed).
bool isConsistent(List<int> cells) {
  for (final unit in allUnits) {
    var seen = 0;
    for (final idx in unit) {
      final v = cells[idx];
      if (v == 0) continue;
      final bit = 1 << (v - 1);
      if (seen & bit != 0) return false;
      seen |= bit;
    }
  }
  return true;
}

/// Whether [cells] is a complete, valid solution (filled + every unit is 1..9).
bool isSolved(List<int> cells) => isFilled(cells) && isConsistent(cells);

/// Parses an 81-character string ('0' or '.' for blanks) into a board list.
List<int> parseBoard(String s) {
  final cleaned = s.replaceAll(RegExp(r'\s'), '');
  if (cleaned.length != cellCount) {
    throw ArgumentError('Board string must have $cellCount cells, '
        'got ${cleaned.length}.');
  }
  return List<int>.generate(cellCount, (i) {
    final ch = cleaned[i];
    if (ch == '.' || ch == '0') return 0;
    final digit = int.parse(ch);
    return digit;
  }, growable: false);
}

/// Renders a board list as an 81-character string ('0' for blanks).
String boardToString(List<int> cells) => cells.join();
