import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/data/level_specs.dart';
import 'package:sudoku/models/level_spec.dart';

void main() {
  test('globalLevel numbers levels 1..30 across tiers', () {
    expect(specFor(1, 1).globalLevel, 1);
    expect(specFor(1, 10).globalLevel, 10);
    expect(specFor(2, 1).globalLevel, 11);
    expect(specFor(3, 10).globalLevel, 30);
  });

  test('difficulty maps tier to the enum', () {
    expect(specFor(1, 1).difficulty, Difficulty.beginner);
    expect(specFor(2, 1).difficulty, Difficulty.advanced);
    expect(specFor(3, 1).difficulty, Difficulty.expert);
  });

  test('Difficulty.tierNumber is 1-based', () {
    expect(Difficulty.beginner.tierNumber, 1);
    expect(Difficulty.advanced.tierNumber, 2);
    expect(Difficulty.expert.tierNumber, 3);
  });
}
