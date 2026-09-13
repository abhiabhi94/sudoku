# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A modern, playful cross-platform (Android + iOS) **Sudoku** game built with Flutter.
Classic 9×9 Sudoku, 4 tiers (Beginner / Advanced / Expert / Master) × 10 levels, with a
fresh procedurally-generated puzzle each time a level is opened. Forgiving
mistakes (3 free, then a short lockout), riddle-gated hints, local progress
tracking, configurable music + haptics, and English/Hindi localization.

## Java path

The system `keytool`/`java` has no JRE. Use the JDK bundled with Android Studio:
`/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin`
(this is also the Java binary Flutter uses — see `flutter doctor -v`).

## Build & Development Commands

```bash
flutter pub get                 # deps
flutter gen-l10n                # regenerate localizations after editing lib/l10n/*.arb
flutter analyze                 # static analysis (must be clean)
flutter test                    # full test suite
tool/coverage.sh 92             # coverage gate (fails under threshold; ~97% today)

flutter build web --debug --no-web-resources-cdn   # web build (debug = all levels unlocked)
node tool/screenshot.mjs --levels 1,11,21 --settings  # phone-viewport screenshots -> shots/

flutter run                     # debug build = "Sudoku Testing", all levels unlocked
flutter run --release           # release build = "Sudoku", locked progression
flutter build apk --debug       # -> build/app/outputs/flutter-apk/app-debug.apk
flutter build apk --release     # -> app-release.apk (upload-key signed if key.properties present)
flutter build appbundle --release  # -> build/app/outputs/bundle/release/app-release.aab (for Play Store)
```

## Cloud sessions & visual verification

