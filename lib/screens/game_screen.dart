import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/hint_explainer.dart';
import '../l10n/app_localizations.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/riddle_rotation_provider.dart';
import '../providers/settings_provider.dart';
import '../ui/colors.dart';
import '../ui/layout.dart';
import '../utils/format.dart';
import '../widgets/cell_notes_panel.dart';
import '../widgets/hint_progress_bar.dart';
import '../widgets/mistakes_indicator.dart';
import '../widgets/number_pad.dart';
import '../widgets/riddle_dialog.dart';
import '../widgets/sudoku_grid.dart';

/// The gameplay screen: board, number pad, timer, mistakes and hints.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({
    super.key,
    required this.globalLevel,
    this.resume = false,
  });

  final int globalLevel;

  /// When true, resume the persisted game for this level instead of dealing a
  /// fresh puzzle (set by the home screen's "Continue" card).
  final bool resume;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  /// Bumped on every new mistake to replay the board-shake animation.
  int _shakeToken = 0;

  GameArgs get _args => (level: widget.globalLevel, resume: widget.resume);
  int get _level => (widget.globalLevel - 1) % 10 + 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Save the exact elapsed time the moment the app leaves the foreground.
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      ref.read(gameProvider(_args).notifier).persistNow();
    }
  }

  /// Opens the hint riddle; on a correct answer, reveals one cell.
  Future<void> _requestHint() async {
    final provider = gameProvider(_args);
    final state = ref.read(provider);
    if (state.phase != GamePhase.playing) return;
    final lang = ref.read(settingsProvider).languageCode;
    final source = ref.read(riddleSourceProvider);
    final earned = await showRiddleDialog(
      context,
      first: source.take(lang),
      nextRiddle: () => source.take(lang),
    );
    if (earned) ref.read(provider.notifier).applyHint();
  }

  /// Keyboard play for the web build: 1-9 place a digit (or light it up across
  /// the board, exactly as the number pad does), 0/backspace/delete erase, the
  /// arrows walk the selection and H opens the hint riddle. Anything with a
  /// modifier held is left alone so the browser keeps its own shortcuts.
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isControlPressed ||
        keyboard.isMetaPressed ||
        keyboard.isAltPressed) {
      return KeyEventResult.ignored;
    }
    final notifier = ref.read(gameProvider(_args).notifier);

    final digit = digitForKey(event);
    if (digit != null) {
      if (digit == 0) {
        notifier.erase();
      } else {
        notifier.inputDigit(digit);
      }
      return KeyEventResult.handled;
    }

    final step = _arrowKeys[event.logicalKey];
    if (step != null) {
      notifier.moveSelection(step.$1, step.$2);
      return KeyEventResult.handled;
    }

    if (_eraseKeys.contains(event.logicalKey)) {
      notifier.erase();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyH) {
      unawaited(_requestHint());
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Shake the board whenever the mistake count climbs.
    ref.listen(gameProvider(_args), (prev, next) {
      if (prev != null && next.mistakes > prev.mistakes) {
        setState(() => _shakeToken++);
      }
    });
    final state = ref.watch(gameProvider(_args));
    final notifier = ref.read(gameProvider(_args).notifier);

    return Focus(
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
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
                      onHint: _requestHint,
                      shakeToken: _shakeToken,
                    ),
                    if (state.isLockedOut)
                      _LockoutOverlay(state: state, l10n: l10n),
                    if (state.isSolved)
                      _VictoryOverlay(
                        state: state,
                        l10n: l10n,
                        onReplay: notifier.newPuzzle,
                        onNext: widget.globalLevel < totalLevels
                            ? () => Navigator.of(context).pushReplacement(
                                  MaterialPageRoute<void>(
                                    builder: (_) => GameScreen(
                                        globalLevel: widget.globalLevel + 1),
                                  ),
                                )
                            : null,
                        onHome: () => Navigator.of(context).pop(),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Board digits by key, for both the number row and the numeric keypad. 0 is
/// the erase key, matching the pad's backspace button.
final Map<LogicalKeyboardKey, int> _digitKeys = <LogicalKeyboardKey, int>{
  LogicalKeyboardKey.digit0: 0,
  LogicalKeyboardKey.digit1: 1,
  LogicalKeyboardKey.digit2: 2,
  LogicalKeyboardKey.digit3: 3,
  LogicalKeyboardKey.digit4: 4,
  LogicalKeyboardKey.digit5: 5,
  LogicalKeyboardKey.digit6: 6,
  LogicalKeyboardKey.digit7: 7,
  LogicalKeyboardKey.digit8: 8,
  LogicalKeyboardKey.digit9: 9,
  LogicalKeyboardKey.numpad0: 0,
  LogicalKeyboardKey.numpad1: 1,
  LogicalKeyboardKey.numpad2: 2,
  LogicalKeyboardKey.numpad3: 3,
  LogicalKeyboardKey.numpad4: 4,
  LogicalKeyboardKey.numpad5: 5,
  LogicalKeyboardKey.numpad6: 6,
  LogicalKeyboardKey.numpad7: 7,
  LogicalKeyboardKey.numpad8: 8,
  LogicalKeyboardKey.numpad9: 9,
};

/// Arrow keys as (row, column) steps for the selection.
final Map<LogicalKeyboardKey, (int, int)> _arrowKeys =
    <LogicalKeyboardKey, (int, int)>{
  LogicalKeyboardKey.arrowUp: (-1, 0),
  LogicalKeyboardKey.arrowDown: (1, 0),
  LogicalKeyboardKey.arrowLeft: (0, -1),
  LogicalKeyboardKey.arrowRight: (0, 1),
};

final Set<LogicalKeyboardKey> _eraseKeys = <LogicalKeyboardKey>{
  LogicalKeyboardKey.backspace,
  LogicalKeyboardKey.delete,
};

/// The digit a key press means (0 = erase), or null when it isn't one. Falls
/// back to the typed character so a layout that reaches digits some other way
/// still plays.
@visibleForTesting
int? digitForKey(KeyEvent event) {
  final mapped = _digitKeys[event.logicalKey];
  if (mapped != null) return mapped;
  final character = event.character;
  if (character == null || character.length != 1) return null;
  final parsed = int.tryParse(character);
  return parsed != null && parsed >= 0 && parsed <= 9 ? parsed : null;
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
          Text(message, style: TextStyle(color: context.palette.textMuted)),
        ],
      ),
    );
  }
}

