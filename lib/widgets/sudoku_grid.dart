import 'package:flutter/material.dart';

import '../engine/board.dart';
import '../models/game_state.dart';
import '../models/stroke.dart';
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
          color: context.palette.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.palette.gridLineBold, width: 2),
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
                          // Round the four corner cells so their fill follows the
                          // board's rounded border instead of being clipped to a
                          // square notch — keeps all four corners uniform.
                          cornerRadius: _cornerRadius(row, col),
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
                child: CustomPaint(
                  painter: _BoxLinesPainter(context.palette.gridLineBold),
                ),
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

  /// A rounded corner for the four board-corner cells (zero elsewhere) so their
  /// fill hugs the board's rounded border. 14 = outer radius (16) minus the 2px
  /// border, so the cell sits flush inside it.
  static BorderRadius _cornerRadius(int row, int col) {
    const r = Radius.circular(14);
    final last = boardSize - 1;
    return BorderRadius.only(
      topLeft: row == 0 && col == 0 ? r : Radius.zero,
      topRight: row == 0 && col == last ? r : Radius.zero,
      bottomLeft: row == last && col == 0 ? r : Radius.zero,
      bottomRight: row == last && col == last ? r : Radius.zero,
    );
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
    required this.cornerRadius,
    required this.onTap,
  });

  final int index;
  final GameState state;
  final bool isSelected;
  final bool isPeer;
  final bool sameValue;
  final bool isExplain;
  final BorderRadius cornerRadius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final kind = state.cellKind(index);
    final value = state.board.isNotEmpty ? state.board[index] : 0;
    final notes = state.notesFor(index);

    Color background;
    Color textColor;
    switch (kind) {
      case CellKind.given:
        background = palette.cellGiven;
        textColor = palette.textInk;
      case CellKind.userFilled:
        background = palette.surfaceWhite;
        textColor = palette.userDigit;
      case CellKind.hint:
        background = palette.cellHinted;
        textColor = palette.accentMint;
      case CellKind.error:
        background = palette.cellErrorBg;
        textColor = palette.errorRed;
      case CellKind.empty:
        background = palette.surfaceWhite;
        textColor = palette.textInk;
    }

    final isError = kind == CellKind.error;
    if (isSelected) {
      background = palette.cellSelected;
    } else if (isError) {
      background = palette.cellErrorBg;
    } else if (isExplain) {
      background = palette.cellExplain;
    } else if (sameValue && value != 0) {
      background = palette.cellPeer;
    } else if (isPeer && kind != CellKind.given) {
      background = palette.cellPeer.withValues(alpha: 0.5);
    }

    // A wrong entry gets a bold red outline so it's impossible to miss.
    final border = isError
        ? Border.all(color: palette.errorRed, width: 1.6)
        : isExplain
            ? Border.all(color: palette.cellExplainBorder, width: 1.2)
            : Border.all(color: palette.gridLineSoft, width: 0.5);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: background,
          border: border,
          borderRadius: cornerRadius,
        ),
        alignment: Alignment.center,
        // A placed value wins the cell; otherwise show the scribble thumbnail
        // (the notes are kept and reappear if the value is erased).
        child: value != 0
            ? Text(
                '$value',
                style: TextStyle(
                  fontSize: isError ? 23 : 22,
                  fontWeight: kind == CellKind.given || isError
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: textColor,
                ),
              )
            : notes.isEmpty
                ? const SizedBox.shrink()
                : CustomPaint(
                    painter: _NotesThumbnailPainter(notes, palette.notesInk),
                    child: const SizedBox.expand(),
                  ),
      ),
    );
  }
}

/// Paints a cell's scribble notes, scaled from their normalised (0..1) points
/// into the cell. A muted warm ink so notes read as their own layer, distinct
/// from placed digits.
class _NotesThumbnailPainter extends CustomPainter {
  _NotesThumbnailPainter(this.strokes, this.color);

  final List<Stroke> strokes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.points.length < 2) continue;
      final path = Path();
      final first = stroke.points.first;
      path.moveTo(first.dx * size.width, first.dy * size.height);
      for (var i = 1; i < stroke.points.length; i++) {
        final p = stroke.points[i];
        path.lineTo(p.dx * size.width, p.dy * size.height);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_NotesThumbnailPainter old) =>
      old.strokes != strokes || old.color != color;
}

class _BoxLinesPainter extends CustomPainter {
  _BoxLinesPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
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
  bool shouldRepaint(_BoxLinesPainter old) => old.color != color;
}
