import 'package:flutter/material.dart';
import 'package:otakuplanner/themes/tokens.dart';

/// A manga panel: an ink border with cut corners and no shadow. Panels sit
/// 12px apart ([Space.gutter]) and are usually of unequal sizes.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Space.gutter),
    this.onTap,
    this.inverted = false,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Solid ink with paper text, for the one panel that should lead.
  final bool inverted;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    Widget body = Padding(padding: padding, child: child);
    if (inverted) {
      body = DefaultTextStyle.merge(
        style: TextStyle(color: c.paper),
        child: IconTheme.merge(data: IconThemeData(color: c.paper), child: body),
      );
    }
    final panel = Material(
      color: inverted ? c.ink : c.paper,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.panelAll,
        side: BorderSide(color: c.ink, width: Strokes.panel),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? body : InkWell(onTap: onTap, child: body),
    );
    return semanticLabel == null ? panel : Semantics(label: semanticLabel, child: panel);
  }
}

/// A plain hairline between rows inside a panel.
class InkRule extends StatelessWidget {
  const InkRule({super.key, this.indent = 0, this.strong = false});

  final double indent;

  /// Full-weight ink instead of the faint row rule.
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    return Container(
      margin: EdgeInsetsDirectional.only(start: indent),
      height: strong ? Strokes.panel : Strokes.hairline,
      color: strong ? c.ink : c.rule,
    );
  }
}
