import 'package:flutter/material.dart';

import '../models/stroke.dart';
import '../ui/colors.dart';

/// A freehand drawing surface. Captures pan gestures as vector [Stroke]s
/// (points normalised to the surface size) and reports the full stroke list up
/// via [onChanged]. The parent owns the stroke list, so undo/clear are just
/// list edits from outside.
class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({
    super.key,
    required this.strokes,
    required this.onChanged,
  });

  final List<Stroke> strokes;
  final ValueChanged<List<Stroke>> onChanged;

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  List<Offset>? _active;

  Offset _normalise(Offset local, Size size) => Offset(
        (local.dx / size.width).clamp(0.0, 1.0),
        (local.dy / size.height).clamp(0.0, 1.0),
      );

  void _start(Offset local, Size size) =>
      setState(() => _active = [_normalise(local, size)]);

  void _update(Offset local, Size size) =>
      setState(() => _active!.add(_normalise(local, size)));

  void _end() {
    final active = _active;
    _active = null;
    // A quick tap with no drag isn't a stroke; drop it.
    if (active != null && active.length > 1) {
      widget.onChanged([...widget.strokes, Stroke(active)]);
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onPanStart: (d) => _start(d.localPosition, size),
          onPanUpdate: (d) => _update(d.localPosition, size),
          onPanEnd: (_) => _end(),
          child: CustomPaint(
            painter: _StrokePainter(
              strokes: widget.strokes,
              active: _active == null ? null : Stroke(_active!),
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class _StrokePainter extends CustomPainter {
  _StrokePainter({required this.strokes, this.active});

  final List<Stroke> strokes;
  final Stroke? active;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = notesInk
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      _draw(canvas, size, stroke, paint);
    }
    if (active != null) _draw(canvas, size, active!, paint);
  }

  void _draw(Canvas canvas, Size size, Stroke stroke, Paint paint) {
    if (stroke.points.length < 2) return;
    final path = Path();
    final first = _denormalise(stroke.points.first, size);
    path.moveTo(first.dx, first.dy);
    for (var i = 1; i < stroke.points.length; i++) {
      final p = _denormalise(stroke.points[i], size);
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  Offset _denormalise(Offset n, Size size) =>
      Offset(n.dx * size.width, n.dy * size.height);

  @override
  bool shouldRepaint(_StrokePainter old) => true;
}
