/// Attribution entries for bundled background music (CC-BY requires crediting
/// each track). Populated in the polish stage when licensed tracks are added.
library;

class TrackCredit {
  const TrackCredit({
    required this.title,
    required this.artist,
    required this.license,
    required this.sourceUrl,
  });

  final String title;
  final String artist;
  final String license;
  final String sourceUrl;
}

/// The bundled tracks and their attributions. Empty until tracks are added.
const List<TrackCredit> audioCredits = <TrackCredit>[];
