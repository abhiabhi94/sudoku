import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/services/haptics_service.dart';

class _FakeEngine implements HapticEngine {
  final List<String> calls = [];
  @override
  void selection() => calls.add('selection');
  @override
  void light() => calls.add('light');
  @override
  void medium() => calls.add('medium');
  @override
  void heavy() => calls.add('heavy');
  @override
  void vibrate() => calls.add('vibrate');
}

void main() {
  test('fires impulses when haptics are enabled', () {
    final engine = _FakeEngine();
    final service = HapticsService(() => true, engine: engine);
    service.tap();
    service.correct();
    service.wrong();
    service.victory();
    service.lockout();
    expect(engine.calls,
        ['selection', 'light', 'heavy', 'medium', 'vibrate']);
  });

  test('stays silent when haptics are disabled', () {
    final engine = _FakeEngine();
    final service = HapticsService(() => false, engine: engine);
    service.tap();
    service.wrong();
    expect(engine.calls, isEmpty);
  });
}
