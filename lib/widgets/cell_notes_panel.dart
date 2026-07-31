import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/stroke.dart';
import '../ui/colors.dart';
import 'drawing_canvas.dart';

/// The magnified scribble surface for the selected cell, shown in the spare
/// vertical space below the grid. Drawing here is comfortable (finger doesn't
/// occlude a 38pt cell) and renders back as a thumbnail in the grid cell.
///
/// The parent owns the stroke list (persisted via the game provider), so undo
/// and clear are just list edits reported through [onChanged].
class CellNotesPanel extends StatelessWidget {
  const CellNotesPanel({
    super.key,
    required this.strokes,
    required this.onChanged,
  });

  final List<Stroke> strokes;
  final ValueChanged<List<Stroke>> onChanged;

  void _undo() {
    if (strokes.isEmpty) return;
    onChanged(strokes.sublist(0, strokes.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.edit_rounded, size: 15, color: context.palette.textMuted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l10n.notesScribbleHint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: context.palette.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
            _MiniAction(
              icon: Icons.undo_rounded,
              label: l10n.notesUndo,
              onTap: strokes.isEmpty ? null : _undo,
            ),
            const SizedBox(width: 2),
            _MiniAction(
              icon: Icons.delete_outline_rounded,
              label: l10n.notesClear,
              onTap: strokes.isEmpty ? null : () => onChanged(const <Stroke>[]),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: context.palette.notesPaper,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.palette.notesPaperBorder, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: DrawingCanvas(strokes: strokes, onChanged: onChanged),
          ),
        ),
      ],
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = enabled ? context.palette.textInk : context.palette.textFaint;
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
