import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/models/settings.dart';
import 'package:sudoku/providers/app_providers.dart';
import 'package:sudoku/providers/settings_provider.dart';

Future<SharedPreferences> _prefs([Map<String, Object> seed = const {}]) async {
  SharedPreferences.setMockInitialValues(seed);
  return SharedPreferences.getInstance();
}

ProviderContainer _container(SharedPreferences prefs) => ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsRepository', () {
    test('loads defaults when nothing is stored', () async {
      final repo = SettingsRepository(await _prefs());
      expect(repo.load(), Settings.defaults);
    });

    test('round-trips saved settings', () async {
      final prefs = await _prefs();
      final repo = SettingsRepository(prefs);
      const custom = Settings(
        musicOn: false,
        musicVolume: 0.3,
        hapticsOn: false,
        languageCode: 'hi',
        onboardingDone: true,
      );
      await repo.save(custom);
      expect(SettingsRepository(prefs).load(), custom);
    });
  });

  group('SettingsNotifier', () {
    test('setters update state and persist', () async {
      final prefs = await _prefs();
      final container = _container(prefs);
      addTearDown(container.dispose);
      final notifier = container.read(settingsProvider.notifier);

      notifier.setMusic(false);
      notifier.setHaptics(false);
      notifier.setLanguage('hi');
      notifier.completeOnboarding();

      final state = container.read(settingsProvider);
      expect(state.musicOn, isFalse);
      expect(state.hapticsOn, isFalse);
      expect(state.languageCode, 'hi');
      expect(state.onboardingDone, isTrue);
      // Persisted to prefs (the notifier saves asynchronously).
      await pumpEventQueue();
      expect(SettingsRepository(prefs).load(), state);
    });

    test('setMusicVolume clamps to 0..1', () async {
      final container = _container(await _prefs());
      addTearDown(container.dispose);
      final notifier = container.read(settingsProvider.notifier);

      notifier.setMusicVolume(2.0);
      expect(container.read(settingsProvider).musicVolume, 1.0);
      notifier.setMusicVolume(-1.0);
      expect(container.read(settingsProvider).musicVolume, 0.0);
    });

    test('setLanguage ignores unsupported codes', () async {
      final container = _container(await _prefs());
      addTearDown(container.dispose);
      final notifier = container.read(settingsProvider.notifier);

      notifier.setLanguage('fr');
      expect(container.read(settingsProvider).languageCode, 'en');
    });
  });
}
