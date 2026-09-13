@AGENTS.md

## Claude Code

The repository guidelines live in `AGENTS.md` (imported above) so that Codex,
Claude Code, and other agents share one set of rules. Put new guidance there;
keep this file for Claude-only notes.

- Cloud sessions: `.claude/hooks/session-start.sh` installs the SDK pinned in
  `.flutter-version` and runs `pub get` + `gen-l10n`; `.claude/skills/run`
  drives the web-build screenshot harness for visual checks.
