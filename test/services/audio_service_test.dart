import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/models/settings.dart';
import 'package:sudoku/services/audio_service.dart';

class _FakeBackend implements AudioBackend {
  final List<String> calls = [];
  double? volume;

  @override
  Future<void> loop(String asset, double v) async {
    volume = v;
    calls.add('loop:$asset');
  }

  @override
  Future<void> setVolume(double v) async {
    volume = v;
    calls.add('setVolume');
  }

  @override
  Future<void> resume() async => calls.add('resume');
  @override
  Future<void> pause() async => calls.add('pause');
  @override
  Future<void> stop() async => calls.add('stop');
}

void main() {
  const on = Settings.defaults; // music on, volume 0.6

  test('does nothing when no track is bundled', () async {
    final backend = _FakeBackend();
    final service = AudioService(backend); // trackAsset null
    await service.apply(on);
    await service.stop();
    expect(backend.calls, isEmpty);
  });

  test('starts the loop once, then resumes on later applies', () async {
    final backend = _FakeBackend();
    final service = AudioService(backend, trackAsset: 'audio/loop.mp3');

    await service.apply(on);
    expect(backend.calls, ['loop:audio/loop.mp3']);
    expect(backend.volume, closeTo(0.6, 0.001));

    await service.apply(on.copyWith(musicVolume: 0.2));
    expect(backend.calls, ['loop:audio/loop.mp3', 'setVolume', 'resume']);
    expect(backend.volume, closeTo(0.2, 0.001));
  });

  test('pauses when music is turned off', () async {
    final backend = _FakeBackend();
    final service = AudioService(backend, trackAsset: 'audio/loop.mp3');
    await service.apply(on);
    await service.apply(on.copyWith(musicOn: false));
    expect(backend.calls.last, 'pause');
  });

  test('does not pause if it never started', () async {
    final backend = _FakeBackend();
    final service = AudioService(backend, trackAsset: 'audio/loop.mp3');
    await service.apply(on.copyWith(musicOn: false));
    expect(backend.calls, isEmpty);
  });

  test('stop halts a started loop', () async {
    final backend = _FakeBackend();
    final service = AudioService(backend, trackAsset: 'audio/loop.mp3');
    await service.apply(on);
    await service.stop();
    expect(backend.calls.last, 'stop');
  });
}
