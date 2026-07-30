import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/engine/puzzle_factory.dart';
import 'package:sudoku/data/riddle_bank.dart';
import 'package:sudoku/models/game_state.dart';
import 'package:sudoku/models/riddle.dart';
import 'package:sudoku/providers/game_provider.dart';
import 'package:sudoku/providers/riddle_rotation_provider.dart';
import 'package:sudoku/screens/game_screen.dart';
import 'package:sudoku/widgets/cell_notes_panel.dart';
import 'package:sudoku/widgets/drawing_canvas.dart';
import 'package:sudoku/widgets/number_pad.dart';
import 'package:sudoku/widgets/sudoku_grid.dart';

import '../support/fake_puzzle.dart';
import '../support/pump_app.dart';

GameNotifier _testNotifier({List<int> blanks = const [0]}) {
  Future<GeneratedPuzzle> gen(int t, int l, int s) async =>
      fakePuzzle(blanks: blanks);
  return GameNotifier(
    globalLevel: 1,
    generator: gen,
    seedSource: () => 0,
    autoTick: false,
  );
}

Future<ProviderContainer> _loadGame(
    WidgetTester tester, GameNotifier notifier) async {
  await tester.binding.setSurfaceSize(const Size(500, 1100));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final container = await pumpApp(
    tester,
    const GameScreen(globalLevel: 1),
    extraOverrides: [
      gameProvider((level: 1, resume: false)).overrideWith((ref) => notifier),
      // Deterministic riddle order so tests can rely on "echo" appearing first.
      riddleSourceProvider.overrideWithValue(_SequentialSource()),
    ],
  );
  await notifier.ready;
  await tester.pump(); // rebuild into the playing state
  return container;
}

/// Deals riddles straight from the bank in order, so the first English riddle
/// is always "echo". Replaces the persistent shuffle in widget tests.
class _SequentialSource implements RiddleSource {
  final Map<String, int> _cursor = <String, int>{};

  @override
  Riddle take(String languageCode) {
    final bank = riddlesFor(languageCode);
    final i = _cursor[languageCode] ?? 0;
    _cursor[languageCode] = i + 1;
    return bank[i % bank.length];
  }
}

