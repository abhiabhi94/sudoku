import 'package:sudoku/engine/board.dart';
import 'package:sudoku/engine/puzzle_factory.dart';

/// A solved Wikipedia grid used as a known solution in gameplay tests.
final List<int> kFakeSolution = parseBoard(
  '534678912672195348198342567859761423426853791'
  '713924856961537284287419635345286179',
);

/// A near-complete puzzle with [blanks] cells removed from [kFakeSolution],
/// so tests can drive input to a win quickly.
GeneratedPuzzle fakePuzzle({List<int> blanks = const [0, 1]}) {
  final givens = List<int>.of(kFakeSolution);
  for (final b in blanks) {
    givens[b] = 0;
  }
  return GeneratedPuzzle(
    givens: givens,
    solution: kFakeSolution,
    tier: 1,
    level: 1,
    clueCount: cellCount - blanks.length,
    hardestTier: 1,
    score: 0,
    inBand: true,
  );
}
