import 'package:flutter/material.dart';

import 'colors.dart';

/// The app's typeface, bundled in `assets/fonts/` and declared in
/// pubspec.yaml. Google Sans Flex: clean, geometric, and available in every
/// weight the UI uses (300-900) without any runtime fetch.
const String kAppFontFamily = 'Google Sans Flex';

/// The app's light theme (the default look).
ThemeData buildLightTheme() =>
    _buildTheme(SudokuPalette.light, Brightness.light);

/// The app's dark theme — same rounded, friendly shapes on deep indigo surfaces.
ThemeData buildDarkTheme() => _buildTheme(SudokuPalette.dark, Brightness.dark);

/// Builds the app's Material 3 theme — rounded, friendly, and colourful.
/// Uses Google Sans Flex ([kAppFontFamily]) for a clean, modern feel.
/// [p] supplies the brightness-specific colour tokens.
ThemeData _buildTheme(SudokuPalette p, Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: p.primaryIndigo,
    brightness: brightness,
    primary: p.primaryIndigo,
    secondary: p.accentCoral,
    tertiary: p.accentMint,
    error: p.errorRed,
    surface: p.surfaceWhite,
  );

  final textTheme = ThemeData(
    brightness: brightness,
    useMaterial3: true,
    fontFamily: kAppFontFamily,
  ).textTheme.apply(bodyColor: p.textInk, displayColor: p.textInk);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: p.backgroundSoft,
    textTheme: textTheme,
    fontFamily: kAppFontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: p.textInk,
    ),
    cardTheme: CardThemeData(
      color: p.surfaceWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.primaryIndigo,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: kAppFontFamily,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.primaryIndigo,
        textStyle: const TextStyle(
          fontFamily: kAppFontFamily,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.textInk,
      contentTextStyle: TextStyle(
        fontFamily: kAppFontFamily,
        color: p.surfaceWhite,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? p.primaryIndigo
            : p.surfaceWhite,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? p.primaryIndigoLight
            : p.textFaint,
      ),
    ),
  );
}
