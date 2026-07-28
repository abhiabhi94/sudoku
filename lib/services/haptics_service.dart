/// Haptic feedback that respects the user's vibration setting. Wraps the
/// built-in [HapticFeedback] behind an injectable [HapticEngine] so the gate
/// logic is unit-testable without a platform channel.
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';

/// Low-level haptic impulses. The real implementation drives [HapticFeedback].
abstract class HapticEngine {
  void selection();
  void light();
  void medium();
  void heavy();
  void vibrate();
}

class SystemHapticEngine implements HapticEngine {
  const SystemHapticEngine();

  @override
  void selection() => HapticFeedback.selectionClick();
  @override
  void light() => HapticFeedback.lightImpact();
  @override
  void medium() => HapticFeedback.mediumImpact();
  @override
  void heavy() => HapticFeedback.heavyImpact();
  @override
  void vibrate() => HapticFeedback.vibrate();
}

class HapticsService {
  HapticsService(
    this._enabled, {
    this._engine = const SystemHapticEngine(),
  });

  final bool Function() _enabled;
  final HapticEngine _engine;

  /// A light tick for cell selection / digit taps.
  void tap() => _run(_engine.selection);

  /// A soft confirmation for a correct placement.
  void correct() => _run(_engine.light);

  /// A firm buzz for a wrong placement.
  void wrong() => _run(_engine.heavy);

  /// A celebratory nudge on solving a level.
  void victory() => _run(_engine.medium);

  /// A long buzz when the "you're guessing" lockout triggers.
  void lockout() => _run(_engine.vibrate);

  void _run(void Function() impulse) {
    if (_enabled()) impulse();
  }
}

final hapticsProvider = Provider<HapticsService>(
  (ref) => HapticsService(() => ref.read(settingsProvider).hapticsOn),
);
