/// The 40 level difficulty bands (4 tiers x 10 levels).
///
/// Difficulty jumps clearly BETWEEN tiers (the technique-tier window steps up:
/// Beginner 1-2, Advanced 3-4, Expert 4-6, Master 7) and rises gently WITHIN a
/// tier (clue count drifts down level by level). This is the single place to
/// tune difficulty. Pure Dart, no Flutter.
library;

import '../models/level_spec.dart';

/// How far below/above the target clue count a generated puzzle may land.
const int _clueSlackLow = 2;
const int _clueSlackHigh = 3;

LevelSpec _spec(
  int tier,
  int level,
  int targetClues,
  int minTier,
  int maxTier, {
  bool symmetric = true,
}) {
  return LevelSpec(
    tier: tier,
    level: level,
    targetClues: targetClues,
    minClues: targetClues - _clueSlackLow,
    maxClues: targetClues + _clueSlackHigh,
    minTier: minTier,
    maxTier: maxTier,
    symmetric: symmetric,
  );
}

/// All 40 level specifications, indexed implicitly by (tier, level).
final List<LevelSpec> levelSpecs = List<LevelSpec>.unmodifiable(<LevelSpec>[
  // ---- Beginner (tier 1): naked & hidden singles only -------------------
  _spec(1, 1, 40, 1, 2),
  _spec(1, 2, 39, 1, 2),
  _spec(1, 3, 38, 1, 2),
  _spec(1, 4, 37, 2, 2),
  _spec(1, 5, 36, 2, 2),
  _spec(1, 6, 36, 2, 2),
  _spec(1, 7, 35, 2, 2),
  _spec(1, 8, 35, 2, 2),
  _spec(1, 9, 34, 2, 2),
  _spec(1, 10, 34, 2, 2),

  // ---- Advanced (tier 2): locked candidates & pairs ---------------------
  _spec(2, 1, 34, 3, 3),
  _spec(2, 2, 33, 3, 3),
  _spec(2, 3, 32, 3, 3),
  _spec(2, 4, 31, 3, 4),
  _spec(2, 5, 30, 4, 4),
  _spec(2, 6, 30, 4, 4),
  _spec(2, 7, 29, 4, 4),
  _spec(2, 8, 29, 4, 4),
  _spec(2, 9, 28, 4, 4),
  _spec(2, 10, 28, 4, 4),

  // ---- Expert (tier 3): triples & X-Wing, lowest clue counts ------------
  _spec(3, 1, 30, 4, 5),
  _spec(3, 2, 29, 5, 5),
  _spec(3, 3, 28, 5, 5),
  _spec(3, 4, 27, 5, 5),
  _spec(3, 5, 26, 5, 6),
  _spec(3, 6, 26, 5, 6, symmetric: false),
  _spec(3, 7, 25, 5, 6, symmetric: false),
  _spec(3, 8, 25, 5, 6, symmetric: false),
  _spec(3, 9, 24, 5, 6, symmetric: false),
  _spec(3, 10, 23, 5, 6, symmetric: false),

  // ---- Master (tier 4): every board needs an XY-Wing ---------------------
  _spec(4, 1, 27, 7, 7, symmetric: false),
  _spec(4, 2, 27, 7, 7, symmetric: false),
  _spec(4, 3, 26, 7, 7, symmetric: false),
  _spec(4, 4, 26, 7, 7, symmetric: false),
  _spec(4, 5, 25, 7, 7, symmetric: false),
  _spec(4, 6, 25, 7, 7, symmetric: false),
  _spec(4, 7, 24, 7, 7, symmetric: false),
  _spec(4, 8, 24, 7, 7, symmetric: false),
  _spec(4, 9, 23, 7, 7, symmetric: false),
  _spec(4, 10, 22, 7, 7, symmetric: false),
]);

/// The spec for a given [tier] (1..4) and [level] (1..10).
LevelSpec specFor(int tier, int level) =>
    levelSpecs.firstWhere((s) => s.tier == tier && s.level == level);
