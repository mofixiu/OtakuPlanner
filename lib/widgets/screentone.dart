import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:otakuplanner/themes/tokens.dart';

/// Manga screentone: printed patterns instead of colour fills. Used for
/// progress tracks, locked badges and category marks.
enum Tone {
  dots,
  fineDots,
  diagonal,
  crosshatch,
  horizontal,
  vertical,
  grid;

  /// A steady pattern per category name, so "Work" always looks the same.
  static Tone forCategory(String category) {
    const order = [dots, diagonal, crosshatch, horizontal, fineDots, vertical, grid];
    final known = {
      'work': diagonal,
      'personal': dots,
      'study': horizontal,
      'anime': crosshatch,
      'manga': vertical,
      'gaming': grid,
      'health': fineDots,
    };
    final key = category.trim().toLowerCase();
    if (known.containsKey(key)) return known[key]!;
    final hash = key.codeUnits.fold<int>(0, (h, c) => (h * 31 + c) & 0x7fffffff);
    return order[hash % order.length];
  }
}

class ScreentonePainter extends CustomPainter {
  ScreentonePainter({required this.tone, required this.color, this.density = 1});

  final Tone tone;
  final Color color;

  /// 1 is the normal pitch; higher packs the pattern tighter.
  final double density;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final line = Paint()
      ..color = color
      ..strokeWidth = 1
      ..isAntiAlias = true;
    final dot = Paint()..color = color;
    final pitch = 5.0 / density;

    switch (tone) {
      case Tone.dots:
      case Tone.fineDots:
        final step = tone == Tone.dots ? pitch : pitch * 0.75;
        final r = tone == Tone.dots ? 1.1 : 0.75;
        var row = 0;
        for (var y = step / 2; y < size.height + step; y += step, row++) {
          final offset = row.isOdd ? step / 2 : 0.0;
          for (var x = step / 2 + offset; x < size.width + step; x += step) {
            canvas.drawCircle(Offset(x, y), r, dot);
          }
        }
      case Tone.diagonal:
      case Tone.crosshatch:
        final span = size.width + size.height;
        for (var d = -size.height; d < span; d += pitch) {
          canvas.drawLine(Offset(d, size.height), Offset(d + size.height, 0), line);
          if (tone == Tone.crosshatch) {
            canvas.drawLine(Offset(d, 0), Offset(d + size.height, size.height), line);
          }
        }
      case Tone.horizontal:
        for (var y = pitch / 2; y < size.height; y += pitch * 0.8) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
        }
      case Tone.vertical:
        for (var x = pitch / 2; x < size.width; x += pitch * 0.8) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
        }
      case Tone.grid:
        for (var y = pitch / 2; y < size.height; y += pitch) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
        }
        for (var x = pitch / 2; x < size.width; x += pitch) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
        }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(ScreentonePainter old) =>
      old.tone != tone || old.color != color || old.density != density;
}

/// Fills its area with a screentone in ink.
class Screentone extends StatelessWidget {
  const Screentone({
    super.key,
    this.tone = Tone.dots,
    this.opacity = 0.55,
    this.density = 1,
    this.child,
  });

  final Tone tone;
  final double opacity;
  final double density;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ScreentonePainter(
        tone: tone,
        density: density,
        color: context.ink.ink.withValues(alpha: opacity),
      ),
      child: child ?? const SizedBox.expand(),
    );
  }
}

/// A progress track: an ink outline, solid ink for what's done and
/// screentone for what's left.
class ToneBar extends StatelessWidget {
  const ToneBar({super.key, required this.value, this.height = 10, this.tone = Tone.dots});

  /// 0 to 1.
  final double value;
  final double height;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    final v = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return Semantics(
      value: '${(v * 100).round()}%',
      child: Container(
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: c.ink, width: Strokes.panel),
          borderRadius: Radii.controlAll,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(math.max(0, Radii.control - 1)),
          child: LayoutBuilder(
            builder: (context, box) {
              final filled = box.maxWidth * v;
              return Stack(
                children: [
                  Positioned.fill(child: Screentone(tone: tone, opacity: 0.45)),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: filled,
                    child: ColoredBox(color: c.ink),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A small square printed with a category's screentone.
class ToneSwatch extends StatelessWidget {
  const ToneSwatch({super.key, required this.category, this.size = 14});

  final String category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: c.ink, width: Strokes.hairline),
        borderRadius: Radii.controlAll,
      ),
      child: ClipRRect(
        borderRadius: Radii.controlAll,
        child: Screentone(tone: Tone.forCategory(category), opacity: 0.85, density: 1.4),
      ),
    );
  }
}
