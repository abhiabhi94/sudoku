import 'package:flutter/material.dart';

/// Playful, modern colour tokens. One cheerful light palette with strong,
/// friendly accents and soft surfaces. Centralised here (mirrors ShabdLok's
/// ui/colors.dart convention) so the whole app stays visually consistent.

// Surfaces
const Color backgroundSoft = Color(0xFFF4F3FF); // soft lavender white
const Color surfaceWhite = Color(0xFFFFFFFF);
const Color cardTint = Color(0xFFFBFAFF);

// Brand accents
const Color primaryIndigo = Color(0xFF6C5CE7);
const Color primaryIndigoDark = Color(0xFF5647C4);
const Color primaryIndigoLight = Color(0xFFA29BFE);
const Color accentCoral = Color(0xFFFF6B6B);
const Color accentSun = Color(0xFFFFC53D);
const Color accentMint = Color(0xFF32D296);

// Semantic
const Color successGreen = Color(0xFF22C55E);
const Color errorRed = Color(0xFFEF4444);
const Color guessAmber = Color(0xFFF59E0B); // the "you're guessing" mood

// Text
const Color textInk = Color(0xFF2D2A4A);
const Color textMuted = Color(0xFF6E6A8F);
const Color textFaint = Color(0xFFA6A2C4);

// Sudoku board
const Color gridLineSoft = Color(0xFFDAD7F2);
const Color gridLineBold = Color(0xFF6C5CE7);
const Color cellGiven = Color(0xFFEDEBFF);
const Color cellSelected = Color(0xFFCFC8FF);
const Color cellPeer = Color(0xFFF0EEFF);
const Color cellHinted = Color(0xFFD5F6E9);
const Color cellHintedBorder = Color(0xFF32D296);
const Color cellErrorBg = Color(0xFFFFE2E2);
// Cells that justify a hint ("Why here?") — a soft sunlit tint.
const Color cellExplain = Color(0xFFFFF3D6);
const Color cellExplainBorder = Color(0xFFFFD873);

// Notes scratchpad — a warm "sticky note" paper tint, deliberately distinct
// from the app's lavender/indigo palette so notes read as their own surface.
const Color notesPaper = Color(0xFFFFF8E1);
const Color notesPaperBorder = Color(0xFFF3E1A3);
const Color notesInk = Color(0xFF4C4630); // strokes/text on the paper

/// Per-tier signature colours (Beginner, Advanced, Expert).
const List<Color> tierColors = <Color>[
  accentMint,
  primaryIndigo,
  accentCoral,
];
