import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/models/riddle.dart';

void main() {
  const riddle = Riddle(
    id: 'r',
    prompt: 'p',
    answers: ['Echo', 'sound wave'],
    clue: 'c',
  );

  test('accepts an exact answer ignoring case and spaces', () {
    expect(riddle.accepts('echo'), isTrue);
    expect(riddle.accepts('  ECHO '), isTrue);
    expect(riddle.accepts('Echo!'), isTrue);
  });

  test('accepts multi-word answers with collapsed whitespace', () {
    expect(riddle.accepts('sound   wave'), isTrue);
  });

  test('rejects wrong and empty answers', () {
    expect(riddle.accepts('mirror'), isFalse);
    expect(riddle.accepts(''), isFalse);
    expect(riddle.accepts('   '), isFalse);
  });

  test('normalises the Devanagari nukta', () {
    const hindi = Riddle(id: 'h', prompt: 'p', answers: ['प्याज़'], clue: 'c');
    expect(hindi.accepts('प्याज'), isTrue); // without nukta
    expect(hindi.accepts('प्याज़'), isTrue); // with nukta
  });
}
