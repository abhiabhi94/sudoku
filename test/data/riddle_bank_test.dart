import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/data/riddle_bank.dart';

void main() {
  test('each language has ten riddles with unique ids and answers', () {
    for (final lang in ['en', 'hi']) {
      final riddles = riddlesFor(lang);
      expect(riddles.length, 10, reason: '$lang should have 10 riddles');
      expect(riddles.map((r) => r.id).toSet().length, 10,
          reason: '$lang ids must be unique');
      for (final r in riddles) {
        expect(r.prompt.trim(), isNotEmpty);
        expect(r.answers, isNotEmpty);
        expect(r.accepts(r.answers.first), isTrue);
      }
    }
  });

  test('English and Hindi banks are distinct sets', () {
    final en = riddlesFor('en').map((r) => r.id).toSet();
    final hi = riddlesFor('hi').map((r) => r.id).toSet();
    expect(en.intersection(hi), isEmpty);
  });

  test('an unknown language falls back to English', () {
    expect(riddlesFor('fr').first.id, riddlesFor('en').first.id);
  });
}
