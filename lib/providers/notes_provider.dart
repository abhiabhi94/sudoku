/// Per-level notes: a scratchpad the player can jot text into or scribble on
/// (candidates, reasoning, reminders). Persisted per level in shared_preferences
/// as a JSON blob (text + vector strokes).
library;

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/level_note.dart';
import 'app_providers.dart';

class NotesRepository {
  NotesRepository(this._prefs);

  final SharedPreferences _prefs;

  String _key(int level) => 'sudoku_note_$level';

  LevelNote load(int level) {
    final raw = _prefs.getString(_key(level));
    if (raw == null || raw.isEmpty) return LevelNote.empty;
    // Notes are now stored as a JSON object; a value that isn't one is a legacy
    // plain-text note (text-only, pre-scribble) and loads as its text.
    if (!raw.startsWith('{')) return LevelNote(text: raw);
    return LevelNote.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(int level, LevelNote note) {
    if (note.isEmpty) return _prefs.remove(_key(level));
    return _prefs.setString(_key(level), jsonEncode(note.toJson()));
  }
}

/// Holds the note for one level; the game screen watches it so the notes button
/// can show whether a note exists.
class LevelNoteNotifier extends StateNotifier<LevelNote> {
  LevelNoteNotifier(this._repo, this._level) : super(_repo.load(_level));

  final NotesRepository _repo;
  final int _level;

  void save(LevelNote note) {
    _repo.save(_level, note);
    state = note.isEmpty ? LevelNote.empty : note;
  }
}

final notesRepositoryProvider = Provider<NotesRepository>(
  (ref) => NotesRepository(ref.watch(sharedPreferencesProvider)),
);

final levelNoteProvider =
    StateNotifierProvider.family<LevelNoteNotifier, LevelNote, int>(
  (ref, level) => LevelNoteNotifier(ref.watch(notesRepositoryProvider), level),
);
