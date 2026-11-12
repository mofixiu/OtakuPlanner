import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Manga focus lines: thin ink wedges running in from the panel edges and
/// stopping short of a clear oval around the subject, which pulls the eye to it.
class FocusLinesPainter extends CustomPainter {
  FocusLinesPainter({
    required this.color,
    required this.focus,
    required this.clear,
    this.count = 120,
    this.seed = 11,
  });

  final Color color;

  /// The centre of the clear oval, from the top-left corner.
  final Offset focus;

  /// The size of the clear oval around the subject.
  final Size clear;

  final int count;

  /// The same seed draws the same lines every time.
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final corners = [Offset.zero, Offset(size.width, 0), Offset(0, size.height), Offset(size.width, size.height)];
    final reach = corners.map((p) => (p - focus).distance).reduce(math.max) + 8;
    final rx = clear.width / 2;
    final ry = clear.height / 2;
    final random = math.Random(seed);
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;

    for (var i = 0; i < count; i++) {
      final angle = (i + random.nextDouble()) / count * 2 * math.pi;
      final dir = Offset(math.cos(angle), math.sin(angle));
      // Where this direction leaves the oval, then a little further, unevenly.
      final edge = 1 / math.sqrt(math.pow(dir.dx / rx, 2) + math.pow(dir.dy / ry, 2));
      final start = edge * (1 + random.nextDouble() * 0.45);
      final width = 0.8 + random.nextDouble() * 2.6;
      final side = Offset(-dir.dy, dir.dx) * (width / 2);
      final tip = focus + dir * start;
      final end = focus + dir * reach;
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(end.dx + side.dx, end.dy + side.dy)
          ..lineTo(end.dx - side.dx, end.dy - side.dy)
          ..close(),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(FocusLinesPainter old) =>
      old.color != color ||
      old.focus != focus ||
      old.clear != clear ||
      old.count != count ||
      old.seed != seed;
}
