import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/providers/notes_provider.dart';

Future<NotesRepository> _repo([Map<String, Object> seed = const {}]) async {
  SharedPreferences.setMockInitialValues(seed);
  return NotesRepository(await SharedPreferences.getInstance());
}

void main() {
  group('NotesRepository', () {
    test('load returns empty when nothing is stored', () async {
      final repo = await _repo();
      expect(repo.load(5), '');
    });

    test('save then load round-trips per level, trimming whitespace', () async {
      final repo = await _repo();
      await repo.save(5, '  r3c5 -> 2 or 7  ');
      expect(repo.load(5), 'r3c5 -> 2 or 7');
      expect(repo.load(6), ''); // other levels untouched
    });

    test('saving an empty (or blank) note clears it', () async {
      final repo = await _repo();
      await repo.save(5, 'temp');
      await repo.save(5, '   ');
      expect(repo.load(5), '');
    });
  });

  group('LevelNoteNotifier', () {
    test('exposes the saved note and persists edits', () async {
      final repo = await _repo({'sudoku_note_7': 'hello'});
      final notifier = LevelNoteNotifier(repo, 7);
      addTearDown(notifier.dispose);

      expect(notifier.state, 'hello');
      notifier.save('updated');
      expect(notifier.state, 'updated');
      expect(repo.load(7), 'updated');
    });
  });
}
