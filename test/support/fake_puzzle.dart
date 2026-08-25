import 'package:sudoku/engine/board.dart';
import 'package:sudoku/engine/puzzle_factory.dart';

/// A solved Wikipedia grid used as a known solution in gameplay tests.
final List<int> kFakeSolution = parseBoard(
  '534678912672195348198342567859761423426853791'
  '713924856961537284287419635345286179',
);

/// The cell used by [kWrongBlanks] for wrong-placement tests (solution: 5).
const int kWrongCell = 0;

/// A digit that is never correct at [kWrongCell], and — with [kWrongBlanks] —
/// always still placeable.
const int kWrongDigit = 1;

/// Blanks for exercising *wrong* placements.
///
/// The default near-complete fixture leaves every digit but one fully placed,
/// and a fully-placed digit can never be a legal entry — so the pad routes a
/// tap on it to the same-digit highlight instead of the board. That makes any
/// "wrong" digit unusable there. This blanks [kWrongCell] plus five cells
/// holding a 1, leaving [kWrongDigit] both wrong at [kWrongCell] and still
/// placeable, even across repeated attempts.
const List<int> kWrongBlanks = <int>[kWrongCell, 7, 12, 18, 32, 44];

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
