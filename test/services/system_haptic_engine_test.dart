import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/services/haptics_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final calls = <String>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        calls.add((call.arguments as String?) ?? 'vibrate');
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('SystemHapticEngine drives the platform haptics channel', () {
    const engine = SystemHapticEngine();
    engine.selection();
    engine.light();
    engine.medium();
    engine.heavy();
    engine.vibrate();
    expect(calls.length, 5);
  });
}
