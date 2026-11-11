import 'package:flutter/material.dart';
import 'package:otakuplanner/themes/tokens.dart';

/// The logo mark (calendar and mascot) without the wordmark.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.height = 30});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/mark.png',
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'OtakuPlanner',
    );
  }
}

enum MascotArt {
  /// The mascot's face, traced from the logo.
  face('assets/images/mascot_line.png'),

  /// The logo's calendar, traced.
  calendar('assets/images/calendar_line.png');

  const MascotArt(this.asset);
  final String asset;
}

/// Line art from the logo, printed in the current ink so it works on both
/// cream and night.
class MascotLine extends StatelessWidget {
  const MascotLine({super.key, this.art = MascotArt.face, this.height = 96, this.color});

  final MascotArt art;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      art.asset,
      height: height,
      fit: BoxFit.contain,
      color: color ?? context.ink.ink,
      colorBlendMode: BlendMode.srcIn,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: true,
    );
  }
}

/// An empty state: mascot line art and one sentence in ink. An optional
/// action sits under it.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.art = MascotArt.face,
    this.action,
    this.artHeight = 84,
    this.padding = const EdgeInsets.symmetric(vertical: Space.l, horizontal: Space.m),
  });

  final String message;
  final MascotArt art;
  final Widget? action;
  final double artHeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MascotLine(art: art, height: artHeight),
          const SizedBox(height: Space.gutter),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.type.bodyMedium,
          ),
          if (action != null) ...[
            const SizedBox(height: Space.gutter),
            action!,
          ],
        ],
      ),
    );
  }
}
