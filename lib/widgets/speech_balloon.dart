import 'package:flutter/material.dart';
import 'package:otakuplanner/themes/tokens.dart';

enum BalloonTail { left, right, none }

/// A speech balloon outline: rounded body and a short tail, drawn as one
/// ink line like a manga balloon.
class BalloonBorder extends ShapeBorder {
  const BalloonBorder({
    this.side = const BorderSide(width: Strokes.panel),
    this.radius = 14,
    this.tail = BalloonTail.left,
    this.tailSize = 8,
    this.tailTop = 12,
  });

  final BorderSide side;
  final double radius;
  final BalloonTail tail;
  final double tailSize;

  /// Distance from the top of the balloon to the tail.
  final double tailTop;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(
        left: tail == BalloonTail.left ? tailSize : 0,
        right: tail == BalloonTail.right ? tailSize : 0,
      );

  Rect _body(Rect rect) => Rect.fromLTRB(
        rect.left + (tail == BalloonTail.left ? tailSize : 0),
        rect.top,
        rect.right - (tail == BalloonTail.right ? tailSize : 0),
        rect.bottom,
      );

  /// One continuous outline, body and tail together. (Path.combine isn't
  /// available on every renderer, so the tail is drawn into the edge.)
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final body = _body(rect);
    final r = radius.clamp(0.0, body.shortestSide / 2);
    final arc = Radius.circular(r);
    final hasTail = tail != BalloonTail.none && body.height >= 2 * r + tailSize;
    final y = hasTail
        ? (body.top + tailTop).clamp(body.top + r, body.bottom - r - tailSize).toDouble()
        : 0.0;
    final path = Path()
      ..moveTo(body.left + r, body.top)
      ..lineTo(body.right - r, body.top)
      ..arcToPoint(Offset(body.right, body.top + r), radius: arc);
    if (hasTail && tail == BalloonTail.right) {
      path
        ..lineTo(body.right, y)
        ..lineTo(rect.right, y + tailSize * 0.25)
        ..lineTo(body.right, y + tailSize);
    }
    path
      ..lineTo(body.right, body.bottom - r)
      ..arcToPoint(Offset(body.right - r, body.bottom), radius: arc)
      ..lineTo(body.left + r, body.bottom)
      ..arcToPoint(Offset(body.left, body.bottom - r), radius: arc);
    if (hasTail && tail == BalloonTail.left) {
      path
        ..lineTo(body.left, y + tailSize)
        ..lineTo(rect.left, y + tailSize * 0.25)
        ..lineTo(body.left, y);
    }
    path
      ..lineTo(body.left, body.top + r)
      ..arcToPoint(Offset(body.left + r, body.top), radius: arc)
      ..close();
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect.deflate(side.width / 2), textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    final paint = side.toPaint()..strokeJoin = StrokeJoin.round;
    canvas.drawPath(getOuterPath(rect.deflate(side.width / 2)), paint);
  }

  @override
  ShapeBorder scale(double t) => BalloonBorder(
        side: side.scale(t),
        radius: radius * t,
        tail: tail,
        tailSize: tailSize * t,
        tailTop: tailTop * t,
      );
}

/// Text or any child inside a speech balloon.
class SpeechBalloon extends StatelessWidget {
  const SpeechBalloon({
    super.key,
    required this.child,
    this.tail = BalloonTail.left,
    this.padding = const EdgeInsets.fromLTRB(14, 10, 14, 10),
    this.filled = false,
  });

  final Widget child;
  final BalloonTail tail;
  final EdgeInsetsGeometry padding;

  /// Solid ink with paper text.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    final shape = BalloonBorder(
      side: BorderSide(color: c.ink, width: Strokes.panel),
      tail: tail,
    );
    Widget body = Padding(padding: padding, child: child);
    if (filled) {
      body = DefaultTextStyle.merge(style: TextStyle(color: c.paper), child: body);
    }
    return Material(
      color: filled ? c.ink : c.paper,
      shape: shape,
      child: Padding(padding: shape.dimensions, child: body),
    );
  }
}
