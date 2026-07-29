import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/notes_provider.dart';
import '../ui/colors.dart';

/// A per-level free-text scratchpad. Opens as a bottom sheet, prefilled with the
/// saved note; Save persists it (an empty note is cleared).
Future<void> showNotesSheet(BuildContext context, {required int level}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: surfaceWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _NotesSheet(level: level),
  );
}

class _NotesSheet extends ConsumerStatefulWidget {
  const _NotesSheet({required this.level});

  final int level;

  @override
  ConsumerState<_NotesSheet> createState() => _NotesSheetState();
}

class _NotesSheetState extends ConsumerState<_NotesSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: ref.read(levelNoteProvider(widget.level)));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(levelNoteProvider(widget.level).notifier).save(_controller.text);
    Navigator.of(context).pop();
  }

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
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 4,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l10n.notesPlaceholder,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: backgroundSoft,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _save, child: Text(l10n.notesSave)),
          ),
        ],
      ),
    );
  }
}
