/// Level progress state: completion, best times, unlock progression. Persisted
/// via shared_preferences with app-prefixed keys.
library;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/level_progress.dart';
import 'app_providers.dart';

/// Total number of levels (4 tiers x 10).
const int totalLevels = 40;

/// Levels per tier.
const int levelsPerTier = 10;

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

  /// The first level of each tier is always open; each later level unlocks
  /// once the previous is cleared. The debug ("Sudoku Testing") build unlocks
  /// everything.
  bool isUnlocked(int level) => _unlockAll || unlockedByProgress(level);

  /// The pure unlock rule (ignores debug-mode overrides):
  /// - The first level of every tier (1, 11, 21, 31) is always open, so a
  ///   player can jump straight into Advanced, Expert or Master.
  /// - Every other level needs the previous one cleared.
  bool unlockedByProgress(int level) {
    if (level <= 1) return true;
    if (_isFirstOfTier(level)) return true;
    return progressFor(level - 1).completed;
  }

  /// Whether [level] is the first level of a tier beyond the first (11, 21, 31).
  bool _isFirstOfTier(int level) =>
      level > 1 && (level - 1) % levelsPerTier == 0;

  /// How many levels of tier [tierIndex] (0..3) are cleared.
  int completedInTier(int tierIndex) {
    final start = tierIndex * levelsPerTier + 1;
    var count = 0;
    for (var level = start; level < start + levelsPerTier; level++) {
      if (progressFor(level).completed) count++;
    }
    return count;
  }

  /// The furthest level reached by linear progress — the highest level whose
  /// previous level has been cleared (for a "Continue" affordance). This
  /// deliberately ignores the always-open first level of each tier, so it
  /// stays a meaningful resume target rather than jumping ahead to a later
  /// tier on a fresh install.
  int get highestUnlocked {
    var highest = 1;
    for (var level = 2; level <= totalLevels; level++) {
      if (progressFor(level - 1).completed) highest = level;
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
