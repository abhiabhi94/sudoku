import 'package:flutter/material.dart';

/// Playful, modern colour tokens. Two palettes — a cheerful light one and a
/// deep indigo dark one — share the same field names so widgets read them
/// through [SudokuPalette] / `context.palette` without caring which is active.
/// Centralised here (mirrors ShabdLok's ui/colors.dart convention) so the whole
/// app stays visually consistent.
///
/// The raw `_l*` (light) and `_d*` (dark) values are private; widgets never
/// touch them directly — they read the theme-aware fields on [SudokuPalette].

// ---------------------------------------------------------------------------
// Light palette values (the app's original, default look).
// ---------------------------------------------------------------------------

// Surfaces
const Color _lBackgroundSoft = Color(0xFFF4F3FF); // soft lavender white
const Color _lSurfaceWhite = Color(0xFFFFFFFF);
const Color _lCardTint = Color(0xFFFBFAFF);

// Brand accents
const Color _lPrimaryIndigo = Color(0xFF6C5CE7);
const Color _lPrimaryIndigoDark = Color(0xFF5647C4);
const Color _lPrimaryIndigoLight = Color(0xFFA29BFE);
// Colour of a digit the player entered (and the number pad). On white it can be
// the brand indigo; on dark it needs to be much lighter to stay legible.
const Color _lUserDigit = Color(0xFF6C5CE7);
const Color _lAccentCoral = Color(0xFFFF6B6B);
const Color _lAccentSun = Color(0xFFFFC53D);
const Color _lAccentMint = Color(0xFF32D296);

// Semantic
const Color _lSuccessGreen = Color(0xFF22C55E);
const Color _lErrorRed = Color(0xFFEF4444);
const Color _lGuessAmber = Color(0xFFF59E0B); // the "you're guessing" mood

// Text
const Color _lTextInk = Color(0xFF2D2A4A);
const Color _lTextMuted = Color(0xFF6E6A8F);
const Color _lTextFaint = Color(0xFFA6A2C4);

// Sudoku board
const Color _lGridLineSoft = Color(0xFFDAD7F2);
const Color _lGridLineBold = Color(0xFF6C5CE7);
const Color _lCellGiven = Color(0xFFEDEBFF);
const Color _lCellSelected = Color(0xFFCFC8FF);
const Color _lCellPeer = Color(0xFFF0EEFF);
// Every cell holding the same digit as the active one. Deliberately stronger
// than the peer wash and ringed, so "where are all my 6s?" reads at a glance
// instead of blending into the row/column/box tint.
const Color _lCellSameValue = Color(0xFFE4E0FF);
const Color _lCellSameValueBorder = Color(0xFF9C90F5);
const Color _lCellHinted = Color(0xFFD5F6E9);
const Color _lCellHintedBorder = Color(0xFF32D296);
const Color _lCellErrorBg = Color(0xFFFFE2E2);
// Cells that justify a hint ("Why here?") — a soft sunlit tint.
const Color _lCellExplain = Color(0xFFFFF3D6);
const Color _lCellExplainBorder = Color(0xFFFFD873);

// Notes scratchpad — a warm "sticky note" paper tint, deliberately distinct
// from the app's lavender/indigo palette so notes read as their own surface.
const Color _lNotesPaper = Color(0xFFFFF8E1);
const Color _lNotesPaperBorder = Color(0xFFF3E1A3);
const Color _lNotesInk = Color(0xFF4C4630); // strokes/text on the paper

const List<Color> _lTierColors = <Color>[
  _lAccentMint,
  _lPrimaryIndigo,
  _lAccentCoral,
  _lAccentSun,
];

// ---------------------------------------------------------------------------
// Dark palette values. Deep indigo-charcoal surfaces, lightened accents/text
// so contrast holds up on a dark background.
// ---------------------------------------------------------------------------

// Surfaces
const Color _dBackgroundSoft = Color(0xFF131120); // deep indigo charcoal
const Color _dSurfaceWhite = Color(0xFF201D30); // elevated cards / cells
const Color _dCardTint = Color(0xFF262238);

