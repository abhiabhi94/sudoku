/// Per-level progress: completion, best time and play count. Pure Dart.
library;

class LevelProgress {
  const LevelProgress({
    required this.globalLevel,
    required this.completed,
    required this.bestTimeMs,
    required this.timesCompleted,
  });

  /// Global level number, 1..40.
  final int globalLevel;

  /// Whether the level has ever been solved.
  final bool completed;

  /// Best completion time in milliseconds, or null if never solved.
  final int? bestTimeMs;

  /// How many times the level has been solved.
  final int timesCompleted;

  /// Empty progress for a level that has not been played.
  factory LevelProgress.empty(int globalLevel) => LevelProgress(
        globalLevel: globalLevel,
        completed: false,
        bestTimeMs: null,
        timesCompleted: 0,
      );

  /// Returns progress after solving in [timeMs], keeping the best time.
  LevelProgress withCompletion(int timeMs) {
    final best = bestTimeMs == null || timeMs < bestTimeMs! ? timeMs : bestTimeMs;
    return LevelProgress(
      globalLevel: globalLevel,
      completed: true,
      bestTimeMs: best,
      timesCompleted: timesCompleted + 1,
    );
  }

  /// Whether [timeMs] would be a new best time for this level.
  bool isNewBest(int timeMs) => bestTimeMs == null || timeMs < bestTimeMs!;

  LevelProgress copyWith({
    bool? completed,
    int? bestTimeMs,
    int? timesCompleted,
  }) {
    return LevelProgress(
      globalLevel: globalLevel,
      completed: completed ?? this.completed,
      bestTimeMs: bestTimeMs ?? this.bestTimeMs,
      timesCompleted: timesCompleted ?? this.timesCompleted,
    );
  }
}
