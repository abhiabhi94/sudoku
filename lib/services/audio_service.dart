/// Looping background music that respects the user's music on/off + volume.
/// Wraps audioplayers behind an injectable [AudioBackend] so the control logic
/// is unit-testable without the audio plugin. No track is bundled yet, so the
/// service stays silent until [trackAsset] points at a real CC-BY file.
library;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/settings.dart';

/// Minimal audio operations the service needs.
abstract class AudioBackend {
  Future<void> loop(String asset, double volume);
  Future<void> setVolume(double volume);
  Future<void> resume();
  Future<void> pause();
  Future<void> stop();
}

/// Real backend backed by an [AudioPlayer] set to loop. Thin platform glue —
/// excluded from coverage (exercised only on a real device).
// coverage:ignore-start
class AudioPlayersBackend implements AudioBackend {
  AudioPlayersBackend([AudioPlayer? player]) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  @override
  Future<void> loop(String asset, double volume) async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(volume);
    await _player.play(AssetSource(asset));
  }

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);
  @override
  Future<void> resume() => _player.resume();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() => _player.stop();
}
// coverage:ignore-end

class AudioService {
  AudioService(this._backend, {this.trackAsset});

  final AudioBackend _backend;

  /// Asset path (under `assets/audio/`) of the looping track, or null until a
  /// licensed track is bundled — while null the service does nothing.
  final String? trackAsset;

  bool _started = false;

  /// Applies the current [settings] to playback: starts/resumes the loop when
  /// music is on, pauses it when off, and tracks volume changes.
  Future<void> apply(Settings settings) async {
    final track = trackAsset;
    if (track == null) return;
    if (settings.musicOn) {
      if (_started) {
        await _backend.setVolume(settings.musicVolume);
        await _backend.resume();
      } else {
        await _backend.loop(track, settings.musicVolume);
        _started = true;
      }
    } else if (_started) {
      await _backend.pause();
    }
  }

  Future<void> stop() async {
    if (_started) {
      await _backend.stop();
      _started = false;
    }
  }
}

// coverage:ignore-start
final audioServiceProvider = Provider<AudioService>(
  (ref) => AudioService(AudioPlayersBackend()),
);
// coverage:ignore-end
