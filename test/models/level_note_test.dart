import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/models/level_note.dart';

void main() {
  group('Stroke', () {
    test('flattens and rebuilds its points', () {
      const stroke = Stroke([Offset(0.1, 0.2), Offset(0.3, 0.4)]);
      expect(stroke.toFlat(), [0.1, 0.2, 0.3, 0.4]);
      expect(Stroke.fromFlat(stroke.toFlat()).points, stroke.points);
    });

    test('fromFlat ignores a dangling odd value', () {
      final stroke = Stroke.fromFlat([0.1, 0.2, 0.3]);
      expect(stroke.points, [const Offset(0.1, 0.2)]);
    });
  });

  group('LevelNote', () {
    test('isEmpty only when both text and strokes are empty', () {
      expect(LevelNote.empty.isEmpty, isTrue);
      expect(const LevelNote(text: '  ').isEmpty, isTrue);
      expect(const LevelNote(text: 'x').isEmpty, isFalse);
      expect(
        const LevelNote(strokes: [Stroke([Offset(0, 0), Offset(1, 1)])]).isEmpty,
        isFalse,
      );
    });

    test('toJson/fromJson round-trips text and strokes', () {
      const note = LevelNote(
        text: 'try 7 here',
        strokes: [
          Stroke([Offset(0.2, 0.2), Offset(0.8, 0.8)]),
        ],
      );
      final restored = LevelNote.fromJson(note.toJson());
      expect(restored.text, 'try 7 here');
      expect(restored.strokes.single.points,
          [const Offset(0.2, 0.2), const Offset(0.8, 0.8)]);
    });

    test('fromJson tolerates missing keys', () {
      final restored = LevelNote.fromJson(const {});
      expect(restored.text, '');
      expect(restored.strokes, isEmpty);
    });

    test('copyWith replaces only the given fields', () {
      const note = LevelNote(text: 'a');
      expect(note.copyWith(text: 'b').text, 'b');
      expect(note.copyWith(text: 'b').strokes, note.strokes);
    });
  });
}