void main() {
  testWidgets('shows the board and number pad once loaded', (tester) async {
    final notifier = _testNotifier();
    await _loadGame(tester, notifier);

    expect(find.byType(SudokuGrid), findsOneWidget);
    expect(find.byType(NumberPad), findsOneWidget);
  });

  testWidgets('solving the puzzle shows the victory overlay', (tester) async {
    final notifier = _testNotifier(blanks: const [0]);
    await _loadGame(tester, notifier);

    notifier.selectCell(0);
    notifier.inputDigit(kFakeSolution[0]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Solved it!'), findsOneWidget);
  });

  testWidgets('the lockout overlay appears after a fourth mistake', (tester) async {
    final notifier = _testNotifier(blanks: const [0, 1]);
    await _loadGame(tester, notifier);

    notifier.selectCell(0);
    final wrong = kFakeSolution[0] == 1 ? 2 : 1;
    for (var i = 0; i < 4; i++) {
      notifier.inputDigit(wrong);
    }
    await tester.pump();

    expect(find.text('Whoa, slow down!'), findsOneWidget);
  });

  testWidgets('the refresh button deals a new puzzle', (tester) async {
    final notifier = _testNotifier();
    await _loadGame(tester, notifier);
    notifier.selectCell(0);
    notifier.inputDigit(kFakeSolution[0] == 1 ? 2 : 1); // a mistake
    await tester.pump();
    expect(notifier.state.mistakes, 1);

    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pump();
    await tester.pump();
    expect(notifier.state.mistakes, 0);
    expect(notifier.state.phase, GamePhase.playing);
  });

  testWidgets('victory "Play again" dismisses the overlay', (tester) async {
    final notifier = _testNotifier(blanks: const [0]);
    await _loadGame(tester, notifier);
    notifier.selectCell(0);
    notifier.inputDigit(kFakeSolution[0]);
    await tester.pump();
    expect(find.text('Solved it!'), findsOneWidget);

    // Let the victory confetti finish so its timer isn't left pending.
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.text('Play again'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Solved it!'), findsNothing);
    expect(notifier.state.phase, GamePhase.playing);
  });

  testWidgets('tapping Hint opens the riddle and a correct answer reveals a cell',
      (tester) async {
    final notifier = _testNotifier(blanks: const [0, 1]);
    await _loadGame(tester, notifier);

    await tester.tap(find.text('Hint'));
    await tester.pumpAndSettle();
    expect(find.text('Solve to earn a hint'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'echo'); // first EN riddle
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    expect(notifier.state.hintsUsed, 1);
    expect(notifier.state.hintCells, isNotEmpty);
    // The "Why here?" explanation card appears after a hint.
    expect(find.text('Why here?'), findsOneWidget);

    // Closing it dismisses the explanation.
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Why here?'), findsNothing);
  });

  testWidgets('the riddle offers a hidden clue on request', (tester) async {
    final notifier = _testNotifier(blanks: const [0, 1]);
    await _loadGame(tester, notifier);

    await tester.tap(find.text('Hint'));
    await tester.pumpAndSettle();
    // Clue is hidden until asked for.
    expect(find.textContaining('canyon'), findsNothing);

    await tester.tap(find.text('Need a clue?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('canyon'), findsOneWidget); // echo clue
  });

  group('cell notes panel', () {
    testWidgets('appears only once an empty editable cell is selected',
        (tester) async {
      final notifier = _testNotifier(blanks: const [0, 1]);
      await _loadGame(tester, notifier);

      // Nothing selected yet -> no panel.
      expect(find.byType(CellNotesPanel), findsNothing);

      notifier.selectCell(0); // an empty, editable cell
      await tester.pump();
      expect(find.byType(CellNotesPanel), findsOneWidget);
    });

    testWidgets('does not appear for a given (non-editable) cell',
        (tester) async {
      final notifier = _testNotifier(blanks: const [0, 1]);
      await _loadGame(tester, notifier);

      notifier.selectCell(2); // cell 2 is a given
      await tester.pump();
      expect(find.byType(CellNotesPanel), findsNothing);
    });

    testWidgets('scribbling in the panel persists notes for the cell',
        (tester) async {
      final notifier = _testNotifier(blanks: const [0, 1]);
      await _loadGame(tester, notifier);

      notifier.selectCell(0);
      await tester.pump();

      await tester.drag(find.byType(DrawingCanvas), const Offset(60, 40));
      await tester.pump();

      expect(notifier.state.notesFor(0), isNotEmpty);
    });

    testWidgets('Undo removes the last stroke only', (tester) async {
      final notifier = _testNotifier(blanks: const [0, 1]);
      await _loadGame(tester, notifier);

      notifier.selectCell(0);
      await tester.pump();
      await tester.drag(find.byType(DrawingCanvas), const Offset(50, 30));
      await tester.pump();
      await tester.drag(find.byType(DrawingCanvas), const Offset(-30, 40));
      await tester.pump();
      expect(notifier.state.notesFor(0), hasLength(2));

      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(notifier.state.notesFor(0), hasLength(1));
    });

    testWidgets('Clear wipes the cell notes', (tester) async {
      final notifier = _testNotifier(blanks: const [0, 1]);
      await _loadGame(tester, notifier);

      notifier.selectCell(0);
      await tester.pump();
      await tester.drag(find.byType(DrawingCanvas), const Offset(60, 40));
      await tester.pump();
      expect(notifier.state.notesFor(0), isNotEmpty);

      await tester.tap(find.text('Clear'));
      await tester.pump();
      expect(notifier.state.notesFor(0), isEmpty);
    });
  });
}
