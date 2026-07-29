import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/models/saved_game.dart';
import 'package:sudoku/providers/active_game_provider.dart';
import 'package:sudoku/screens/home_screen.dart';

import '../support/fake_puzzle.dart';
import '../support/pump_app.dart';

Map<String, Object> _seedWithActiveGame() {
  final puzzle = fakePuzzle(blanks: const [0, 1, 2, 3]);
  final board = List<int>.of(puzzle.givens)..[0] = kFakeSolution[0];
  final game = SavedGame(
    globalLevel: 3,
    puzzle: puzzle,
    board: board,
    mistakes: 0,
    elapsedMs: 5000,
    hintsUsed: 0,
    hintCells: const <int>{},
    errorCells: const <int>{},
  );
  return <String, Object>{'sudoku_active_game': jsonEncode(game.toJson())};
}

void main() {
  testWidgets('renders title, tiers and the games-completed stat', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpApp(tester, const HomeScreen());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Sudoku'), findsOneWidget);
    expect(find.text('Beginner'), findsOneWidget);
    expect(find.text('Advanced'), findsOneWidget);
    expect(find.text('Expert'), findsOneWidget);
    expect(find.text('Games completed'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('shows a Continue card when a saved game exists', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpApp(tester, const HomeScreen(), seed: _seedWithActiveGame());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Continue'), findsOneWidget);
    // 4 blanks, 1 filled -> 25%.
    expect(find.textContaining('25%'), findsOneWidget);
  });

  testWidgets('dismissing the Continue card clears the saved game', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container =
        await pumpApp(tester, const HomeScreen(), seed: _seedWithActiveGame());
    await tester.pump(const Duration(milliseconds: 300));
    expect(container.read(activeGameProvider), isNotNull);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    expect(container.read(activeGameProvider), isNull);
    expect(find.text('Continue'), findsNothing);
  });
}