// Brand accents (a touch brighter so they pop on dark)
const Color _dPrimaryIndigo = Color(0xFF7A6BF2);
const Color _dPrimaryIndigoDark = Color(0xFF5647C4);
const Color _dPrimaryIndigoLight = Color(0xFFB7AEFF);
// User-entered digits: a bright lavender so they read clearly on dark cells
// while still reading as "indigo / editable" against the near-white givens.
const Color _dUserDigit = Color(0xFFBEB4FF);
const Color _dAccentCoral = Color(0xFFFF7B7B);
const Color _dAccentSun = Color(0xFFFFCE52);
const Color _dAccentMint = Color(0xFF3FE0A6);

// Semantic
const Color _dSuccessGreen = Color(0xFF34D058);
const Color _dErrorRed = Color(0xFFFF6B6B);
const Color _dGuessAmber = Color(0xFFFBBF3F);

// Text
const Color _dTextInk = Color(0xFFEAE7F7);
const Color _dTextMuted = Color(0xFFA9A4CC);
const Color _dTextFaint = Color(0xFF6E6A8F);

// Sudoku board
const Color _dGridLineSoft = Color(0xFF322E4A);
const Color _dGridLineBold = Color(0xFF7A6BF2);
const Color _dCellGiven = Color(0xFF332E54); // lighter than empty cells so
// the pre-filled givens read as a distinct band from the empty squares.
const Color _dCellSelected = Color(0xFF463C7A);
const Color _dCellPeer = Color(0xFF2C2942);
// Sits between the givens band and the selected cell so it stays distinct from
// both; the ring carries most of the signal on dark.
const Color _dCellSameValue = Color(0xFF3A3560);
const Color _dCellSameValueBorder = Color(0xFF8A7BF5);
const Color _dCellHinted = Color(0xFF163A2E);
const Color _dCellHintedBorder = Color(0xFF2FBE86);
const Color _dCellErrorBg = Color(0xFF3E1F27);
const Color _dCellExplain = Color(0xFF3A331C);
const Color _dCellExplainBorder = Color(0xFF9A8434);

// Notes scratchpad (dark warm paper with light warm ink)
const Color _dNotesPaper = Color(0xFF322D1C);
const Color _dNotesPaperBorder = Color(0xFF5A5030);
const Color _dNotesInk = Color(0xFFE7D9A0);

const List<Color> _dTierColors = <Color>[
  _dAccentMint,
  _dPrimaryIndigo,
  _dAccentCoral,
  _dAccentSun,
];

// ---------------------------------------------------------------------------
// Palette — the theme-aware bundle of every board/semantic colour token. Field
// names match the design tokens, so a widget's `token` becomes
// `context.palette.token`.
// ---------------------------------------------------------------------------

@immutable
class SudokuPalette {
  const SudokuPalette({
    required this.backgroundSoft,
    required this.surfaceWhite,
    required this.cardTint,
    required this.primaryIndigo,
    required this.primaryIndigoDark,
    required this.primaryIndigoLight,
    required this.userDigit,
    required this.accentCoral,
    required this.accentSun,
    required this.accentMint,
    required this.successGreen,
    required this.errorRed,
    required this.guessAmber,
    required this.textInk,
    required this.textMuted,
    required this.textFaint,
    required this.gridLineSoft,
    required this.gridLineBold,
    required this.cellGiven,
    required this.cellSelected,
    required this.cellPeer,
    required this.cellSameValue,
    required this.cellSameValueBorder,
    required this.cellHinted,
    required this.cellHintedBorder,
    required this.cellErrorBg,
    required this.cellExplain,
    required this.cellExplainBorder,
    required this.notesPaper,
    required this.notesPaperBorder,
    required this.notesInk,
    required this.tierColors,
  });

