/// A word riddle used to gate a hint. Pure Dart (no Flutter).
library;

class Riddle {
  const Riddle({
    required this.id,
    required this.prompt,
    required this.answers,
  });

  final String id;

  /// The riddle text shown to the player.
  final String prompt;

  /// Accepted answers (compared after normalisation).
  final List<String> answers;

  /// Whether [input] matches any accepted answer (case/space/nukta-insensitive).
  bool accepts(String input) {
    final normalized = _normalize(input);
    return normalized.isNotEmpty &&
        answers.any((a) => _normalize(a) == normalized);
  }

  static final RegExp _spaces = RegExp(r'\s+');
  static final RegExp _punctuation = RegExp(r'''[.!?,;:'"।]''');

  static String _normalize(String s) => s
      .trim()
      .toLowerCase()
      .replaceAll('़', '') // Devanagari nukta (प्याज़ == प्याज)
      .replaceAll(_punctuation, '')
      .replaceAll(_spaces, ' ')
      .trim();
}
