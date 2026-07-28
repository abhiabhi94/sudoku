/// Small formatting helpers. Pure Dart.
library;

/// Formats a duration in milliseconds as `m:ss` (e.g. 1:07).
String formatDurationMs(int milliseconds) {
  final totalSeconds = (milliseconds < 0 ? 0 : milliseconds) ~/ 1000;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