  final Color backgroundSoft;
  final Color surfaceWhite;
  final Color cardTint;
  final Color primaryIndigo;
  final Color primaryIndigoDark;
  final Color primaryIndigoLight;
  final Color userDigit;
  final Color accentCoral;
  final Color accentSun;
  final Color accentMint;
  final Color successGreen;
  final Color errorRed;
  final Color guessAmber;
  final Color textInk;
  final Color textMuted;
  final Color textFaint;
  final Color gridLineSoft;
  final Color gridLineBold;
  final Color cellGiven;
  final Color cellSelected;
  final Color cellPeer;
  final Color cellSameValue;
  final Color cellSameValueBorder;
  final Color cellHinted;
  final Color cellHintedBorder;
  final Color cellErrorBg;
  final Color cellExplain;
  final Color cellExplainBorder;
  final Color notesPaper;
  final Color notesPaperBorder;
  final Color notesInk;
  final List<Color> tierColors;

  static const SudokuPalette light = SudokuPalette(
    backgroundSoft: _lBackgroundSoft,
    surfaceWhite: _lSurfaceWhite,
    cardTint: _lCardTint,
    primaryIndigo: _lPrimaryIndigo,
    primaryIndigoDark: _lPrimaryIndigoDark,
    primaryIndigoLight: _lPrimaryIndigoLight,
    userDigit: _lUserDigit,
    accentCoral: _lAccentCoral,
    accentSun: _lAccentSun,
    accentMint: _lAccentMint,
    successGreen: _lSuccessGreen,
    errorRed: _lErrorRed,
    guessAmber: _lGuessAmber,
    textInk: _lTextInk,
    textMuted: _lTextMuted,
    textFaint: _lTextFaint,
    gridLineSoft: _lGridLineSoft,
    gridLineBold: _lGridLineBold,
    cellGiven: _lCellGiven,
    cellSelected: _lCellSelected,
    cellPeer: _lCellPeer,
    cellSameValue: _lCellSameValue,
    cellSameValueBorder: _lCellSameValueBorder,
    cellHinted: _lCellHinted,
    cellHintedBorder: _lCellHintedBorder,
    cellErrorBg: _lCellErrorBg,
    cellExplain: _lCellExplain,
    cellExplainBorder: _lCellExplainBorder,
    notesPaper: _lNotesPaper,
    notesPaperBorder: _lNotesPaperBorder,
    notesInk: _lNotesInk,
    tierColors: _lTierColors,
  );

  static const SudokuPalette dark = SudokuPalette(
    backgroundSoft: _dBackgroundSoft,
    surfaceWhite: _dSurfaceWhite,
    cardTint: _dCardTint,
    primaryIndigo: _dPrimaryIndigo,
    primaryIndigoDark: _dPrimaryIndigoDark,
    primaryIndigoLight: _dPrimaryIndigoLight,
    userDigit: _dUserDigit,
    accentCoral: _dAccentCoral,
    accentSun: _dAccentSun,
    accentMint: _dAccentMint,
    successGreen: _dSuccessGreen,
    errorRed: _dErrorRed,
    guessAmber: _dGuessAmber,
    textInk: _dTextInk,
    textMuted: _dTextMuted,
    textFaint: _dTextFaint,
    gridLineSoft: _dGridLineSoft,
    gridLineBold: _dGridLineBold,
    cellGiven: _dCellGiven,
    cellSelected: _dCellSelected,
    cellPeer: _dCellPeer,
    cellSameValue: _dCellSameValue,
    cellSameValueBorder: _dCellSameValueBorder,
    cellHinted: _dCellHinted,
    cellHintedBorder: _dCellHintedBorder,
    cellErrorBg: _dCellErrorBg,
    cellExplain: _dCellExplain,
    cellExplainBorder: _dCellExplainBorder,
    notesPaper: _dNotesPaper,
    notesPaperBorder: _dNotesPaperBorder,
    notesInk: _dNotesInk,
    tierColors: _dTierColors,
  );
}

/// Reads the active [SudokuPalette] for the current theme brightness.
extension SudokuPaletteX on BuildContext {
  SudokuPalette get palette => Theme.of(this).brightness == Brightness.dark
      ? SudokuPalette.dark
      : SudokuPalette.light;
}