/// Narrowest the play column goes on a squat window: below a phone's width the
/// number pad's labels and the notes panel's toolbar stop fitting, so the board
/// gives way (and the column scrolls) instead.
const double _minPlayWidth = 320;

/// How much of the available height the board may claim before the play column
/// stops widening. Everything else on the screen scales with the board's width,
/// and this share leaves them room on a laptop-shaped window without shrinking
/// the board on a phone.
const double _boardHeightShare = 0.62;

class _PlayView extends StatelessWidget {
  const _PlayView({
    required this.state,
    required this.notifier,
    required this.l10n,
    required this.onHint,
    required this.shakeToken,
  });

  final GameState state;
  final GameNotifier notifier;
  final AppLocalizations l10n;
  final VoidCallback onHint;
  final int shakeToken;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Phone-first layout in a desktop browser: cap the play column's
          // width so the square board can't swallow the window — stretched to a
          // laptop's full width it pushed the notes panel and the number pad
          // clean off the bottom, with no page scroll to chase them with. The
          // window's height gets a say too, so a short, wide window shrinks the
          // board instead of hiding half of it.
          final width = min(
            constraints.maxWidth,
            (constraints.maxHeight * _boardHeightShare)
                .clamp(_minPlayWidth, kMaxContentWidth)
                .toDouble(),
          );
          return Center(
            child: SizedBox(
              width: width,
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
                  // Board, hint card and notes share whatever is left between
                  // the header and the pad; the pad itself is never pushed off.
                  Expanded(
                    child: _BoardAndNotes(
                      state: state,
                      notifier: notifier,
                      l10n: l10n,
                      shakeToken: shakeToken,
                    ),
                  ),
                  NumberPad(
                    state: state,
                    onDigit: notifier.inputDigit,
                    onErase: notifier.erase,
                    onHint: onHint,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The board with the scribble panel below it, sized to the space the header
/// and the number pad left over.
///
/// The board shrinks to keep the notes panel on screen, and the pair scrolls
/// (rather than overflowing) if even that isn't enough — a squat browser window
/// has no page scrollbar to fall back on. Scrolling is only *enabled* when the
/// content really is taller than the space, so in the normal case a vertical
/// scribble stroke can't be mistaken for a scroll drag.
class _BoardAndNotes extends StatelessWidget {
  const _BoardAndNotes({
    required this.state,
    required this.notifier,
    required this.l10n,
    required this.shakeToken,
  });

  final GameState state;
  final GameNotifier notifier;
  final AppLocalizations l10n;
  final int shakeToken;

  /// Smallest the scribble panel may be squeezed to before the board stops
  /// giving way; below this, drawing in it stops being worth the space.
  static const double _notesMinHeight = 116;

  /// Smallest the board may shrink to before the column starts scrolling.
  static const double _boardMinSide = 220;

  /// Gap between the board and whatever follows it.
  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    final showNotes = _showNotesPanel(state);
    return LayoutBuilder(
      builder: (context, constraints) {
        final reserved = _gap + (showNotes ? _notesMinHeight : 0.0);
        final board = min(
          constraints.maxWidth,
          max(constraints.maxHeight - reserved, _boardMinSide),
        );
        // Spare height goes to the scribble panel, exactly as the old Expanded
        // did; the minimum only bites once the window is genuinely too short.
        final notesHeight =
            max(_notesMinHeight, constraints.maxHeight - board - _gap);
        final content = board + _gap + (showNotes ? notesHeight : 0.0);
        // The "Why here?" card's height depends on its text, so its presence
        // counts as "this may not fit" rather than being measured.
        final fits = state.lastHint == null && content <= constraints.maxHeight;
        return SingleChildScrollView(
          physics: fits ? const NeverScrollableScrollPhysics() : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ShakeOnChange(
                trigger: shakeToken,
                child: SizedBox(
                  width: board,
                  height: board,
                  child:
                      SudokuGrid(state: state, onCellTap: notifier.selectCell),
                ),
              ),
              const SizedBox(height: _gap),
              if (state.lastHint != null)
                _WhyCard(
                  text: _explainText(l10n, state.lastHint!),
                  onClose: notifier.dismissHint,
                ),
              // The magnified scribble panel takes over the spare vertical
              // space while an empty, editable cell is selected. A cell already
              // holding a value shows the number pad's job (place/erase), not
              // notes.
              if (showNotes)
                SizedBox(
                  height: notesHeight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 12),
                    child: CellNotesPanel(
                      strokes: state.notesFor(state.selectedIndex),
                      onChanged: (s) =>
                          notifier.setCellNotes(state.selectedIndex, s),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Plays a quick damped horizontal shake each time [trigger] changes. Uses an
/// implicit animation (no stray timers), so it's safe in widget tests.
class _ShakeOnChange extends StatelessWidget {
  const _ShakeOnChange({required this.trigger, required this.child});

  final int trigger;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(trigger),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, t, child) {
        final dx = trigger == 0 ? 0.0 : sin(t * pi * 5) * 9 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: child,
    );
  }
}

/// Whether to show the scribble panel: an empty, editable cell is selected
/// during normal play (a filled cell is for placing/erasing digits, not notes).
bool _showNotesPanel(GameState state) {
  final i = state.selectedIndex;
  return state.phase == GamePhase.playing &&
      i >= 0 &&
      state.isEditable(i) &&
      state.board[i] == 0;
}

/// A localized, board-aware explanation of the latest hint placement.
String _explainText(AppLocalizations l10n, HintExplanation e) {
  switch (e.kind) {
    case HintKind.nakedSingle:
      return l10n.hintWhyNaked(e.digit);
    case HintKind.hiddenSingle:
      return l10n.hintWhyHidden(_unitName(l10n, e.unit), e.digit);
    case HintKind.advanced:
      return l10n.hintWhyAdvanced(e.digit);
  }
}

String _unitName(AppLocalizations l10n, HintUnit unit) => switch (unit) {
      HintUnit.row => l10n.hintUnitRow,
      HintUnit.column => l10n.hintUnitColumn,
      HintUnit.box => l10n.hintUnitBox,
      HintUnit.none => '',
    };

/// The "Why here?" card shown after a hint, explaining the deduction.
class _WhyCard extends StatelessWidget {
  const _WhyCard({required this.text, required this.onClose});

  final String text;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      decoration: BoxDecoration(
        color: context.palette.cellExplain,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.cellExplainBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.hintWhyTitle,
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: context.palette.textInk)),
                const SizedBox(height: 2),
                Text(text,
                    style: TextStyle(
                        color: context.palette.textInk, height: 1.35, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 18),
            color: context.palette.textMuted,
            tooltip: l10n.commonClose,
            visualDensity: VisualDensity.compact,
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
        color: context.palette.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: context.palette.textMuted),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(
                  fontWeight: FontWeight.w800, color: context.palette.textInk)),
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
              color: context.palette.surfaceWhite,
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
                    style: TextStyle(color: context.palette.textMuted, height: 1.4)),
                const SizedBox(height: 16),
                Text(l10n.lockoutCountdown(seconds),
                    style: TextStyle(
                        color: context.palette.guessAmber, fontWeight: FontWeight.w800)),
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
                colors: [
                  context.palette.primaryIndigo,
                  context.palette.accentCoral,
                  context.palette.accentMint,
                  context.palette.accentSun,
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
              color: context.palette.surfaceWhite,
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
                    style: TextStyle(color: context.palette.textMuted)),
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
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w900, color: context.palette.primaryIndigo)),
        Text(label, style: TextStyle(color: context.palette.textMuted, fontSize: 12)),
      ],
    );
  }
}
