import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/riddle.dart';
import '../ui/colors.dart';

/// Shows a riddle the player must solve to earn a hint. Resolves to true if the
/// riddle was answered correctly, false if cancelled.
Future<bool> showRiddleDialog(
  BuildContext context, {
  required List<Riddle> riddles,
  required int startIndex,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => _RiddleDialog(riddles: riddles, startIndex: startIndex),
  );
  return result ?? false;
}

class _RiddleDialog extends StatefulWidget {
  const _RiddleDialog({required this.riddles, required this.startIndex});

  final List<Riddle> riddles;
  final int startIndex;

  @override
  State<_RiddleDialog> createState() => _RiddleDialogState();
}

class _RiddleDialogState extends State<_RiddleDialog> {
  late int _index = widget.startIndex % widget.riddles.length;
  final _controller = TextEditingController();
  bool _wrong = false;
  bool _showClue = false;

  Riddle get _riddle => widget.riddles[_index];

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

  /// Manually swap to a different riddle.
  void _newRiddle() {
    setState(() {
      _index = (_index + 1) % widget.riddles.length;
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
              style: const TextStyle(color: textMuted, fontSize: 13)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(_riddle.prompt,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, height: 1.4, color: textInk)),
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
                color: cellHinted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('🔍 ${_riddle.clue}',
                  style: const TextStyle(color: textInk, height: 1.35)),
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
