import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/models/stroke.dart';

void main() {
  group('Stroke', () {
    test('flattens and rebuilds its points', () {
      const stroke = Stroke([Offset(0.1, 0.2), Offset(0.3, 0.4)]);
      expect(stroke.toFlat(), [0.1, 0.2, 0.3, 0.4]);
      expect(Stroke.fromFlat(stroke.toFlat()).points, stroke.points);
    });

    test('fromFlat ignores a dangling odd value', () {
      final stroke = Stroke.fromFlat([0.1, 0.2, 0.3]);
      expect(stroke.points, [const Offset(0.1, 0.2)]);
    });
  });
}
