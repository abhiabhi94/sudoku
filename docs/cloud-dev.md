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
| Android APK build                  | ⚠️     | Possible (dl.google.com is reachable) but needs a ~2 GB SDK install; not set up |
| iOS build                          | ❌     | Needs macOS/Xcode |

So the loop is: change code → `flutter build web --debug --no-web-resources-cdn`
→ `node tool/screenshot.mjs --levels …` → read the PNGs. CI runs the same
script and uploads the screenshots as an artifact.

## Files that make this work

| File | Role |
|------|------|
| `.flutter-version` | Single pin for the SDK (hook + both CI jobs read it). Keep in sync with `.metadata`. |
| `.claude/hooks/session-start.sh` + `.claude/settings.json` | Cloud-only SessionStart hook: installs Flutter, `pub get`, `gen-l10n`, ensures Playwright/Chromium, exports `PATH`/`NODE_PATH`. |
| `.claude/skills/run/SKILL.md` | Tells Claude how to build/screenshot/review in a session. |
| `tool/screenshot.mjs` | The driver: static server + font mirror + Playwright script + smoke gate. |
| `.github/actions/web-smoke/action.yml` | Composite action: build web, run the driver, upload `shots/`. Used by the `smoke` job in `ci.yml`. |
| `assets/fonts/` + `pubspec.yaml` assets entry | Nunito bundled so `google_fonts` never fetches at runtime (offline-safe on phones too). |
| `web/` | Web platform scaffold (`flutter create --platforms=web .`). |

## Porting to another Flutter game repo — checklist

1. `flutter create --platforms=web .` then **restore** the android/ios entries
   `flutter create` drops from `.metadata` (keep the new web entry).
2. Copy `.flutter-version`, `.claude/`, `tool/screenshot.mjs`,
   `.github/actions/web-smoke/`, the `smoke` job from `ci.yml`, and the
   `/shots/` line in `.gitignore`.
3. If the app uses `google_fonts`, bundle the family: download the exact
   files the package expects (hashes live in
   `google_fonts/lib/src/google_fonts_parts/part_<x>.g.dart`, URL
   `https://fonts.gstatic.com/s/a/<hash>.ttf`), name them
   `<Family>-<Weight>.ttf` (`Regular`, `Bold`, `SemiBold`, …), add the folder
   under `flutter: assets:` and ship the OFL licence next to them.
4. Adapt the **app-specific** parts of `tool/screenshot.mjs`:
   - the `prefs` map (your `shared_preferences` keys, `flutter.`-prefixed,
     JSON-encoded) — skip onboarding, mute audio, pick language/theme;
   - the navigation steps (what to click for a "level", how to go back).
     Give tappable widgets a `Semantics(label: …, button: true)` or a
     `tooltip:` so the driver can find them; run `--dump` to list them.
5. Adjust the default `runs:` lines in the composite action to your levels.

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
