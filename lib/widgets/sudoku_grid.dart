import 'package:flutter/material.dart';

import '../engine/board.dart';
import '../models/game_state.dart';
import '../ui/colors.dart';

/// The 9x9 Sudoku board. Renders cell states, selection, peer/same-value
/// highlights, and bold 3x3 box separators.
class SudokuGrid extends StatelessWidget {
  const SudokuGrid({
    super.key,
    required this.state,
    required this.onCellTap,
  });

  final GameState state;
  final void Function(int index) onCellTap;

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedIndex;
    final selectedValue =
        selected >= 0 && state.board.isNotEmpty ? state.board[selected] : 0;
    // While a hint's "Why here?" card is up, softly highlight the cells that
    // justify the placement.
    final explainCells = state.lastHint?.justifiers.toSet() ?? const <int>{};

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gridLineBold, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              children: List<Widget>.generate(boardSize, (row) {
                return Expanded(
                  child: Row(
                    children: List<Widget>.generate(boardSize, (col) {
                      final index = indexOf(row, col);
                      return Expanded(
                        child: _Cell(
                          index: index,
                          state: state,
                          isSelected: index == selected,
                          isPeer: selected >= 0 && _isPeer(selected, index),
                          sameValue: selectedValue != 0 &&
                              state.board[index] == selectedValue,
                          isExplain: explainCells.contains(index),
                          onTap: () => onCellTap(index),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _BoxLinesPainter()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isPeer(int selected, int index) {
    if (selected == index) return false;
    return rowOf(selected) == rowOf(index) ||
        colOf(selected) == colOf(index) ||
        boxOf(selected) == boxOf(index);
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.index,
    required this.state,
    required this.isSelected,
    required this.isPeer,
    required this.sameValue,
    required this.isExplain,
    required this.onTap,
  });

  final int index;
  final GameState state;
  final bool isSelected;
  final bool isPeer;
  final bool sameValue;
  final bool isExplain;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kind = state.cellKind(index);
    final value = state.board.isNotEmpty ? state.board[index] : 0;

    Color background;
    Color textColor;
    switch (kind) {
      case CellKind.given:
        background = cellGiven;
        textColor = textInk;
      case CellKind.userFilled:
        background = surfaceWhite;
        textColor = primaryIndigo;
      case CellKind.hint:
        background = cellHinted;
        textColor = accentMint;
      case CellKind.error:
        background = cellErrorBg;
        textColor = errorRed;
      case CellKind.empty:
        background = surfaceWhite;
        textColor = textInk;
    }

    final isError = kind == CellKind.error;
    if (isSelected) {
      background = cellSelected;
    } else if (isError) {
      background = cellErrorBg;
    } else if (isExplain) {
      background = cellExplain;
    } else if (sameValue && value != 0) {
      background = cellPeer;
    } else if (isPeer && kind != CellKind.given) {
      background = cellPeer.withValues(alpha: 0.5);
    }

    // A wrong entry gets a bold red outline so it's impossible to miss.
    final border = isError
        ? Border.all(color: errorRed, width: 1.6)
        : isExplain
            ? Border.all(color: cellExplainBorder, width: 1.2)
            : Border.all(color: gridLineSoft, width: 0.5);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(color: background, border: border),
        alignment: Alignment.center,
        child: value == 0
            ? const SizedBox.shrink()
            : Text(
                '$value',
                style: TextStyle(
                  fontSize: isError ? 23 : 22,
                  fontWeight: kind == CellKind.given || isError
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}

class _BoxLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridLineBold
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final cell = size.width / boardSize;
    for (var i = 1; i < boardSize; i++) {
      if (i % boxSize != 0) continue;
      final d = cell * i;
      canvas.drawLine(Offset(d, 0), Offset(d, size.height), paint);
      canvas.drawLine(Offset(0, d), Offset(size.width, d), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
