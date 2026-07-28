# Sudoku

A modern, playful cross-platform (Android + iOS) Sudoku game built with Flutter.

## Features

- **Classic 9×9 Sudoku** with a guaranteed-unique solution.
- **3 tiers × 10 levels** (Beginner, Advanced, Expert). Difficulty jumps
  between tiers and rises gently within a tier. A **fresh puzzle is generated
  every time** you open a level.
- **Forgiving mistakes**: 3 wrong placements are free; a 4th triggers a playful
  3–5 second "you're guessing 👀" lockout.
- **Riddle-gated hints**: solve a word riddle (10 per language) to reveal one
  logically-deducible cell. A wrong answer offers another riddle.
- **Progress**: games completed, best time per level, and level unlocking.
- **Configurable** background music (CC-BY, with an attribution screen) and
  vibration (on by default).
- **English & Hindi** (हिन्दी), with natively-authored Hindi riddles.
- One-time animated onboarding, confetti wins, and a cheerful Material 3 look.

## Architecture

Pure-Dart, zero-Flutter **engine** (`lib/engine/`) — generation, a backtracking
solver + uniqueness counter, a human-technique solver (used for both difficulty
**rating** and **hints**), and band-based generation. It runs on a background
isolate so the UI never blocks, and is exhaustively unit-tested.

State is **Riverpod `StateNotifier`**; persistence is **`shared_preferences`**.
Layout follows a layered `lib/` structure (`engine`, `models`, `providers`,
`services`, `screens`, `widgets`, `ui`, `data`, `l10n`).

## Running

Two build types install side-by-side:

- **Debug → "Sudoku Testing"** (`app.curious.sudoku.testing`): every level
  unlocked, for testing.
- **Release → "Sudoku"** (`app.curious.sudoku`): levels locked until the
  previous one is cleared.

```bash
flutter run                 # debug — "Sudoku Testing", all levels open
flutter run --release       # release — "Sudoku", locked progression
flutter build apk --debug   # -> app-debug.apk   ("Sudoku Testing")
flutter build apk --release # -> app-release.apk  ("Sudoku")
```

## Publishing (Play Store)

Release builds are signed with your **upload key**, read from a gitignored
`android/key.properties`. Copy `android/key.properties.example` to
`android/key.properties`, generate an upload keystore, then:

```bash
flutter build appbundle --release   # -> build/app/outputs/bundle/release/app-release.aab
```

Upload the `.aab` to the Play Console (Internal testing). Play App Signing
re-signs it with the app signing key. Without `key.properties`, release falls
back to debug signing (fine for local runs, not for the Play Store).

## Tests & coverage

```bash
flutter test                 # full suite
tool/coverage.sh 92          # coverage gate (fails under 92%)
```

The gate excludes generated localizations, `main.dart`, and platform-only glue
marked with `// coverage:ignore`. Current hand-written coverage is ~97%
(engine, models, providers at 100%).

## Follow-ups

- **Music tracks**: `AudioService` + the settings toggles + the credits screen
  are wired, but no track is bundled yet. Drop CC-BY `.mp3`/`.ogg` files into
  `assets/audio/`, set `trackAsset` in `AudioService`, and list attributions in
  `lib/data/audio_credits.dart`.
- **App icon**: still the default Flutter icon (`flutter_launcher_icons` is a
  dev dependency, ready to configure with an `assets/logo.png`).
- **iOS flavor**: the Android `testing`/`production` flavors are set up; the
  matching iOS scheme needs to be added in Xcode (not installed in this env).
