import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/utils/format.dart';

void main() {
  test('formats milliseconds as m:ss', () {
    expect(formatDurationMs(0), '0:00');
    expect(formatDurationMs(7000), '0:07');
    expect(formatDurationMs(67000), '1:07');
    expect(formatDurationMs(600000), '10:00');
  });

  test('clamps negative durations to zero', () {
    expect(formatDurationMs(-500), '0:00');
  });
}
