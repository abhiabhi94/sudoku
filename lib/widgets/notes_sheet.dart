import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/level_note.dart';
import '../providers/notes_provider.dart';
import '../ui/colors.dart';
import 'drawing_canvas.dart';

/// A per-level scratchpad. Opens as a bottom sheet on a warm "paper" surface,
/// prefilled with the saved note. The player can type text or scribble; Save
/// persists both (an empty note is cleared).
Future<void> showNotesSheet(BuildContext context, {required int level}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    // Drawing strokes (especially downward) must not dismiss the sheet; close
    // via Save or by tapping outside instead.
    enableDrag: false,
    backgroundColor: notesPaper,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _NotesSheet(level: level),
  );
}

enum _NoteMode { text, draw }

class _NotesSheet extends ConsumerStatefulWidget {
  const _NotesSheet({required this.level});

  final int level;

  @override
  ConsumerState<_NotesSheet> createState() => _NotesSheetState();
}

class _NotesSheetState extends ConsumerState<_NotesSheet> {
  late final LevelNote _initial = ref.read(levelNoteProvider(widget.level));
  late final TextEditingController _controller =
      TextEditingController(text: _initial.text);
  late List<Stroke> _strokes = List.of(_initial.strokes);
  _NoteMode _mode = _NoteMode.text;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(levelNoteProvider(widget.level).notifier).save(
          LevelNote(text: _controller.text, strokes: _strokes),
        );
    Navigator.of(context).pop();
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes = _strokes.sublist(0, _strokes.length - 1));
  }

  void _clear() => setState(() => _strokes = <Stroke>[]);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localLevel = (widget.level - 1) % 10 + 1;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📝', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Text(
                '${l10n.notesTitle} · ${l10n.levelNumber(localLevel)}',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: textInk),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedButton<_NoteMode>(
            segments: [
              ButtonSegment(
                value: _NoteMode.text,
                icon: const Icon(Icons.notes_rounded),
                label: Text(l10n.notesTabText),
              ),
              ButtonSegment(
                value: _NoteMode.draw,
                icon: const Icon(Icons.draw_rounded),
                label: Text(l10n.notesTabDraw),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() => _mode = s.first),
          ),
          const SizedBox(height: 16),
          if (_mode == _NoteMode.text) _buildText(l10n) else _buildDraw(l10n),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _save, child: Text(l10n.notesSave)),
          ),
        ],
      ),
    );
  }

  Widget _buildText(AppLocalizations l10n) {
    return TextField(
      controller: _controller,
      autofocus: true,
      minLines: 4,
      maxLines: 8,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: l10n.notesPlaceholder,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: surfaceWhite,
      ),
    );
  }

  Widget _buildDraw(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 260,
          decoration: BoxDecoration(
            color: surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: notesPaperBorder, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: DrawingCanvas(
            strokes: _strokes,
            onChanged: (s) => setState(() => _strokes = s),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: _strokes.isEmpty ? null : _undo,
              icon: const Icon(Icons.undo_rounded, size: 18),
              label: Text(l10n.notesUndo),
            ),
            const SizedBox(width: 4),
            TextButton.icon(
              onPressed: _strokes.isEmpty ? null : _clear,
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: Text(l10n.notesClear),
            ),
          ],
        ),
      ],
    );
  }
}
