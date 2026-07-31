import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../ui/colors.dart';

/// Shows the mistake count as three dots that fill up, plus an overflow badge
/// once the free-mistake limit is passed.
class MistakesIndicator extends StatelessWidget {
  const MistakesIndicator({super.key, required this.mistakes});

  final int mistakes;

  @override
  Widget build(BuildContext context) {
    final overflow = mistakes - maxFreeMistakes;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < maxFreeMistakes; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < mistakes ? context.palette.errorRed : context.palette.gridLineSoft,
              ),
            ),
          ),
        if (overflow > 0)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              '+$overflow',
              style: TextStyle(
                color: context.palette.errorRed,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}
