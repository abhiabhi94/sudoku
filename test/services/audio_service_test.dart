import 'package:flutter/widgets.dart';
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

  test('starts the loop once; a volume change does not re-resume it', () async {
    final backend = _FakeBackend();
    final service = AudioService(backend, trackAsset: 'audio/loop.mp3');

    await service.apply(on);
    expect(backend.calls, ['loop:audio/loop.mp3']);
    expect(backend.volume, closeTo(0.6, 0.001));

    // Already audible, so only the volume moves — no redundant resume().
    await service.apply(on.copyWith(musicVolume: 0.2));
    expect(backend.calls, ['loop:audio/loop.mp3', 'setVolume']);
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

  group('app lifecycle', () {
    test('pauses when the app leaves the foreground, resumes on return',
        () async {
      final backend = _FakeBackend();
      final service = AudioService(backend, trackAsset: 'audio/loop.mp3');
      await service.apply(on);
      backend.calls.clear();

      await service.handleLifecycle(AppLifecycleState.paused);
      expect(backend.calls, ['pause']);

      await service.handleLifecycle(AppLifecycleState.resumed);
      expect(backend.calls, ['pause', 'setVolume', 'resume']);
    });

    for (final away in const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.detached,
    ]) {
      test('pauses on $away', () async {
        final backend = _FakeBackend();
        final service = AudioService(backend, trackAsset: 'audio/loop.mp3');
        await service.apply(on);
        backend.calls.clear();
        await service.handleLifecycle(away);
        expect(backend.calls, ['pause']);
      });
    }

    test('does not resume music the user had turned off', () async {
      final backend = _FakeBackend();
      final service = AudioService(backend, trackAsset: 'audio/loop.mp3');
      await service.apply(on);
      await service.apply(on.copyWith(musicOn: false));
      await service.handleLifecycle(AppLifecycleState.paused);
      backend.calls.clear();

      await service.handleLifecycle(AppLifecycleState.resumed);
      expect(backend.calls, isEmpty);
    });

    test('does not start the loop while backgrounded', () async {
      final backend = _FakeBackend();
      final service = AudioService(backend, trackAsset: 'audio/loop.mp3');
      await service.handleLifecycle(AppLifecycleState.paused);

      // Settings can still change (e.g. restored on launch) — but nothing
      // should start playing until the app is back in the foreground.
      await service.apply(on);
      expect(backend.calls, isEmpty);

      // Coming back to the foreground is what finally starts it.
      await service.handleLifecycle(AppLifecycleState.resumed);
      expect(backend.calls, ['loop:audio/loop.mp3']);
    });

    test('starts the loop on return when it never started while backgrounded',
        () async {
      // Regression: `resumed` used to only resume an already-started loop, so
      // an app whose first apply() landed while backgrounded stayed silent for
      // the rest of the session.
      final backend = _FakeBackend();
      final service = AudioService(backend, trackAsset: 'audio/loop.mp3');

      await service.handleLifecycle(AppLifecycleState.paused);
      await service.apply(on);
      expect(backend.calls, isEmpty);

      await service.handleLifecycle(AppLifecycleState.resumed);
      expect(backend.calls, ['loop:audio/loop.mp3']);
      expect(backend.volume, closeTo(0.6, 0.001));
    });

    test('does nothing when no track is bundled', () async {
      final backend = _FakeBackend();
      final service = AudioService(backend); // trackAsset null
      await service.handleLifecycle(AppLifecycleState.paused);
      await service.handleLifecycle(AppLifecycleState.resumed);
      expect(backend.calls, isEmpty);
    });
  });
}
