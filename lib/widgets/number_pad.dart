import 'package:flutter/material.dart';

import '../engine/board.dart';
import '../l10n/app_localizations.dart';
import '../models/game_state.dart';
import '../ui/colors.dart';

/// The 1–9 input pad plus erase and hint actions. Digits that are fully placed
/// are dimmed.
class NumberPad extends StatelessWidget {
  const NumberPad({
    super.key,
    required this.state,
    required this.onDigit,
    required this.onErase,
    required this.onHint,
  });

  final GameState state;
  final void Function(int digit) onDigit;
  final VoidCallback onErase;
  final VoidCallback onHint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            for (var d = 1; d <= boardSize; d++)
              Expanded(
                child: _DigitButton(
                  digit: d,
                  remaining: state.remainingForDigit(d),
                  onTap: () => onDigit(d),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.backspace_rounded,
                label: l10n.gameErase,
                color: context.palette.textMuted,
                onTap: onErase,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.lightbulb_rounded,
                label: l10n.gameHint,
                color: context.palette.accentSun,
                onTap: onHint,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DigitButton extends StatelessWidget {
  const _DigitButton({
    required this.digit,
    required this.remaining,
    required this.onTap,
  });

  final int digit;
  final int remaining;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = remaining <= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: AspectRatio(
        aspectRatio: 0.82,
        child: Material(
          color: done ? context.palette.backgroundSoft : context.palette.surfaceWhite,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: done ? null : onTap,
            child: Center(
              child: Text(
                '$digit',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: done ? context.palette.textFaint : context.palette.userDigit,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.surfaceWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(color: context.palette.textInk, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
