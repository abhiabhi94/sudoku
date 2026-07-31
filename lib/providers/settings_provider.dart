/// Settings state: loads from and persists to shared_preferences.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings.dart';
import 'app_providers.dart';

/// Supported language codes (English default, Hindi).
const List<String> supportedLanguageCodes = <String>['en', 'hi'];

/// Wraps shared_preferences with typed load/save for [Settings].
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _kMusicOn = 'sudoku_music_on';
  static const _kMusicVolume = 'sudoku_music_volume';
  static const _kHaptics = 'sudoku_haptics_on';
  static const _kLanguage = 'sudoku_language';
  static const _kTheme = 'sudoku_theme';
  static const _kOnboarding = 'sudoku_onboarding_done';

  Settings load() {
    const d = Settings.defaults;
    return Settings(
      musicOn: _prefs.getBool(_kMusicOn) ?? d.musicOn,
      musicVolume: _prefs.getDouble(_kMusicVolume) ?? d.musicVolume,
      hapticsOn: _prefs.getBool(_kHaptics) ?? d.hapticsOn,
      languageCode: _prefs.getString(_kLanguage) ?? d.languageCode,
      themeChoice: _parseTheme(_prefs.getString(_kTheme), d.themeChoice),
      onboardingDone: _prefs.getBool(_kOnboarding) ?? d.onboardingDone,
    );
  }

  Future<void> save(Settings s) async {
    await _prefs.setBool(_kMusicOn, s.musicOn);
    await _prefs.setDouble(_kMusicVolume, s.musicVolume);
    await _prefs.setBool(_kHaptics, s.hapticsOn);
    await _prefs.setString(_kLanguage, s.languageCode);
    await _prefs.setString(_kTheme, s.themeChoice.name);
    await _prefs.setBool(_kOnboarding, s.onboardingDone);
  }

  /// Maps a stored theme name back to [ThemeChoice], falling back to [fallback]
  /// for missing or unrecognised values.
  static ThemeChoice _parseTheme(String? name, ThemeChoice fallback) {
    for (final choice in ThemeChoice.values) {
      if (choice.name == name) return choice;
    }
    return fallback;
  }
}

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier(this._repo) : super(_repo.load());

  final SettingsRepository _repo;

  void setMusic(bool on) => _update(state.copyWith(musicOn: on));
  void setMusicVolume(double volume) =>
      _update(state.copyWith(musicVolume: volume.clamp(0.0, 1.0)));
  void setHaptics(bool on) => _update(state.copyWith(hapticsOn: on));

  void setLanguage(String code) {
    if (!supportedLanguageCodes.contains(code)) return;
    _update(state.copyWith(languageCode: code));
  }

  void setThemeChoice(ThemeChoice choice) =>
      _update(state.copyWith(themeChoice: choice));

  void completeOnboarding() => _update(state.copyWith(onboardingDone: true));

  void _update(Settings next) {
    state = next;
    _repo.save(next);
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Settings>(
  (ref) => SettingsNotifier(ref.watch(settingsRepositoryProvider)),
);