Claude Code on the web has no Android emulator (no KVM). The stand-in is the
**web build + headless Chromium**: `tool/screenshot.mjs` serves `build/web`,
drives the app (home, settings, any level, EN/HI, light/dark) at 390×844 and
writes PNGs to `shots/`; it exits 1 on any Flutter exception, so it doubles
as the CI smoke test (`.github/actions/web-smoke`, job "Web smoke &
screenshots"). See `.claude/skills/run/SKILL.md` and `docs/cloud-dev.md`
(porting checklist for other repos). The SessionStart hook in
`.claude/hooks/session-start.sh` installs the SDK pinned in `.flutter-version`.

The web target is a verification/preview target; the shipped platforms are
still Android + iOS. Nunito is bundled in `assets/fonts/` (google_fonts
resolves it from assets, no runtime fetch).

## Build types (no flavors)

Identity is tied to the **build type**, not a product flavor:

| Build   | App name        | Application id                  | Levels                      |
|---------|-----------------|---------------------------------|-----------------------------|
| debug   | Sudoku Testing  | `app.curious.sudoku.testing`    | all unlocked (for testing)  |
| release | Sudoku          | `app.curious.sudoku`            | locked until previous cleared |

- The debug `.testing` app-id suffix lets both install side-by-side.
- "Unlock all levels" keys off `kDebugMode` (`testingUnlocksAllLevels` in
  `lib/providers/progress_provider.dart`). Namespace is `app.curious.sudoku`.
- Do NOT name an Android flavor starting with `test` (Gradle reserves it), and
  `android.buildFeatures.resValues` must stay enabled for the per-build app name.

## Release signing / publishing

- Release is signed with an upload key read from `android/key.properties`
  (**gitignored**); falls back to debug signing when that file is absent.
  Template: `android/key.properties.example`. Keystore lives OUTSIDE the repo.
- Never commit `key.properties`, `*.jks`, `*.keystore`, or anything under
  `build/` or `android/build/`.
- Publish flow: `flutter build appbundle --release` → upload the `.aab` to the
  Play Console (Play App Signing re-signs it).

## Architecture

**Pure-Dart engine + Riverpod StateNotifier + shared_preferences.** Layered
`lib/` (by type):

```
lib/
  main.dart            # prefs awaited once, ProviderScope override, MaterialApp + l10n
  engine/              # PURE DART, zero Flutter imports — runs on a compute() isolate
    board.dart           geometry, candidate bitmasks, validity
    generator.dart       randomized-MRV full solution + uniqueness-preserving digging
    solver.dart          countSolutions(cap:2) uniqueness + solver
    techniques.dart      technique ladder (singles→locked→pairs/triples→X-Wing→XY-Wing); powers rating AND hints
    rater.dart           score puzzle by hardest technique + clue count
    puzzle_factory.dart  generateForBand(tier,level,seed) — generatePuzzleTask is the isolate entry
  data/                level_specs.dart (40 bands), riddle_bank.dart (10 EN + 10 HI), audio_credits.dart
  models/              level_spec, level_progress, settings, game_state, riddle
  providers/           app_providers (DI root), settings_provider, progress_provider, game_provider
  services/            haptics_service, audio_service (both behind injectable backends)
  screens/             onboarding, home, game, settings, credits
  ui/                  colors.dart (light+dark SudokuPalette), theme.dart (Material 3 + Nunito)
  widgets/             sudoku_grid, number_pad, mistakes_indicator, hint_progress_bar, riddle_dialog
  l10n/                app_en.arb, app_hi.arb (+ generated app_localizations*.dart)
```

Key patterns:
- **DI:** `sharedPreferencesProvider` throws until overridden in `main()`; all
  repositories/providers read prefs through it. Tests override it with a mock.
- **Persistence:** `shared_preferences` only, keys prefixed `sudoku_*`.
- **Generation is off-thread:** `game_provider` calls `compute(generatePuzzleTask, …)`.
  The engine has zero Flutter imports so it is isolate-safe and fully unit-testable.
- **Difficulty:** technique-tier window + clue count per level, tuned in
  `data/level_specs.dart` (tiers jump between Beginner/Advanced/Expert/Master, gentle within;
  Master requires an XY-Wing on every board).
- **Mistakes:** 3 free; the 4th triggers a 3–5s lockout (paused timer). Hints
  reveal the next logically-deducible cell, gated behind a word riddle.

## Testing

- `flutter test` + `tool/coverage.sh`. Engine, models, and providers are at
  **100%**; overall ~97%.
- The gate excludes generated l10n, `main.dart`, and platform-only glue marked
  with `// coverage:ignore` (real audio backend, isolate/timer wiring, provider
  defaults). Don't add `coverage:ignore` to hide untested logic — only true glue.
- Services/notifiers take injectable backends (HapticEngine, AudioBackend,
  PuzzleGenerator, Random, seedSource, autoTick) so they test without plugins.

## Continuous Integration

GitHub Actions runs on every push to `main` and every PR targeting `main`
(`.github/workflows/ci.yml`). Flutter is pinned in **`.flutter-version`**
(3.44.8 / stable — match `.metadata`; bump both together; the session-start
hook reads the same file). Job "Analyze & test" runs the same gates you run
locally:

```
flutter pub get
flutter gen-l10n
flutter analyze --fatal-infos      # any info/warning fails the build
bash tool/coverage.sh 92           # coverage gate — fails under 92%
```

The coverage gate is enforced in CI, so a PR that drops line coverage below
**92%** (excluding generated l10n, `main.dart`, and `// coverage:ignore` glue)
is red and cannot merge. Keep `.flutter-version` in sync with `.metadata`
whenever you upgrade the toolchain.

Job "Web smoke & screenshots" builds the web app, drives it in headless
Chromium (`tool/screenshot.mjs`), fails on any Flutter exception, and uploads
`shots/` as the `screenshots` artifact for visual review.

## Conventions

- Dart `^3.12.2`, Material 3, `useMaterial3: true`; stock `flutter_lints` (no overrides).
- **Theming:** light + dark via `ThemeMode` (default `system`, set in Settings). Widgets read board/semantic colours through `context.palette` (a `SudokuPalette` chosen by brightness) — never hardcode a `Color`. Add new tokens as fields on `SudokuPalette` with both light/dark values in `ui/colors.dart`.
- `snake_case` filenames; const-heavy; trailing commas; imports at the top.
- Immutable state with `copyWith`; Riverpod **StateNotifier** style (not codegen).
- **No `try/except`** unless explicitly required. Pre-compile regexes as constants.
- Prefer "allowedlist/blocklist" over black/white; format large numbers as `10_000`.

## Pending follow-ups

- **More music tracks:** one looping track is bundled — "Permafrost" by Scott
  Buckley (CC-BY 4.0), `kBackgroundTrack` in `services/audio_service.dart`,
  credited in `data/audio_credits.dart`. Adding more means extending
  `AudioService` past its single `trackAsset`. Use `.mp3`/AAC, never `.ogg`
  (iOS can't decode Vorbis via audioplayers).
- **App icon:** still the default Flutter icon (`flutter_launcher_icons` is a
  dev dependency, ready for an `assets/logo.png`).
- **iOS:** code is iOS-ready; the matching iOS scheme needs Xcode (not set up here).
