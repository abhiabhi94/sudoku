/// Per-level free-text notes: a scratchpad the player can jot anything into
/// (candidates, reasoning, reminders). Persisted per level in shared_preferences.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_providers.dart';

class NotesRepository {
  NotesRepository(this._prefs);

  final SharedPreferences _prefs;

  String _key(int level) => 'sudoku_note_$level';

  String load(int level) => _prefs.getString(_key(level)) ?? '';

  Future<void> save(int level, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return _prefs.remove(_key(level));
    return _prefs.setString(_key(level), trimmed);
  }
}

/// Holds the note text for one level; the game screen watches it so the notes
/// button can show whether a note exists.
class LevelNoteNotifier extends StateNotifier<String> {
  LevelNoteNotifier(this._repo, this._level) : super(_repo.load(_level));

  final NotesRepository _repo;
  final int _level;

  void save(String text) {
    _repo.save(_level, text);
    state = text.trim();
  }
}

final notesRepositoryProvider = Provider<NotesRepository>(
  (ref) => NotesRepository(ref.watch(sharedPreferencesProvider)),
);

final levelNoteProvider =
    StateNotifierProvider.family<LevelNoteNotifier, String, int>(
  (ref, level) => LevelNoteNotifier(ref.watch(notesRepositoryProvider), level),
);
