import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/engine/board.dart';
import 'package:sudoku/engine/puzzle_factory.dart';
import 'package:sudoku/engine/techniques.dart';

/// A state with every cell empty and all nine candidates everywhere.
SolveState _fullState() => SolveState.raw(
      List<int>.filled(cellCount, 0),
      List<int>.filled(cellCount, allCandidatesMask),
    );

/// Clears [digit] from the candidates of every cell in [unit] except [keep].
void _confineDigit(SolveState s, List<int> unit, int digit, Set<int> keep) {
  final clear = ~maskForDigit(digit);
  for (final i in unit) {
    if (!keep.contains(i)) s.candidates[i] &= clear;
  }
}

bool _hasElim(SolveStep step, int index, int digit) =>
    step.eliminations.any((e) => e.index == index && e.digit == digit);

void main() {
  group('naked single', () {
    test('finds a cell with one candidate', () {
      final s = _fullState();
      s.candidates[40] = maskForDigit(7);
      final step = detectNakedSingle(s)!;
      expect(step.technique, Technique.nakedSingle);
      expect(step.placements.single.index, 40);
      expect(step.placements.single.digit, 7);
    });

    test('returns null when no cell is forced', () {
      expect(detectNakedSingle(_fullState()), isNull);
    });
  });

  group('hidden single', () {
    test('finds a digit with a single home in a unit', () {
      final s = _fullState();
      // 7 lives only in cell 0 of row 0, but cell 0 also holds a 3 (not naked).
      s.candidates[0] = maskForDigit(3) | maskForDigit(7);
      _confineDigit(s, rowUnits[0], 7, {0});
      expect(detectNakedSingle(s), isNull);
      final step = detectHiddenSingle(s)!;
      expect(step.technique, Technique.hiddenSingle);
      expect(step.placements.any((p) => p.index == 0 && p.digit == 7), isTrue);
    });
  });

  group('locked candidates', () {
    test('pointing: a digit confined to one row within a box clears the row',
        () {
      final s = _fullState();
      // Digit 4 in box 0 confined to row 0 (cells 0,1,2).
      _confineDigit(s, boxUnits[0], 4, {0, 1, 2});
      final step = detectLockedCandidates(s)!;
      expect(step.technique, Technique.lockedCandidates);
      // 4 removed from the rest of row 0 (cells 3..8).
      for (var c = 3; c < 9; c++) {
        expect(_hasElim(step, c, 4), isTrue, reason: 'cell $c should lose 4');
      }
    });
  });

  group('naked pair', () {
    test('two cells sharing two candidates clear them from the unit', () {
      final s = _fullState();
      s.candidates[0] = maskForDigit(1) | maskForDigit(2);
      s.candidates[1] = maskForDigit(1) | maskForDigit(2);
      final step = detectNakedSubset(s, 2)!;
      expect(step.technique, Technique.nakedPair);
      expect(_hasElim(step, 2, 1), isTrue);
      expect(_hasElim(step, 8, 2), isTrue);
    });
  });

  group('hidden pair', () {
    test('two digits confined to two cells strip other candidates', () {
      final s = _fullState();
      // 8 and 9 live only in cells 0 and 3 of row 0 (different boxes, so
      // locked-candidates cannot fire first).
      _confineDigit(s, rowUnits[0], 8, {0, 3});
      _confineDigit(s, rowUnits[0], 9, {0, 3});
      expect(detectLockedCandidates(s), isNull);
      final step = detectHiddenSubset(s, 2)!;
      expect(step.technique, Technique.hiddenPair);
      // Cells 0 and 3 lose everything except 8 and 9.
      expect(_hasElim(step, 0, 1), isTrue);
      expect(_hasElim(step, 3, 7), isTrue);
      expect(_hasElim(step, 0, 8), isFalse);
    });
  });

  group('naked triple', () {
    test('three cells covering three candidates clear the unit', () {
      final s = _fullState();
      s.candidates[0] = maskForDigit(1) | maskForDigit(2);
      s.candidates[1] = maskForDigit(2) | maskForDigit(3);
      s.candidates[2] = maskForDigit(1) | maskForDigit(3);
      expect(detectNakedSubset(s, 2), isNull);
      final step = detectNakedSubset(s, 3)!;
      expect(step.technique, Technique.nakedTriple);
      expect(_hasElim(step, 5, 1), isTrue);
      expect(_hasElim(step, 7, 3), isTrue);
    });
  });

  group('hidden triple', () {
    test('three digits confined to three cells strip other candidates', () {
      final s = _fullState();
      // 7,8,9 confined to cells 0,1,3 of row 0 (spanning two boxes).
      _confineDigit(s, rowUnits[0], 7, {0, 1, 3});
      _confineDigit(s, rowUnits[0], 8, {0, 1, 3});
      _confineDigit(s, rowUnits[0], 9, {0, 1, 3});
      expect(detectLockedCandidates(s), isNull);
      final step = detectHiddenSubset(s, 3)!;
      expect(step.technique, Technique.hiddenTriple);
      expect(_hasElim(step, 0, 1), isTrue);
      expect(_hasElim(step, 3, 6), isTrue);
    });
  });

  group('x-wing', () {
    test('a digit locked to two columns across two rows clears the columns',
        () {
      final s = _fullState();
      // Digit 5 confined to columns 2 and 6 in rows 0 and 3.
      _confineDigit(s, rowUnits[0], 5, {indexOf(0, 2), indexOf(0, 6)});
      _confineDigit(s, rowUnits[3], 5, {indexOf(3, 2), indexOf(3, 6)});
      expect(detectLockedCandidates(s), isNull);
      final step = detectXWing(s)!;
      expect(step.technique, Technique.xWing);
      // 5 removed from columns 2 and 6 in other rows.
      expect(_hasElim(step, indexOf(1, 2), 5), isTrue);
      expect(_hasElim(step, indexOf(5, 6), 5), isTrue);
      // Never from the defining rows.
      expect(_hasElim(step, indexOf(0, 2), 5), isFalse);
    });
  });

  group('xy-wing', () {
    test('a pivot {x,y} with pincers {x,z} and {y,z} clears z from cells '
        'seeing both pincers', () {
      final s = _fullState();
      // Pivot at (0,0) = {1,2}; pincers at (0,4) = {1,3} (same row) and
      // (4,0) = {2,3} (same column). Cell (4,4) sees both pincers.
      s.candidates[indexOf(0, 0)] = maskForDigit(1) | maskForDigit(2);
      s.candidates[indexOf(0, 4)] = maskForDigit(1) | maskForDigit(3);
      s.candidates[indexOf(4, 0)] = maskForDigit(2) | maskForDigit(3);
      final step = detectXYWing(s)!;
      expect(step.technique, Technique.xyWing);
      expect(_hasElim(step, indexOf(4, 4), 3), isTrue);
      // (0,8) sees only the row pincer, so it keeps its 3.
      expect(_hasElim(step, indexOf(0, 8), 3), isFalse);
      // Never from the wing cells themselves, and never a non-z digit.
      expect(_hasElim(step, indexOf(0, 4), 3), isFalse);
      expect(_hasElim(step, indexOf(4, 0), 3), isFalse);
      expect(step.eliminations.every((e) => e.digit == 3), isTrue);
    });

    test('ignores bivalue peers that do not form a wing', () {
      final s = _fullState();
      // Two peers sharing the SAME pivot digit are not pincers.
      s.candidates[indexOf(0, 0)] = maskForDigit(1) | maskForDigit(2);
      s.candidates[indexOf(0, 4)] = maskForDigit(1) | maskForDigit(3);
      s.candidates[indexOf(4, 0)] = maskForDigit(1) | maskForDigit(3);
      expect(detectXYWing(s), isNull);
    });

    test('returns null when z is already absent around the pincers', () {
      final s = _fullState();
      s.candidates[indexOf(0, 0)] = maskForDigit(1) | maskForDigit(2);
      s.candidates[indexOf(0, 4)] = maskForDigit(1) | maskForDigit(3);
      s.candidates[indexOf(4, 0)] = maskForDigit(2) | maskForDigit(3);
      final clear = ~maskForDigit(3);
      for (var i = 0; i < cellCount; i++) {
        if (i != indexOf(0, 4) && i != indexOf(4, 0)) s.candidates[i] &= clear;
      }
      expect(detectXYWing(s), isNull);
    });
  });

  group('solveLogically & firstHint', () {
    final puzzle = parseBoard(
      '53..7....6..195....98....6.8...6...34..8.3..17...2...6.6....28....419..5....8..79',
    );
    final solution = parseBoard(
      '534678912672195348198342567859761423426853791'
      '713924856961537284287419635345286179',
    );

    test('solves an easy puzzle and reports the hardest technique', () {
      final result = solveLogically(puzzle);
      expect(result.solved, isTrue);
      expect(result.board, solution);
      expect(result.hardestTier, greaterThanOrEqualTo(1));
      expect(result.techniqueCounts, isNotEmpty);
    });

    test('firstHint returns a correct next placement', () {
      final hint = firstHint(puzzle)!;
      expect(hint.digit, solution[hint.index]);
      expect(puzzle[hint.index], 0, reason: 'hints target empty cells');
    });

    test('firstHint returns null when no logic applies (empty board)', () {
      expect(firstHint(List<int>.filled(cellCount, 0)), isNull);
    });

    test('firstHint applies eliminations before finding a placement', () {
      // Advance an advanced puzzle to the first state whose next logical step
      // is an elimination (no single available), then hint from there.
      List<int>? eliminationFirst;
      for (var seed = 0; seed < 30 && eliminationFirst == null; seed++) {
        final p = generateForBand(2, 5, seed);
        final s = SolveState.fromBoard(p.givens);
        while (!isFilled(s.cells)) {
          final step = nextStep(s);
          if (step == null) break;
          if (step.placements.isEmpty) {
            eliminationFirst = List<int>.of(s.cells);
            break;
          }
          for (final pl in step.placements) {
            if (s.cells[pl.index] == 0) s.place(pl.index, pl.digit);
          }
        }
      }
      expect(eliminationFirst, isNotNull,
          reason: 'expected an elimination-first mid-solve state');
      expect(firstHint(eliminationFirst!), isNotNull);
    });
  });

  group('value types', () {
    test('Placement and Elimination stringify and compare', () {
      expect(const Placement(0, 5).toString(), contains('5'));
      expect(const Elimination(3, 7).toString(), contains('!='));
      expect(const Elimination(3, 7), const Elimination(3, 7));
      expect(const Elimination(3, 7).hashCode, const Elimination(3, 7).hashCode);
    });
  });
}
