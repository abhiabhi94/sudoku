/// Supplies hint riddles in a random, non-repeating order that survives app
/// restarts. Persisted via shared_preferences with app-prefixed keys.
library;

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/riddle_bank.dart';
import '../models/riddle.dart';
import 'app_providers.dart';

/// Supplies the next hint riddle for a language. Abstracted so the UI can be
/// driven by a deterministic source in tests.
abstract class RiddleSource {
  Riddle take(String languageCode);
}

/// A per-language shuffled riddle deck plus how far it has been consumed, both
/// persisted so hint riddles appear in a random order that never repeats until
/// the whole deck is exhausted — and the position carries across app restarts.
///
/// When the deck runs out it is reshuffled, and the just-seen riddle is never
/// dealt first, so there is no back-to-back repeat across the shuffle boundary.
/// If the bank changes (e.g. an app update adds riddles) the deck is rebuilt.
class RiddleRotation implements RiddleSource {
  RiddleRotation(SharedPreferences prefs, {Random? random})
      : _prefs = prefs,
        _random = random ?? Random();

  final SharedPreferences _prefs;
  final Random _random;

  static String _orderKey(String lang) => 'sudoku_riddle_order_$lang';
  static String _posKey(String lang) => 'sudoku_riddle_pos_$lang';

  @override
  Riddle take(String languageCode) {
    final bank = riddlesFor(languageCode);
    final ids = bank.map((r) => r.id).toList();

    var order = _prefs.getStringList(_orderKey(languageCode));
    var pos = _prefs.getInt(_posKey(languageCode)) ?? 0;

    if (order == null || !_sameSet(order, ids)) {
      // First run, or the bank changed after an update: deal a fresh deck.
      order = _shuffled(ids);
      pos = 0;
    } else if (pos >= order.length) {
      // Deck exhausted: reshuffle, but don't deal the last card again first.
      order = _shuffled(ids, avoidFirst: order[order.length - 1]);
      pos = 0;
    }

    final id = order[pos];
    _persist(languageCode, order, pos + 1);
    return bank.firstWhere((r) => r.id == id);
  }

  bool _sameSet(List<String> a, List<String> b) =>
      a.length == b.length && a.toSet().containsAll(b);

  List<String> _shuffled(List<String> ids, {String? avoidFirst}) {
    final deck = List<String>.of(ids)..shuffle(_random);
    if (avoidFirst != null && deck.length > 1 && deck.first == avoidFirst) {
      final other = 1 + _random.nextInt(deck.length - 1);
      deck[0] = deck[other];
      deck[other] = avoidFirst;
    }
    return deck;
  }

  void _persist(String lang, List<String> order, int pos) {
    _prefs.setStringList(_orderKey(lang), order);
    _prefs.setInt(_posKey(lang), pos);
  }
}

final riddleSourceProvider = Provider<RiddleSource>(
  (ref) => RiddleRotation(ref.watch(sharedPreferencesProvider)),
);
