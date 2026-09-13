---
name: run
description: Build the app for web and drive it in headless Chromium at a phone viewport to capture screenshots of home/settings/any level, then review the PNGs. Use to visually verify a UI change, check a level's rendering, or run the smoke test. The cloud container has no Android emulator (no KVM); this harness is the stand-in.
---

# Run & screenshot the app (cloud stand-in for the emulator)

The session container has no KVM, so no Android emulator. Instead the app is
built for **web** (debug mode = every level unlocked, same as the "Sudoku
Testing" Android build) and rendered in headless Chromium at 390×844 @2x.

## Commands

```bash
flutter build web --debug --no-web-resources-cdn --no-wasm-dry-run   # ~60 s
node tool/screenshot.mjs --levels 1,5,11,21 --settings               # -> shots/*.png
node tool/screenshot.mjs --levels 3,25 --lang hi --dark              # Hindi + dark
node tool/screenshot.mjs --onboarding                                # first-launch carousel
node tool/screenshot.mjs --dump                                      # print reachable buttons/labels
```

`--levels` takes *global* level numbers: 1–10 Beginner, 11–20 Advanced,
21–30 Expert, 31–40 Master. Then `Read` the PNGs in `shots/` to review them.

Rebuild whenever `lib/` changes; the script serves whatever is in `build/web`.
`PATH`/`NODE_PATH` are set by the session-start hook; if `flutter` is missing
run `.claude/hooks/session-start.sh` with `CLAUDE_CODE_REMOTE=true`.

## What it verifies

- Exit code 1 if the app logged a Flutter exception (e.g. a RenderFlex
  overflow) or a JS error while being driven — treat that as a failing test.
  CI runs the same script via `.github/actions/web-smoke` (see `ci.yml`,
  job "Web smoke & screenshots") and uploads `shots/` as an artifact.
- Rendering is faithful: Google Sans Flex ships in `assets/fonts/`, CanvasKit is
  bundled by `--no-web-resources-cdn`, and emoji/Devanagari fallback fonts are
  mirrored through the script's local server (cached in `build/font-cache/`).

## Extending the driver

Flutter web paints to a canvas, so the script enables Flutter's semantics
tree and targets widgets by accessible name: anything in
`Semantics(label: …, button: true)` or an `IconButton(tooltip: …)` is
reachable via `page.getByRole('button', { name: /…/ })`. Use `--dump` to see
what a screen exposes. Note the accessible name of a level tile is
"Level N" *plus* the tile's digit, so anchor regexes at the start only.

Preferences are seeded through `localStorage` (`flutter.<pref key>`, JSON
encoded) before boot — that is how onboarding is skipped and music muted.
Add new prefs there rather than clicking through the UI.

## Gotchas (all already handled in the script — keep them when porting)

- Headless Chromium cannot reach `*.gstatic.com` through the cloud proxy;
  Node and curl can. Hence bundled fonts + the `/__fonts/` mirror.
- Puzzle generation runs on the main thread on web (no isolates) — wait a
  couple of seconds after opening a level before screenshotting.
- `flutter create --platforms=web .` rewrites `.metadata` and drops the
  android/ios entries; restore them (done once, keep it that way).
