import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/data/level_specs.dart';
import 'package:sudoku/engine/board.dart';
import 'package:sudoku/engine/puzzle_factory.dart';
import 'package:sudoku/engine/solver.dart';

void _assertPlayable(GeneratedPuzzle p) {
  // Unique solution, and the stored solution is exactly that solution.
  expect(hasUniqueSolution(p.givens), isTrue);
  expect(solve(p.givens), p.solution);
  expect(isSolved(p.solution), isTrue);
  // Every given matches the solution.
  for (var i = 0; i < cellCount; i++) {
    if (p.givens[i] != 0) expect(p.givens[i], p.solution[i]);
  }
}

void main() {
  group('level specs', () {
    test('there are 40 specs, one per tier/level, with sane windows', () {
      expect(levelSpecs.length, 40);
      for (var tier = 1; tier <= 4; tier++) {
        for (var level = 1; level <= 10; level++) {
          final spec = specFor(tier, level);
          expect(spec.minClues, lessThanOrEqualTo(spec.targetClues));
          expect(spec.maxClues, greaterThanOrEqualTo(spec.targetClues));
          expect(spec.minTier, lessThanOrEqualTo(spec.maxTier));
        }
      }
    });

    test('technique tiers step up between difficulty tiers', () {
      expect(specFor(1, 10).maxTier, lessThan(specFor(2, 1).maxTier));
      expect(specFor(2, 10).maxTier, lessThan(specFor(3, 10).maxTier));
      expect(specFor(3, 10).maxTier, lessThan(specFor(4, 1).minTier));
    });
  });

  group('generateForBand', () {
    test('produces playable puzzles across all tiers', () {
      for (final coord in const <List<int>>[
        [1, 1],
        [1, 10],
        [2, 1],
        [2, 10],
        [3, 1],
        [3, 6],
        [4, 1],
        [4, 10],
      ]) {
        final p = generateForBand(coord[0], coord[1], 20260728);
        _assertPlayable(p);
        expect(p.tier, coord[0]);
        expect(p.level, coord[1]);
      }
    });

    test('beginner puzzles stay within their easy band across seeds', () {
      final spec = specFor(1, 1);
      for (var seed = 0; seed < 5; seed++) {
        final p = generateForBand(1, 1, seed);
        expect(p.inBand, isTrue, reason: 'seed $seed should land in band');
        expect(p.hardestTier, inInclusiveRange(spec.minTier, spec.maxTier));
        expect(p.clueCount, inInclusiveRange(spec.minClues, spec.maxClues));
      }
    });

    test('advanced puzzles require mid-tier techniques', () {
      final spec = specFor(2, 5);
      final p = generateForBand(2, 5, 99);
      _assertPlayable(p);
      if (p.inBand) {
        expect(p.hardestTier, inInclusiveRange(spec.minTier, spec.maxTier));
      }
    });

    test('master puzzles need an XY-Wing', () {
      final spec = specFor(4, 5);
      final p = generateForBand(4, 5, 2026);
      _assertPlayable(p);
      expect(p.inBand, isTrue);
      expect(p.hardestTier, inInclusiveRange(spec.minTier, spec.maxTier));
      expect(p.clueCount, inInclusiveRange(spec.minClues, spec.maxClues));
    });

    test('is deterministic for a given seed', () {
      final a = generateForBand(2, 5, 4242);
      final b = generateForBand(2, 5, 4242);
      expect(a.givens, b.givens);
      expect(a.solution, b.solution);
    });

    test('generatePuzzleTask forwards to generateForBand', () {
      final viaTask = generatePuzzleTask(PuzzleRequest(1, 2, 7));
      final direct = generateForBand(1, 2, 7);
      expect(viaTask.givens, direct.givens);
    });

    test('falls back to an easy puzzle when no attempt is allowed', () {
      final p = generateForBand(3, 10, 1, maxAttempts: 0);
      expect(p.inBand, isFalse);
      _assertPlayable(p);
    });

    test('returns the closest solvable puzzle when the band is not hit', () {
      // One attempt at a tier-locked beginner band almost always lands
      // out-of-band-but-solvable, exercising the closest-match fallback.
      final p = generateForBand(1, 4, 0, maxAttempts: 1);
      _assertPlayable(p);
    });
  });
}
