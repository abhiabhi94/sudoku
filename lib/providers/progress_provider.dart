/// Level progress state: completion, best times, unlock progression. Persisted
/// via shared_preferences with app-prefixed keys.
library;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/level_progress.dart';
import 'app_providers.dart';

/// Total number of levels (3 tiers x 10).
const int totalLevels = 30;

/// Levels per tier.
const int levelsPerTier = 10;

/// Clearing this many levels in a tier unlocks the first level of the next tier.
const int tierUnlockThreshold = 5;

class SudokuProgressRepository {
  SudokuProgressRepository(this._prefs);

  final SharedPreferences _prefs;

  String _doneKey(int level) => 'sudoku_level_${level}_done';
  String _bestKey(int level) => 'sudoku_level_${level}_best';
  String _countKey(int level) => 'sudoku_level_${level}_count';

  LevelProgress load(int level) {
    final completed = _prefs.getBool(_doneKey(level)) ?? false;
    final best = _prefs.getInt(_bestKey(level));
    final count = _prefs.getInt(_countKey(level)) ?? 0;
    return LevelProgress(
      globalLevel: level,
      completed: completed,
      bestTimeMs: best,
      timesCompleted: count,
    );
  }

  Map<int, LevelProgress> loadAll() => <int, LevelProgress>{
        for (var level = 1; level <= totalLevels; level++) level: load(level),
      };

  Future<void> save(LevelProgress p) async {
    await _prefs.setBool(_doneKey(p.globalLevel), p.completed);
    await _prefs.setInt(_countKey(p.globalLevel), p.timesCompleted);
    final best = p.bestTimeMs;
    if (best != null) await _prefs.setInt(_bestKey(p.globalLevel), best);
  }
}

/// Whether the running build unlocks every level regardless of progress. True
/// for the debug ("Sudoku Testing") build so testers can reach any level; the
/// release ("Sudoku") build enforces the locked progression.
bool get testingUnlocksAllLevels => kDebugMode;

class ProgressNotifier extends StateNotifier<Map<int, LevelProgress>> {
  ProgressNotifier(this._repo, {bool? unlockAllLevels})
      : _unlockAll = unlockAllLevels ?? testingUnlocksAllLevels,
        super(_repo.loadAll());

  final SudokuProgressRepository _repo;
  final bool _unlockAll;

  LevelProgress progressFor(int level) =>
      state[level] ?? LevelProgress.empty(level);

  /// Records a solve of [level] in [timeMs] and persists it.
  void recordCompletion(int level, int timeMs) {
    final updated = progressFor(level).withCompletion(timeMs);
    _repo.save(updated);
    state = <int, LevelProgress>{...state, level: updated};
  }

  /// Total number of puzzles solved across all levels.
  int get totalGamesCompleted =>
      state.values.fold(0, (sum, p) => sum + p.timesCompleted);

  /// Level 1 is always open; each later level unlocks once the previous is
  /// cleared. The debug ("Sudoku Testing") build unlocks everything.
  bool isUnlocked(int level) => _unlockAll || unlockedByProgress(level);

  /// The pure unlock rule (ignores debug-mode overrides):
  /// - Level 1 is always open.
  /// - The first level of a tier (11, 21) opens once [tierUnlockThreshold]
  ///   levels of the previous tier are cleared.
  /// - Every other level needs the previous one cleared.
  bool unlockedByProgress(int level) {
    if (level <= 1) return true;
    if (_isFirstOfTier(level)) {
      return completedInTier(_tierIndexOf(level) - 1) >= tierUnlockThreshold;
    }
    return progressFor(level - 1).completed;
  }

  /// Tier index (0..2) of a global [level].
  int _tierIndexOf(int level) => (level - 1) ~/ levelsPerTier;

  /// Whether [level] is the first level of a tier beyond the first (11 or 21).
  bool _isFirstOfTier(int level) =>
      level > 1 && (level - 1) % levelsPerTier == 0;

  /// How many levels of tier [tierIndex] (0..2) are cleared.
  int completedInTier(int tierIndex) {
    final start = tierIndex * levelsPerTier + 1;
    var count = 0;
    for (var level = start; level < start + levelsPerTier; level++) {
      if (progressFor(level).completed) count++;
    }
    return count;
  }

  /// The highest unlocked level (for a "Continue" affordance).
  int get highestUnlocked {
    var highest = 1;
    for (var level = 2; level <= totalLevels; level++) {
      if (unlockedByProgress(level)) highest = level;
    }
    return highest;
  }
}

final progressRepositoryProvider = Provider<SudokuProgressRepository>(
  (ref) => SudokuProgressRepository(ref.watch(sharedPreferencesProvider)),
);

final progressProvider =
    StateNotifierProvider<ProgressNotifier, Map<int, LevelProgress>>(
  (ref) => ProgressNotifier(ref.watch(progressRepositoryProvider)),
);
