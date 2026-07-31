import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/ui/colors.dart';
import 'package:sudoku/ui/theme.dart';

/// Pumps a MaterialApp in the given [mode] and returns the (brightness, palette)
/// seen by a descendant — the exact pair a real screen resolves at build time.
Future<(Brightness, SudokuPalette)> _resolve(
    WidgetTester tester, ThemeMode mode) async {
  late Brightness brightness;
  late SudokuPalette palette;
  await tester.pumpWidget(
    MaterialApp(
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: mode,
      home: Builder(builder: (context) {
        brightness = Theme.of(context).brightness;
        palette = context.palette;
        return const SizedBox.shrink();
      }),
    ),
  );
  return (brightness, palette);
}

void main() {
  testWidgets('light mode resolves the light brightness and palette',
      (tester) async {
    final (brightness, palette) = await _resolve(tester, ThemeMode.light);
    expect(brightness, Brightness.light);
    expect(palette, same(SudokuPalette.light));
  });

  testWidgets('dark mode resolves the dark brightness and palette',
      (tester) async {
    final (brightness, palette) = await _resolve(tester, ThemeMode.dark);
    expect(brightness, Brightness.dark);
    expect(palette, same(SudokuPalette.dark));
    // The dark surfaces genuinely differ from the light ones.
    expect(palette.surfaceWhite, isNot(SudokuPalette.light.surfaceWhite));
  });
}
