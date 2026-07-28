import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/providers/app_providers.dart';

void main() {
  test('sharedPreferencesProvider throws until overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(
      () => container.read(sharedPreferencesProvider),
      throwsUnimplementedError,
    );
  });
}
