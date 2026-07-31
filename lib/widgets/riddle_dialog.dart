import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/riddle.dart';
import '../ui/colors.dart';

/// Shows a riddle the player must solve to earn a hint. Resolves to true if the
/// riddle was answered correctly, false if cancelled.
///
/// [first] is the riddle shown initially; [nextRiddle] supplies a fresh one each
/// time the player asks for a new riddle. Both come from the caller's rotation
/// so every riddle displayed is consumed from the non-repeating deck.
Future<bool> showRiddleDialog(
  BuildContext context, {
  required Riddle first,
  required Riddle Function() nextRiddle,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => _RiddleDialog(first: first, nextRiddle: nextRiddle),
  );
  return result ?? false;
}

class _RiddleDialog extends StatefulWidget {
  const _RiddleDialog({required this.first, required this.nextRiddle});

  final Riddle first;
  final Riddle Function() nextRiddle;

  @override
  State<_RiddleDialog> createState() => _RiddleDialogState();
}

class _RiddleDialogState extends State<_RiddleDialog> {
  late Riddle _riddle = widget.first;
  final _controller = TextEditingController();
  bool _wrong = false;
  bool _showClue = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Submit the current answer. Wrong answers can be retried without limit.
  void _check() {
    if (_riddle.accepts(_controller.text)) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _wrong = true);
    }
  }

  /// Swap to the next riddle from the rotation.
  void _newRiddle() {
    setState(() {
      _riddle = widget.nextRiddle();
      _controller.clear();
      _wrong = false;
      _showClue = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      title: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.close_rounded),
            tooltip: l10n.commonClose,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          const Text('💡', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Expanded(child: Text(l10n.hintTitle)),
        ],
      ),
      // Scrollable so the clue + keyboard can't overflow on short screens.
      content: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.hintIntro,
              style: TextStyle(color: context.palette.textMuted, fontSize: 13)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.palette.backgroundSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(_riddle.prompt,
                style: TextStyle(
                    fontWeight: FontWeight.w700, height: 1.4, color: context.palette.textInk)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _check(),
            decoration: InputDecoration(
              labelText: l10n.hintAnswerLabel,
              errorText: _wrong ? l10n.hintWrong : null,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 4),
          if (_showClue)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.palette.cellHinted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('🔍 ${_riddle.clue}',
                  style: TextStyle(color: context.palette.textInk, height: 1.35)),
            )
          else
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => setState(() => _showClue = true),
                icon: const Icon(Icons.help_outline_rounded, size: 18),
                label: Text(l10n.hintShowClue),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
        ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _newRiddle,
          child: Text(l10n.hintNewRiddle),
        ),
        FilledButton(onPressed: _check, child: Text(l10n.hintCheck)),
      ],
    );
  }
}
