import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/models/level_note.dart';
import 'package:sudoku/providers/notes_provider.dart';

Future<NotesRepository> _repo([Map<String, Object> seed = const {}]) async {
  SharedPreferences.setMockInitialValues(seed);
  return NotesRepository(await SharedPreferences.getInstance());
}

void main() {
  group('NotesRepository', () {
    test('load returns an empty note when nothing is stored', () async {
      final repo = await _repo();
      expect(repo.load(5).isEmpty, isTrue);
      expect(repo.load(5).text, '');
      expect(repo.load(5).strokes, isEmpty);
    });

    test('save then load round-trips text per level, trimming whitespace',
        () async {
      final repo = await _repo();
      await repo.save(5, const LevelNote(text: '  r3c5 -> 2 or 7  '));
      expect(repo.load(5).text, 'r3c5 -> 2 or 7');
      expect(repo.load(6).isEmpty, isTrue); // other levels untouched
    });

    test('save then load round-trips scribble strokes', () async {
      final repo = await _repo();
      const note = LevelNote(
        strokes: [
          Stroke([Offset(0.1, 0.2), Offset(0.3, 0.4)]),
          Stroke([Offset(0.5, 0.5), Offset(0.6, 0.7), Offset(0.9, 0.1)]),
        ],
      );
      await repo.save(5, note);

      final loaded = repo.load(5);
      expect(loaded.strokes, hasLength(2));
      expect(loaded.strokes[0].points, [const Offset(0.1, 0.2), const Offset(0.3, 0.4)]);
      expect(loaded.strokes[1].points.last, const Offset(0.9, 0.1));
    });

    test('saving an empty note clears it', () async {
      final repo = await _repo();
      await repo.save(5, const LevelNote(text: 'temp'));
      await repo.save(5, const LevelNote(text: '   '));
      expect(repo.load(5).isEmpty, isTrue);
    });

    test('a legacy plain-text value loads as a text note', () async {
      final repo = await _repo({'sudoku_note_7': 'old plain note'});
      expect(repo.load(7).text, 'old plain note');
      expect(repo.load(7).strokes, isEmpty);
    });
  });

  group('LevelNoteNotifier', () {
    test('exposes the saved note and persists edits', () async {
      final repo = await _repo({'sudoku_note_7': 'hello'});
      final notifier = LevelNoteNotifier(repo, 7);
      addTearDown(notifier.dispose);

      expect(notifier.state.text, 'hello');
      notifier.save(const LevelNote(text: 'updated'));
      expect(notifier.state.text, 'updated');
      expect(repo.load(7).text, 'updated');
    });

    test('saving an empty note resets state to empty', () async {
      final repo = await _repo();
      final notifier = LevelNoteNotifier(repo, 3);
      addTearDown(notifier.dispose);

      notifier.save(const LevelNote(text: 'draft'));
      notifier.save(const LevelNote(text: '  '));
      expect(notifier.state.isEmpty, isTrue);
    });
  });
}
