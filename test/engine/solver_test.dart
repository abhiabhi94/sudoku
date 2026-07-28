import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/engine/board.dart';
import 'package:sudoku/engine/solver.dart';

void main() {
  // The canonical Wikipedia example puzzle and its unique solution.
  final puzzle = parseBoard(
    '53..7....6..195....98....6.8...6...34..8.3..17...2...6.6....28....419..5....8..79',
  );
  final solution = parseBoard(
    '534678912672195348198342567859761423426853791'
    '713924856961537284287419635345286179',
  );

  group('countSolutions', () {
    test('a proper puzzle has exactly one solution', () {
      expect(countSolutions(puzzle), 1);
      expect(hasUniqueSolution(puzzle), isTrue);
    });

    test('a completed grid counts as one solution', () {
      expect(countSolutions(solution), 1);
    });

    test('an empty grid is ambiguous (early-exit at cap)', () {
      final empty = List<int>.filled(cellCount, 0);
      expect(countSolutions(empty, cap: 2), 2);
    });

    test('a board with an unavoidable rectangle has exactly two solutions', () {
      // Blank a 6/7 "deadly pattern" rectangle out of the full solution: the
      // two ways to fill it give two complete solutions and nothing else.
      final ambiguous = List<int>.of(solution);
      for (final idx in <int>[indexOf(0, 3), indexOf(0, 4), indexOf(3, 3), indexOf(3, 4)]) {
        ambiguous[idx] = 0;
      }
      expect(countSolutions(ambiguous, cap: 10), 2);
      expect(hasUniqueSolution(ambiguous), isFalse);
    });

    test('a contradictory board has no solution', () {
      final broken = List<int>.of(puzzle);
      // Force two 5s into the same column.
      broken[indexOf(1, 0)] = 5; // column 0 already has a 5 at row 0
      expect(countSolutions(broken), 0);
      expect(solve(broken), isNull);
    });
  });

  group('solve', () {
    test('solves the puzzle to the known solution', () {
      final result = solve(puzzle);
      expect(result, isNotNull);
      expect(result, solution);
      expect(isSolved(result!), isTrue);
    });

    test('does not mutate the input board', () {
      final input = List<int>.of(puzzle);
      solve(input);
      expect(input, puzzle);
    });
  });
}
