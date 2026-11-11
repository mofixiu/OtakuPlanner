import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:otakuplanner/themes/tokens.dart';

/// The one small uppercase label: "TODAY · SAT 1 NOV", "STREAK", "CATEGORY".
class Kicker extends StatelessWidget {
  const Kicker(this.text, {super.key, this.stamped = false, this.color, this.textAlign});

  final String text;

  /// Prints the label in the stamp vermilion. Only for today and the streak.
  final bool stamped;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    return Text(
      text.toUpperCase(),
      textAlign: textAlign,
      style: context.type.labelSmall?.copyWith(
        color: color ?? (stamped ? c.stamp : c.inkMuted),
      ),
    );
  }
}

/// A hanko stamp in vermilion. It marks today, the streak and nothing else.
class Stamp extends StatelessWidget {
  const Stamp(this.text, {super.key, this.tilt = -3, this.filled = true, this.large = false});

  final String text;

  /// Degrees; a stamp is never quite straight.
  final double tilt;

  /// Solid vermilion with paper text, or a vermilion outline.
  final bool filled;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    final style = (large ? context.type.titleSmall : context.type.labelSmall)?.copyWith(
      color: filled ? c.paper : c.stamp,
      fontWeight: FontWeight.w700,
      letterSpacing: large ? 0.6 : 1.1,
      fontFeatures: TypeScale.tabular,
    );
    return Transform.rotate(
      angle: tilt * math.pi / 180,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: large ? 8 : 5, vertical: large ? 3 : 2),
        decoration: BoxDecoration(
          color: filled ? c.stamp : Colors.transparent,
          border: Border.all(color: c.stamp, width: Strokes.panel),
          borderRadius: Radii.controlAll,
        ),
        child: Text(text.toUpperCase(), style: style),
      ),
    );
  }
}
