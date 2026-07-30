import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/data/riddle_bank.dart';
import 'package:sudoku/providers/app_providers.dart';
import 'package:sudoku/providers/riddle_rotation_provider.dart';

Future<SharedPreferences> _prefs([Map<String, Object> seed = const {}]) async {
  SharedPreferences.setMockInitialValues(seed);
  return SharedPreferences.getInstance();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('deals every riddle once before repeating', () async {
    final rotation = RiddleRotation(await _prefs(), random: Random(1));
    final deckSize = riddlesFor('en').length;

    final seen = [for (var i = 0; i < deckSize; i++) rotation.take('en').id];
    expect(seen.toSet().length, deckSize, reason: 'no repeats within a deck');
  });

  test('reshuffles after each deck without ever repeating back-to-back',
      () async {
    final rotation = RiddleRotation(await _prefs(), random: Random(2));
    final deckSize = riddlesFor('en').length;

    // Play through many decks so the reshuffle boundary — including the case
    // where the fresh shuffle would otherwise re-deal the just-seen card — is
    // exercised repeatedly. Every consecutive pair must differ.
    var prev = rotation.take('en').id;
    for (var i = 1; i < deckSize * 300; i++) {
      final next = rotation.take('en').id;
      expect(next, isNot(prev), reason: 'no two riddles in a row may match');
      prev = next;
    }
  });

  test('position persists so a restart resumes without repeats', () async {
    final prefs = await _prefs();
    final before = RiddleRotation(prefs, random: Random(3));
    final seen = {before.take('en').id, before.take('en').id};

    // A new instance sharing the persisted prefs continues where we left off.
    final resumed = RiddleRotation(prefs, random: Random(3));
    expect(seen, isNot(contains(resumed.take('en').id)));
  });

  test('each language keeps its own independent deck', () async {
    final rotation = RiddleRotation(await _prefs(), random: Random(4));
    expect(rotation.take('en').id, startsWith('en-'));
    expect(rotation.take('hi').id, startsWith('hi-'));
  });

  test('rebuilds the deck when stored ids no longer match the bank', () async {
    final rotation = RiddleRotation(
      await _prefs(<String, Object>{
        'sudoku_riddle_order_en': <String>['en-gone', 'en-old'],
        'sudoku_riddle_pos_en': 1,
      }),
      random: Random(5),
    );
    expect(riddlesFor('en').map((r) => r.id), contains(rotation.take('en').id));
  });

  test('the provider supplies a persistent rotation', () async {
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(await _prefs())],
    );
    addTearDown(container.dispose);
    expect(container.read(riddleSourceProvider), isA<RiddleRotation>());
  });
}
