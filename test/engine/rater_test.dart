import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/engine/board.dart';
import 'package:sudoku/engine/rater.dart';
import 'package:sudoku/engine/techniques.dart';

void main() {
  final easyPuzzle = parseBoard(
    '53..7....6..195....98....6.8...6...34..8.3..17...2...6.6....28....419..5....8..79',
  );
  final solution = parseBoard(
    '534678912672195348198342567859761423426853791'
    '713924856961537284287419635345286179',
  );

  test('rates an easy puzzle as solvable with a low technique tier', () {
    final rating = rate(easyPuzzle);
    expect(rating.solvable, isTrue);
    expect(rating.hardestTier, inInclusiveRange(1, 2));
    expect(rating.clueCount, easyPuzzle.where((v) => v != 0).length);
    expect(rating.score, greaterThan(0));
  });

  test('a completed grid needs no techniques', () {
    final rating = rate(solution);
    expect(rating.solvable, isTrue);
    expect(rating.hardestTier, 0);
    expect(rating.clueCount, cellCount);
    expect(rating.techniqueCounts, isEmpty);
  });

  test('usedTechnique reflects the technique counts', () {
    final rating = rate(easyPuzzle);
    expect(rating.usedTechnique(Technique.nakedSingle), isTrue);
  });
}
