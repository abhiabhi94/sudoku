import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/providers/notes_provider.dart';
import 'package:sudoku/widgets/drawing_canvas.dart';
import 'package:sudoku/widgets/notes_sheet.dart';

import '../support/pump_app.dart';

/// Opens the notes sheet over a trivial host screen and returns the container.
Future<ProviderContainer> _openSheet(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(500, 1100));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final container = await pumpApp(
    tester,
    Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => showNotesSheet(context, level: 3),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('switching to Draw shows the canvas and a scribble is saved',
      (tester) async {
    final container = await _openSheet(tester);

    // Text mode is the default.
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(DrawingCanvas), findsNothing);

    await tester.tap(find.text('Draw'));
    await tester.pumpAndSettle();
    expect(find.byType(DrawingCanvas), findsOneWidget);

    // Drag across the canvas to draw a stroke.
    await tester.drag(find.byType(DrawingCanvas), const Offset(80, 60));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final note = container.read(levelNoteProvider(3));
    expect(note.strokes, isNotEmpty);
    expect(note.strokes.first.points.length, greaterThan(1));
  });

  testWidgets('Undo removes the last stroke', (tester) async {
    final container = await _openSheet(tester);

    await tester.tap(find.text('Draw'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(DrawingCanvas), const Offset(60, 40));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(DrawingCanvas), const Offset(-40, 50));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Two strokes drawn, one undone -> one saved.
    expect(container.read(levelNoteProvider(3)).strokes, hasLength(1));
  });

  testWidgets('Clear wipes every stroke', (tester) async {
    final container = await _openSheet(tester);

    await tester.tap(find.text('Draw'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(DrawingCanvas), const Offset(70, 30));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(container.read(levelNoteProvider(3)).isEmpty, isTrue);
  });

  testWidgets('a tap without dragging is not recorded as a stroke',
      (tester) async {
    final container = await _openSheet(tester);

    await tester.tap(find.text('Draw'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DrawingCanvas));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(container.read(levelNoteProvider(3)).strokes, isEmpty);
  });
}
