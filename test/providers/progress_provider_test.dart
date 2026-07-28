import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/providers/app_providers.dart';
import 'package:sudoku/providers/progress_provider.dart';

Future<SharedPreferences> _prefs([Map<String, Object> seed = const {}]) async {
  SharedPreferences.setMockInitialValues(seed);
  return SharedPreferences.getInstance();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SudokuProgressRepository', () {
    test('loads empty progress for a fresh install', () async {
      final repo = SudokuProgressRepository(await _prefs());
      final all = repo.loadAll();
      expect(all.length, totalLevels);
      expect(all[1]!.completed, isFalse);
    });

    test('saves and reloads completion, best time and count', () async {
      final prefs = await _prefs();
      final repo = SudokuProgressRepository(prefs);
      final solved = repo.load(3).withCompletion(42000);
      await repo.save(solved);

      final reloaded = SudokuProgressRepository(prefs).load(3);
      expect(reloaded.completed, isTrue);
      expect(reloaded.bestTimeMs, 42000);
      expect(reloaded.timesCompleted, 1);
    });
  });

  group('ProgressNotifier', () {
    test('recordCompletion updates state and total games', () async {
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(await _prefs())],
      );
      addTearDown(container.dispose);
      final notifier = container.read(progressProvider.notifier);

      expect(notifier.totalGamesCompleted, 0);
      notifier.recordCompletion(1, 30000);
      notifier.recordCompletion(1, 20000);
      notifier.recordCompletion(2, 50000);

      expect(notifier.progressFor(1).timesCompleted, 2);
      expect(notifier.progressFor(1).bestTimeMs, 20000);
      expect(notifier.totalGamesCompleted, 3);
    });

    test('unlockedByProgress gates levels behind the previous one', () async {
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(await _prefs())],
      );
      addTearDown(container.dispose);
      final notifier = container.read(progressProvider.notifier);

      expect(notifier.unlockedByProgress(1), isTrue);
      expect(notifier.unlockedByProgress(2), isFalse);
      expect(notifier.highestUnlocked, 1);

      notifier.recordCompletion(1, 30000);
      expect(notifier.unlockedByProgress(2), isTrue);
      expect(notifier.unlockedByProgress(3), isFalse);
      expect(notifier.highestUnlocked, 2);
    });

    test('isUnlocked follows progress, or opens everything when unlockAll', () async {
      final repo = SudokuProgressRepository(await _prefs());

      final locked = ProgressNotifier(repo, unlockAllLevels: false);
      addTearDown(locked.dispose);
      expect(locked.isUnlocked(1), isTrue);
      expect(locked.isUnlocked(2), isFalse);
      expect(locked.isUnlocked(30), isFalse);

      final openAll = ProgressNotifier(repo, unlockAllLevels: true);
      addTearDown(openAll.dispose);
      expect(openAll.isUnlocked(30), isTrue);
    });
  });
}
