import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/riddle_bank.dart';
import '../l10n/app_localizations.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/settings_provider.dart';
import '../ui/colors.dart';
import '../utils/format.dart';
import '../widgets/hint_progress_bar.dart';
import '../widgets/mistakes_indicator.dart';
import '../widgets/number_pad.dart';
import '../widgets/riddle_dialog.dart';
import '../widgets/sudoku_grid.dart';

/// The gameplay screen: board, number pad, timer, mistakes and hints.
class GameScreen extends ConsumerWidget {
  const GameScreen({super.key, required this.globalLevel});

  final int globalLevel;

  int get _level => (globalLevel - 1) % 10 + 1;

  /// Opens the hint riddle; on a correct answer, reveals one cell.
  Future<void> _requestHint(BuildContext context, WidgetRef ref) async {
    final provider = gameProvider(globalLevel);
    final state = ref.read(provider);
    if (state.phase != GamePhase.playing) return;
    final riddles = riddlesFor(ref.read(settingsProvider).languageCode);
    final earned = await showRiddleDialog(
      context,
      riddles: riddles,
      startIndex: state.hintsUsed,
    );
    if (earned) ref.read(provider.notifier).applyHint();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(gameProvider(globalLevel));
    final notifier = ref.read(gameProvider(globalLevel).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.levelNumber(_level)),
        actions: [
          if (!state.isLoading)
            IconButton(
              tooltip: l10n.gameNewPuzzle,
              onPressed: notifier.newPuzzle,
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? _LoadingView(message: l10n.gameDealing)
            : Stack(
                children: [
                  _PlayView(
                    state: state,
                    notifier: notifier,
                    l10n: l10n,
                    onHint: () => _requestHint(context, ref),
                  ),
                  if (state.isLockedOut)
                    _LockoutOverlay(state: state, l10n: l10n),
                  if (state.isSolved)
                    _VictoryOverlay(
                      state: state,
                      l10n: l10n,
                      onReplay: notifier.newPuzzle,
                      onNext: globalLevel < totalLevels
                          ? () => Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      GameScreen(globalLevel: globalLevel + 1),
                                ),
                              )
                          : null,
                      onHome: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🧩', style: TextStyle(fontSize: 64))
              .animate(onPlay: (c) => c.repeat())
              .rotate(duration: 1400.ms),
          const SizedBox(height: 20),
          Text(message, style: const TextStyle(color: textMuted)),
        ],
      ),
    );
  }
}

class _PlayView extends StatelessWidget {
  const _PlayView({
    required this.state,
    required this.notifier,
    required this.l10n,
    required this.onHint,
  });

  final GameState state;
  final GameNotifier notifier;
  final AppLocalizations l10n;
  final VoidCallback onHint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Pill(
                icon: Icons.timer_outlined,
                text: formatDurationMs(state.elapsedMs),
              ),
              if (state.hintsUsed > 0)
                HintProgressBar(hintsUsed: state.hintsUsed),
              MistakesIndicator(mistakes: state.mistakes),
            ],
          ),
          const SizedBox(height: 16),
          SudokuGrid(state: state, onCellTap: notifier.selectCell),
          const Spacer(),
          NumberPad(
            state: state,
            onDigit: notifier.inputDigit,
            onErase: notifier.erase,
            onHint: onHint,
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: textMuted),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: textInk)),
        ],
      ),
    );
  }
}

class _LockoutOverlay extends StatelessWidget {
  const _LockoutOverlay({required this.state, required this.l10n});
  final GameState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final seconds = (state.lockoutRemainingMs / 1000).ceil();
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: surfaceWhite,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('👀', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text(l10n.lockoutTitle,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(l10n.lockoutBody,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: textMuted, height: 1.4)),
                const SizedBox(height: 16),
                Text(l10n.lockoutCountdown(seconds),
                    style: const TextStyle(
                        color: guessAmber, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VictoryOverlay extends StatefulWidget {
  const _VictoryOverlay({
    required this.state,
    required this.l10n,
    required this.onReplay,
    required this.onNext,
    required this.onHome,
  });

  final GameState state;
  final AppLocalizations l10n;
  final VoidCallback onReplay;
  final VoidCallback? onNext;
  final VoidCallback onHome;

  @override
  State<_VictoryOverlay> createState() => _VictoryOverlayState();
}

class _VictoryOverlayState extends State<_VictoryOverlay> {
  final _confetti = ConfettiController(duration: const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final l10n = widget.l10n;
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black54,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 24,
                gravity: 0.25,
                colors: const [
                  primaryIndigo,
                  accentCoral,
                  accentMint,
                  accentSun,
                ],
                createParticlePath: (size) => Path()
                  ..addOval(Rect.fromCircle(
                      center: Offset.zero, radius: 4 + Random(size.hashCode).nextInt(3).toDouble())),
              ),
            ),
            Center(
          child: Container(
            margin: const EdgeInsets.all(28),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: surfaceWhite,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 8),
                Text(l10n.victoryTitle,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w900)),
                Text(l10n.victoryCheer,
                    style: const TextStyle(color: textMuted)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat(label: l10n.victoryTime, value: formatDurationMs(state.elapsedMs)),
                    _Stat(label: l10n.victoryMistakes, value: '${state.mistakes}'),
                    _Stat(label: l10n.victoryHints, value: '${state.hintsUsed}'),
                  ],
                ),
                const SizedBox(height: 24),
                if (widget.onNext != null)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: widget.onNext,
                      child: Text(l10n.victoryNext),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                          onPressed: widget.onReplay,
                          child: Text(l10n.victoryReplay)),
                    ),
                    Expanded(
                      child: TextButton(
                          onPressed: widget.onHome,
                          child: Text(l10n.victoryHome)),
                    ),
                  ],
                ),
              ],
            ),
          )
                  .animate()
                  .scale(
                      begin: const Offset(0.85, 0.85),
                      curve: Curves.easeOutBack)
                  .fadeIn(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w900, color: primaryIndigo)),
        Text(label, style: const TextStyle(color: textMuted, fontSize: 12)),
      ],
    );
  }
}
