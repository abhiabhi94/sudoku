import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/models/settings.dart';

void main() {
  test('defaults are sensible (music on, haptics on, English)', () {
    const d = Settings.defaults;
    expect(d.musicOn, isTrue);
    expect(d.hapticsOn, isTrue);
    expect(d.languageCode, 'en');
    expect(d.onboardingDone, isFalse);
    expect(d.musicVolume, closeTo(0.6, 0.001));
  });

  test('copyWith changes only the given fields', () {
    const d = Settings.defaults;
    final next = d.copyWith(musicOn: false, languageCode: 'hi');
    expect(next.musicOn, isFalse);
    expect(next.languageCode, 'hi');
    expect(next.hapticsOn, d.hapticsOn);
    expect(next.musicVolume, d.musicVolume);
  });

  test('equality and hashCode are value-based', () {
    const a = Settings.defaults;
    final b = a.copyWith();
    final c = a.copyWith(hapticsOn: false);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(c));
  });
}
