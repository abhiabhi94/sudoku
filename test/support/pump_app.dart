import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/l10n/app_localizations.dart';
import 'package:sudoku/providers/app_providers.dart';
import 'package:sudoku/ui/theme.dart';

/// Pumps [home] inside a fully-localised MaterialApp with a mock
/// SharedPreferences, returning the ProviderContainer for state assertions.
Future<ProviderContainer> pumpApp(
  WidgetTester tester,
  Widget home, {
  Map<String, Object> seed = const {},
  Locale locale = const Locale('en'),
  List<Override> extraOverrides = const [],
  ThemeMode themeMode = ThemeMode.light,
}) async {
  SharedPreferences.setMockInitialValues(seed);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      ...extraOverrides,
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    ),
  );
  return container;
}
