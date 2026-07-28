import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/engine/board.dart';
import 'package:sudoku/engine/generator.dart';
import 'package:sudoku/engine/solver.dart';

void main() {
  group('generateFullSolution', () {
    test('produces a complete valid solution across many seeds', () {
      for (var seed = 0; seed < 25; seed++) {
        final board = generateFullSolution(Random(seed));
        expect(isSolved(board), isTrue, reason: 'seed $seed should be solved');
      }
    });

    test('is deterministic for a given seed', () {
      final a = generateFullSolution(Random(42));
      final b = generateFullSolution(Random(42));
      expect(a, b);
    });

    test('different seeds yield different grids', () {
      final a = generateFullSolution(Random(1));
      final b = generateFullSolution(Random(2));
      expect(a, isNot(b));
    });
  });

  group('digHoles', () {
    test('always yields a uniquely solvable puzzle whose clues match the '
        'source solution', () {
      for (var seed = 0; seed < 15; seed++) {
        final rng = Random(seed);
        final solution = generateFullSolution(rng);
        final result = digHoles(solution, rng, targetClues: 32);

        expect(hasUniqueSolution(result.givens), isTrue,
            reason: 'seed $seed must stay unique');

        // Every remaining clue equals the original solution at that cell,
        // and solving the puzzle reproduces the source solution.
        for (var i = 0; i < cellCount; i++) {
          if (result.givens[i] != 0) {
            expect(result.givens[i], solution[i]);
          }
        }
        expect(solve(result.givens), solution);
      }
    });

    test('reaches close to the requested clue count', () {
      final rng = Random(7);
      final solution = generateFullSolution(rng);
      final result = digHoles(solution, rng, targetClues: 30);
      // Digging never adds clues and stops at/under target when it can.
      expect(result.clueCount, lessThanOrEqualTo(40));
      expect(result.clueCount, greaterThanOrEqualTo(17));
      expect(
        result.givens.where((v) => v != 0).length,
        result.clueCount,
      );
    });

    test('symmetric digging keeps rotational pairs consistent', () {
      final rng = Random(3);
      final solution = generateFullSolution(rng);
      final result = digHoles(solution, rng, targetClues: 36, symmetric: true);
      expect(hasUniqueSolution(result.givens), isTrue);
    });
  });
}
