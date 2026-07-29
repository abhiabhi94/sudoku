/// A per-level scratchpad note. Holds free text AND optional freehand (vector)
/// scribbles, so a player can jot candidates or sketch reasoning. Pure Dart
/// (only `dart:ui.Offset` for points); persisted as JSON by [NotesRepository].
library;

import 'dart:ui';

/// One freehand stroke: an ordered list of points. Points are stored
/// **normalised** to 0..1 of the drawing surface, so a note drawn on one device
/// renders correctly on another (resolution-independent vector storage).
class Stroke {
  const Stroke(this.points);

  final List<Offset> points;

  /// Flattens the points to `[x0, y0, x1, y1, …]` for compact JSON.
  List<double> toFlat() {
    final flat = <double>[];
    for (final p in points) {
      flat
        ..add(p.dx)
        ..add(p.dy);
    }
    return flat;
  }

  factory Stroke.fromFlat(List<double> flat) {
    final points = <Offset>[];
    for (var i = 0; i + 1 < flat.length; i += 2) {
      points.add(Offset(flat[i], flat[i + 1]));
    }
    return Stroke(points);
  }
}

class LevelNote {
  const LevelNote({this.text = '', this.strokes = const []});

  final String text;
  final List<Stroke> strokes;

  static const LevelNote empty = LevelNote();

  bool get isEmpty => text.trim().isEmpty && strokes.isEmpty;
  bool get isNotEmpty => !isEmpty;

  LevelNote copyWith({String? text, List<Stroke>? strokes}) => LevelNote(
        text: text ?? this.text,
        strokes: strokes ?? this.strokes,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        't': text.trim(),
        's': strokes.map((s) => s.toFlat()).toList(),
      };

  factory LevelNote.fromJson(Map<String, dynamic> json) => LevelNote(
        text: (json['t'] as String?) ?? '',
        strokes: ((json['s'] as List?) ?? const [])
            .map((e) => Stroke.fromFlat(
                (e as List).map((n) => (n as num).toDouble()).toList()))
            .toList(),
      );
}
