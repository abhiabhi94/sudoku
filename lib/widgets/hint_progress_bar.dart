import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../ui/colors.dart';

/// Shows hints earned this level as a row of lit lightbulbs (the "progress
/// format" for hints), with an overflow badge past the shown maximum.
class HintProgressBar extends StatelessWidget {
  const HintProgressBar({
    super.key,
    required this.hintsUsed,
    this.shownMax = 4,
  });

  final int hintsUsed;
  final int shownMax;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final overflow = hintsUsed - shownMax;
    return Semantics(
      label: l10n.hintProgress(hintsUsed),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.palette.surfaceWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < shownMax; i++)
              Icon(
                Icons.lightbulb_rounded,
                size: 16,
                color: i < hintsUsed ? context.palette.accentSun : context.palette.gridLineSoft,
              ),
            if (overflow > 0)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text('+$overflow',
                    style: TextStyle(
                        color: context.palette.accentSun, fontWeight: FontWeight.w800, fontSize: 13)),
              ),
          ],
        ),
      ),
    );
  }
}
