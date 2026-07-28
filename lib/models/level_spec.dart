/// Difficulty band for one level: the clue window and technique-tier window a
/// generated puzzle must fall into. Pure Dart (no Flutter), safe for isolates.
///
/// Technique tiers (see [Technique] in engine/techniques.dart):
///   1 naked single · 2 hidden single · 3 locked candidates ·
///   4 pairs · 5 triples · 6 X-Wing
library;

/// The three difficulty tiers.
enum Difficulty { beginner, advanced, expert }

extension DifficultyLabel on Difficulty {
  /// 1-based tier number (Beginner = 1).
  int get tierNumber => index + 1;
}

class LevelSpec {
  const LevelSpec({
    required this.tier,
    required this.level,
    required this.targetClues,
    required this.minClues,
    required this.maxClues,
    required this.minTier,
    required this.maxTier,
    this.symmetric = true,
  });

  /// 1 = Beginner, 2 = Advanced, 3 = Expert.
  final int tier;

  /// 1..10 within the tier.
  final int level;

  /// Clue count the digger aims for.
  final int targetClues;

  /// Accepted clue-count window (inclusive).
  final int minClues;
  final int maxClues;

  /// Accepted hardest-technique-tier window (inclusive).
  final int minTier;
  final int maxTier;

  /// Whether to dig clues in rotationally-symmetric pairs.
  final bool symmetric;

  /// Global level number, 1..30.
  int get globalLevel => (tier - 1) * 10 + level;

  /// The difficulty enum for this tier.
  Difficulty get difficulty => Difficulty.values[tier - 1];
}
