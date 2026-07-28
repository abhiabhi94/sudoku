/// Generates a puzzle for a given difficulty band via accept/reject sampling.
///
/// [generatePuzzleTask] is the top-level entry point meant to be run on a
/// background isolate (`compute`) so generation never blocks the UI thread.
/// Pure Dart, no Flutter.
library;

import 'dart:math';

import '../data/level_specs.dart';
import 'generator.dart';
import 'rater.dart';

/// A generated puzzle plus the rating metadata that placed it in its band.
class GeneratedPuzzle {
  const GeneratedPuzzle({
    required this.givens,
    required this.solution,
    required this.tier,
    required this.level,
    required this.clueCount,
    required this.hardestTier,
    required this.score,
    required this.inBand,
  });

  /// The puzzle (81 cells, 0 for blanks). Unique solution guaranteed.
  final List<int> givens;

  /// The unique solution (81 cells).
  final List<int> solution;

  final int tier;
  final int level;
  final int clueCount;
  final int hardestTier;
  final int score;

  /// False if no in-band puzzle was found and the closest match was returned.
  final bool inBand;
}

/// Serializable request for [generatePuzzleTask] (isolate-friendly).
class PuzzleRequest {
  const PuzzleRequest(this.tier, this.level, this.seed);
  final int tier;
  final int level;
  final int seed;
}

/// Isolate entry point: build a puzzle for the requested band.
GeneratedPuzzle generatePuzzleTask(PuzzleRequest request) =>
    generateForBand(request.tier, request.level, request.seed);

const int _defaultMaxAttempts = 500;

/// Generates a puzzle for [tier]/[level] seeded by [seed]. Samples until a
/// puzzle lands in the level's band; if none is found within [maxAttempts],
/// returns the closest solvable puzzle seen (with `inBand == false`).
GeneratedPuzzle generateForBand(
  int tier,
  int level,
  int seed, {
  int maxAttempts = _defaultMaxAttempts,
}) {
  final spec = specFor(tier, level);
  final rng = Random(seed);

  GeneratedPuzzle? best;
  var bestDistance = 1 << 30;

  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    final solution = generateFullSolution(rng);
    final dig = digHoles(
      solution,
      rng,
      targetClues: spec.targetClues,
      symmetric: spec.symmetric,
    );
    final rating = rate(dig.givens);
    if (!rating.solvable) continue;

    final tierDistance = _distance(rating.hardestTier, spec.minTier, spec.maxTier);
    final clueDistance = _distance(rating.clueCount, spec.minClues, spec.maxClues);

    if (tierDistance == 0 && clueDistance == 0) {
      return GeneratedPuzzle(
        givens: dig.givens,
        solution: solution,
        tier: tier,
        level: level,
        clueCount: rating.clueCount,
        hardestTier: rating.hardestTier,
        score: rating.score,
        inBand: true,
      );
    }

    final distance = tierDistance * 100 + clueDistance;
    if (best == null || distance < bestDistance) {
      bestDistance = distance;
      best = GeneratedPuzzle(
        givens: dig.givens,
        solution: solution,
        tier: tier,
        level: level,
        clueCount: rating.clueCount,
        hardestTier: rating.hardestTier,
        score: rating.score,
        inBand: false,
      );
    }
  }

  return best ?? _easyFallback(tier, level, rng);
}

/// How far [value] sits outside the inclusive window [min]..[max] (0 if in it).
int _distance(int value, int min, int max) {
  if (value < min) return min - value;
  if (value > max) return value - max;
  return 0;
}

/// Last-resort puzzle: dig to a high clue count so it is almost certainly
/// solvable by singles alone. Used only if no solvable puzzle was sampled.
GeneratedPuzzle _easyFallback(int tier, int level, Random rng) {
  final solution = generateFullSolution(rng);
  final dig = digHoles(solution, rng, targetClues: 40);
  final rating = rate(dig.givens);
  return GeneratedPuzzle(
    givens: dig.givens,
    solution: solution,
    tier: tier,
    level: level,
    clueCount: rating.clueCount,
    hardestTier: rating.hardestTier,
    score: rating.score,
    inBand: false,
  );
}
