import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Builds the app's Material 3 theme — rounded, friendly, and colourful.
/// Uses Nunito (rounded, warm) for a playful feel while staying readable.
ThemeData buildTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: primaryIndigo,
    primary: primaryIndigo,
    secondary: accentCoral,
    tertiary: accentMint,
    error: errorRed,
    surface: surfaceWhite,
  );

  final textTheme = GoogleFonts.nunitoTextTheme().apply(
    bodyColor: textInk,
    displayColor: textInk,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: backgroundSoft,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: textInk,
    ),
    cardTheme: CardThemeData(
      color: surfaceWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryIndigo,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryIndigo,
        textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: textInk,
      contentTextStyle: GoogleFonts.nunito(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? primaryIndigo
            : Colors.white,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? primaryIndigoLight
            : textFaint,
      ),
    ),
  );
}
