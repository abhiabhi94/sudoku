/// User-configurable settings, persisted via shared_preferences. Immutable
/// with [copyWith]. Pure Dart (no Flutter).
library;

class Settings {
  const Settings({
    required this.musicOn,
    required this.musicVolume,
    required this.hapticsOn,
    required this.languageCode,
    required this.onboardingDone,
  });

  /// Background music on/off.
  final bool musicOn;

  /// Music volume, 0.0 .. 1.0.
  final double musicVolume;

  /// Vibration/haptics on/off (on by default).
  final bool hapticsOn;

  /// Active language: 'en' (default) or 'hi'.
  final String languageCode;

  /// Whether the one-time onboarding has been seen.
  final bool onboardingDone;

  /// Default settings for a fresh install.
  static const Settings defaults = Settings(
    musicOn: true,
    musicVolume: 0.6,
    hapticsOn: true,
    languageCode: 'en',
    onboardingDone: false,
  );

  Settings copyWith({
    bool? musicOn,
    double? musicVolume,
    bool? hapticsOn,
    String? languageCode,
    bool? onboardingDone,
  }) {
    return Settings(
      musicOn: musicOn ?? this.musicOn,
      musicVolume: musicVolume ?? this.musicVolume,
      hapticsOn: hapticsOn ?? this.hapticsOn,
      languageCode: languageCode ?? this.languageCode,
      onboardingDone: onboardingDone ?? this.onboardingDone,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Settings &&
      other.musicOn == musicOn &&
      other.musicVolume == musicVolume &&
      other.hapticsOn == hapticsOn &&
      other.languageCode == languageCode &&
      other.onboardingDone == onboardingDone;

  @override
  int get hashCode => Object.hash(
        musicOn,
        musicVolume,
        hapticsOn,
        languageCode,
        onboardingDone,
      );
}
