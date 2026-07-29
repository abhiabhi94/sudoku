/// The single "active game" slot: the in-progress puzzle a player can resume.
/// Persisted as a JSON blob in shared_preferences under an app-prefixed key.
library;

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_game.dart';
import 'app_providers.dart';

const String _activeGameKey = 'sudoku_active_game';

class ActiveGameRepository {
  ActiveGameRepository(this._prefs);

  final SharedPreferences _prefs;

  SavedGame? load() {
    final raw = _prefs.getString(_activeGameKey);
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return SavedGame.fromJson(json);
  }

  Future<void> save(SavedGame game) =>
      _prefs.setString(_activeGameKey, jsonEncode(game.toJson()));

  Future<void> clear() => _prefs.remove(_activeGameKey);
}

/// Holds the current resumable game (or null). The home screen watches this to
/// show/hide its "Continue" card; the game notifier updates it on every move.
class ActiveGameNotifier extends StateNotifier<SavedGame?> {
  ActiveGameNotifier(this._repo) : super(_repo.load());

  final ActiveGameRepository _repo;

  void save(SavedGame game) {
    _repo.save(game);
    state = game;
  }

  void clear() {
    _repo.clear();
    state = null;
  }
}

final activeGameRepositoryProvider = Provider<ActiveGameRepository>(
  (ref) => ActiveGameRepository(ref.watch(sharedPreferencesProvider)),
);

final activeGameProvider =
    StateNotifierProvider<ActiveGameNotifier, SavedGame?>(
  (ref) => ActiveGameNotifier(ref.watch(activeGameRepositoryProvider)),
);
