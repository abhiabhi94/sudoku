import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/models/level_progress.dart';

void main() {
  test('empty progress is uncompleted with no best time', () {
    final p = LevelProgress.empty(5);
    expect(p.globalLevel, 5);
    expect(p.completed, isFalse);
    expect(p.bestTimeMs, isNull);
    expect(p.timesCompleted, 0);
  });

  test('withCompletion records first solve and best time', () {
    final p = LevelProgress.empty(1).withCompletion(45000);
    expect(p.completed, isTrue);
    expect(p.bestTimeMs, 45000);
    expect(p.timesCompleted, 1);
  });

  test('withCompletion keeps the faster time and counts replays', () {
    final first = LevelProgress.empty(1).withCompletion(45000);
    final slower = first.withCompletion(60000);
    expect(slower.bestTimeMs, 45000);
    expect(slower.timesCompleted, 2);
    final faster = slower.withCompletion(30000);
    expect(faster.bestTimeMs, 30000);
    expect(faster.timesCompleted, 3);
  });

  test('isNewBest reflects whether a time beats the record', () {
    final p = LevelProgress.empty(1);
    expect(p.isNewBest(99999), isTrue);
    final solved = p.withCompletion(40000);
    expect(solved.isNewBest(50000), isFalse);
    expect(solved.isNewBest(20000), isTrue);
  });

  test('copyWith overrides fields', () {
    final p = LevelProgress.empty(3).copyWith(
      completed: true,
      bestTimeMs: 12345,
      timesCompleted: 2,
    );
    expect(p.completed, isTrue);
    expect(p.bestTimeMs, 12345);
    expect(p.timesCompleted, 2);
    expect(p.globalLevel, 3);
  });

  test('copyWith with no args keeps every field', () {
    final original = LevelProgress.empty(5).withCompletion(9000);
    final same = original.copyWith();
    expect(same.globalLevel, original.globalLevel);
    expect(same.completed, original.completed);
    expect(same.bestTimeMs, original.bestTimeMs);
    expect(same.timesCompleted, original.timesCompleted);
  });
}
