/// One freehand stroke: an ordered list of points. Points are stored
/// **normalised** to 0..1 of the drawing surface, so a scribble drawn on one
/// device renders correctly on another (resolution-independent vector storage).
/// Pure Dart (only `dart:ui.Offset`).
library;

import 'dart:ui';

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
