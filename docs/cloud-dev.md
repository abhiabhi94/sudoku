# Developing in Claude Code on the web (cloud sessions)

How this repo is set up so a cloud session (no Android emulator, no KVM) can
build, test, and **visually verify** the app — and what to copy to a new
Flutter game repo (e.g. the arrow game) to get the same workflow.

## What the cloud container can and cannot do

| Capability                         | Status | Notes |
|------------------------------------|--------|-------|
| Flutter SDK (pinned)               | ✅     | Installed by the session-start hook into `/opt/flutter` |
| `flutter analyze` / `flutter test` | ✅     | Same gates as CI, incl. `tool/coverage.sh` |
| Web build + headless Chromium      | ✅     | `tool/screenshot.mjs` — phone-viewport screenshots + smoke test |
| Android emulator                   | ❌     | No `/dev/kvm`; an emulator would not boot usably |
| Android APK build                  | ⚠️     | Works after a one-off ~3 GB SDK install (see below); CI's `apk` job is the easy route |
| iOS build                          | ❌     | Needs macOS/Xcode |

So the loop is: change code → `flutter build web --debug --no-web-resources-cdn`
→ `node tool/screenshot.mjs --levels …` → read the PNGs. CI runs the same
script and uploads the screenshots as an artifact.

## Building an APK in a cloud session

CI's `apk` job (`.github/workflows/ci.yml`) is the normal way to get a
testable build: every push/PR uploads the arm64 "Sudoku Testing" APK as the
`sudoku-testing-debug-apk` artifact. A debug APK is ~90 MB (Dart kernel blob
+ debug engine), too big for the session's file hand-off, so building in the
container is only worth it for checking that the Android build still
compiles. If needed (Java 21 is preinstalled, dl.google.com is reachable):

```bash
mkdir -p /opt/android-sdk/cmdline-tools && cd /opt/android-sdk/cmdline-tools
curl -fsSL -o t.zip https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip
unzip -q t.zip && rm t.zip && mv cmdline-tools latest
export ANDROID_HOME=/opt/android-sdk
yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses >/dev/null
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --install "platform-tools" \
  "platforms;android-36" "build-tools;36.0.0" "ndk;28.2.13676358"   # versions from FlutterExtension.kt
flutter config --android-sdk $ANDROID_HOME
flutter build apk --debug --split-per-abi --target-platform android-arm64   # ~6 min first time
```

## Files that make this work

| File | Role |
|------|------|
| `.flutter-version` | Single pin for the SDK (hook + both CI jobs read it). Keep in sync with `.metadata`. |
| `AGENTS.md` + `CLAUDE.md` | One set of repo guidelines for every agent. `AGENTS.md` is the content (Codex reads it natively, incl. a "Code review" section); `CLAUDE.md` is a 10-line shim that starts with `@AGENTS.md` so Claude Code imports the same file. |
| `.claude/hooks/session-start.sh` + `.claude/settings.json` | Cloud-only SessionStart hook: installs Flutter, `pub get`, `gen-l10n`, ensures Playwright/Chromium, exports `PATH`/`NODE_PATH`. |
| `.claude/skills/run/SKILL.md` | Tells Claude how to build/screenshot/review in a session. |
| `tool/screenshot.mjs` | The driver: static server + font mirror + Playwright script + smoke gate. |
| `.github/actions/web-smoke/action.yml` | Composite action: build web, run the driver, upload `shots/`. Used by the `smoke` job in `ci.yml`. |
| `assets/fonts/` + `pubspec.yaml` `fonts:` block | Google Sans Flex bundled as a regular Flutter font family, so nothing is fetched at runtime (offline-safe on phones too). |
| `.github/workflows/pages.yml` | Deploys the release web build to GitHub Pages on every push to `main` (base href derived from the repo name). |
| `.github/workflows/codex-review.yml` | Codex PR review (`openai/codex-action`) on open / ready-for-review / `codex-review` label; posts one PR comment. Needs the `OPENAI_API_KEY` secret. The prompt only points at `AGENTS.md`. |
| `web/` | Web platform scaffold (`flutter create --platforms=web .`). |

## Porting to another Flutter game repo — checklist

1. `flutter create --platforms=web .` then **restore** the android/ios entries
   `flutter create` drops from `.metadata` (keep the new web entry).
2. Copy `.flutter-version`, `.claude/`, `tool/screenshot.mjs`,
   `.github/actions/web-smoke/`, the `smoke` job from `ci.yml`, and the
   `/shots/` line in `.gitignore`.
3. Bundle the typeface instead of fetching it at runtime (this repo uses
   Google Sans Flex, OFL). Static per-weight TTFs come from the Google Fonts
   CSS API: `curl -A "" "https://fonts.googleapis.com/css2?family=Google+Sans+Flex:wght@700"`
   prints the `.ttf` URL for that weight. Put them in `assets/fonts/`, declare
   the family under `flutter: fonts:` in `pubspec.yaml` with one entry per
   weight, ship `OFL.txt` next to them, and set `fontFamily` on the
   `ThemeData` (see `lib/ui/theme.dart`). No `google_fonts` package needed.
4. Adapt the **app-specific** parts of `tool/screenshot.mjs`:
   - the `prefs` map (your `shared_preferences` keys, `flutter.`-prefixed,
     JSON-encoded) — skip onboarding, mute audio, pick language/theme;
   - the navigation steps (what to click for a "level", how to go back).
     Give tappable widgets a `Semantics(label: …, button: true)` or a
     `tooltip:` so the driver can find them; run `--dump` to list them.
5. Adjust the default `runs:` lines in the composite action to your levels.
6. Copy `.github/workflows/codex-review.yml` unchanged and add the
   `OPENAI_API_KEY` secret. Keep the guidelines in `AGENTS.md` (with a
   "Code review" section) and make `CLAUDE.md` a shim whose first line is
   `@AGENTS.md`; the workflow itself has nothing repo-specific in it.

## Gotchas worth remembering

- **Chromium vs proxy:** in cloud sessions headless Chromium's TLS through
  the egress proxy fails for `*.gstatic.com` (curl/Node succeed). Everything
  the browser needs must come from `localhost`: `--no-web-resources-cdn`
  bundles CanvasKit, fonts are bundled, and the engine's fallback fonts
  (emoji, Devanagari) are mirrored by the script's server via
  `fontFallbackBaseUrl` (injected into `flutter_bootstrap.js` on the fly).
- **Debug web build** ≙ "testing" build: `kDebugMode` is true, so the
  unlock-everything switch applies. Release web builds keep progression.
- **Semantics on web** are off until the hidden "Enable accessibility"
  placeholder is clicked; the script does that. The accessible name of a
  widget concatenates its label and child text.
- **No isolates on web:** `compute()` runs inline; heavy generation blocks
  the UI thread briefly — wait before screenshotting.
- The first layout runs before the bundled font is registered; a
  `RenderFlex overflow` seen only on the very first frame is that transient.
  The script waits ~1.5 s after boot before screenshotting so the gate only
  catches real overflows.
