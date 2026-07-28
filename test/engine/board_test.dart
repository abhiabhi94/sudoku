import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/engine/board.dart';

void main() {
  group('geometry', () {
    test('rowOf / colOf / indexOf are consistent', () {
      for (var i = 0; i < cellCount; i++) {
        expect(indexOf(rowOf(i), colOf(i)), i);
      }
    });

    test('boxOf maps the four corners and centre correctly', () {
      expect(boxOf(indexOf(0, 0)), 0);
      expect(boxOf(indexOf(0, 8)), 2);
      expect(boxOf(indexOf(4, 4)), 4);
      expect(boxOf(indexOf(8, 0)), 6);
      expect(boxOf(indexOf(8, 8)), 8);
    });
  });

  group('units', () {
    test('there are 27 units of 9 cells each', () {
      expect(allUnits.length, 27);
      for (final unit in allUnits) {
        expect(unit.length, boardSize);
        expect(unit.toSet().length, boardSize, reason: 'no duplicate cells');
      }
    });

    test('box 0 holds the top-left 3x3 block', () {
      expect(boxUnits[0], <int>[0, 1, 2, 9, 10, 11, 18, 19, 20]);
    });

    test('each cell reports its three owning units', () {
      const idx = 40; // centre cell (row 4, col 4)
      expect(unitsForCell[idx][0], rowUnits[4]);
      expect(unitsForCell[idx][1], colUnits[4]);
      expect(unitsForCell[idx][2], boxUnits[4]);
    });
  });

  group('peers', () {
    test('every cell has exactly 20 peers, excluding itself', () {
      expect(peers.length, cellCount);
      for (var i = 0; i < cellCount; i++) {
        expect(peers[i].length, 20);
        expect(peers[i], isNot(contains(i)));
      }
    });

    test('peers of the top-left cell are its row, column and box', () {
      expect(peers[0].toSet(), <int>{
        1, 2, 3, 4, 5, 6, 7, 8, // row
        9, 18, 27, 36, 45, 54, 63, 72, // column
        10, 11, 19, 20, // rest of box
      });
    });
  });

  group('bit helpers', () {
    test('maskForDigit sets the right bit', () {
      expect(maskForDigit(1), 1);
      expect(maskForDigit(9), 256);
    });

    test('bitCount counts set bits', () {
      expect(bitCount(0), 0);
      expect(bitCount(allCandidatesMask), 9);
      expect(bitCount(maskForDigit(3) | maskForDigit(7)), 2);
    });

    test('isSingleBit and digitOfSingleMask', () {
      expect(isSingleBit(0), isFalse);
      expect(isSingleBit(maskForDigit(5)), isTrue);
      expect(isSingleBit(maskForDigit(5) | maskForDigit(6)), isFalse);
      expect(digitOfSingleMask(maskForDigit(5)), 5);
    });

    test('digitsOfMask lists digits ascending', () {
      final mask = maskForDigit(2) | maskForDigit(5) | maskForDigit(9);
      expect(digitsOfMask(mask), <int>[2, 5, 9]);
      expect(digitsOfMask(0), isEmpty);
      expect(digitsOfMask(allCandidatesMask), <int>[1, 2, 3, 4, 5, 6, 7, 8, 9]);
    });
  });

  group('candidates and validity', () {
    test('candidateMask excludes digits used by peers', () {
      final cells = List<int>.filled(cellCount, 0);
      cells[1] = 3; // same row as cell 0
      cells[9] = 5; // same column as cell 0
      cells[20] = 7; // same box as cell 0
      final mask = candidateMask(cells, 0);
      expect(digitsOfMask(mask), <int>[1, 2, 4, 6, 8, 9]);
    });

    test('isValidPlacement rejects a peer conflict', () {
      final cells = List<int>.filled(cellCount, 0);
      cells[1] = 4;
      expect(isValidPlacement(cells, 0, 4), isFalse);
      expect(isValidPlacement(cells, 0, 5), isTrue);
    });

    test('isConsistent detects a duplicate in a unit', () {
      final cells = List<int>.filled(cellCount, 0);
      cells[0] = 8;
      cells[8] = 8; // duplicate 8 in row 0
      expect(isConsistent(cells), isFalse);
    });

    test('isSolved on a complete valid grid', () {
      final solved = parseBoard(
        '534678912672195348198342567859761423426853791'
        '713924856961537284287419635345286179',
      );
      expect(isFilled(solved), isTrue);
      expect(isConsistent(solved), isTrue);
      expect(isSolved(solved), isTrue);
    });
  });

  group('parsing', () {
    test('parseBoard accepts 0 and . as blanks and round-trips', () {
      const puzzle =
          '53..7....6..195....98....6.8...6...34..8.3..17...2...6.6....28....419..5....8..79';
      final board = parseBoard(puzzle);
      expect(board.length, cellCount);
      expect(board[0], 5);
      expect(board[2], 0);
      expect(boardToString(board), puzzle.replaceAll('.', '0'));
    });

    test('parseBoard rejects wrong-length input', () {
      expect(() => parseBoard('123'), throwsArgumentError);
    });
  });
}
