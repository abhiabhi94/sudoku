import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
import 'providers/app_providers.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/audio_service.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const SudokuApp(),
    ),
  );
}

class SudokuApp extends ConsumerWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep background music in sync with the music/volume settings. (No-op
    // until a licensed track is bundled into AudioService.)
    ref.listen(settingsProvider, (_, next) {
      ref.read(audioServiceProvider).apply(next);
    });
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'Sudoku',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: Locale(settings.languageCode),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: settings.onboardingDone
          ? const HomeScreen()
          : const OnboardingScreen(),
    );
  }
}
