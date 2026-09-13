/// Rates a puzzle by the human techniques it requires plus its clue count.
/// Pure Dart, no Flutter.
library;

import 'dart:math' as math;

import 'techniques.dart';

class DifficultyRating {
  const DifficultyRating({
    required this.solvable,
    required this.hardestTier,
    required this.clueCount,
    required this.techniqueCounts,
    required this.score,
  });

  /// Whether the puzzle is solvable by the technique ladder without guessing.
  final bool solvable;

  /// Highest technique tier required (1..7), or 0 if already solved.
  final int hardestTier;

  /// Number of given clues.
  final int clueCount;

  /// How many times each technique fired while solving.
  final Map<Technique, int> techniqueCounts;

  /// Composite difficulty score — the hardest-technique term dominates so
  /// tiers separate cleanly, with clue count and advanced-step count giving a
  /// gentle gradient inside a tier.
  final int score;

  bool usedTechnique(Technique t) => techniqueCounts.containsKey(t);
}

/// Rates [givens] (an 81-cell board, 0 for blanks).
DifficultyRating rate(List<int> givens) {
  final result = solveLogically(givens);
  final clueCount = givens.where((v) => v != 0).length;

  var advancedSteps = 0;
  result.techniqueCounts.forEach((technique, count) {
    if (technique.tier >= Technique.lockedCandidates.tier) advancedSteps += count;
  });

  final score = 100 * result.hardestTier +
      (5 * (math.log(1 + advancedSteps) / math.ln2)).round() +
      (36 - clueCount);

  return DifficultyRating(
    solvable: result.solved,
    hardestTier: result.hardestTier,
    clueCount: clueCount,
    techniqueCounts: result.techniqueCounts,
    score: score,
  );
}
