import 'package:flutter/material.dart';
import 'package:otakuplanner/themes/tokens.dart';

/// The one segmented control: a strip of ink-bordered segments where the
/// chosen one is solid ink. Scrolls sideways when there are more segments
/// than fit, so it works for a user's own list of categories.
class InkSegmented<T> extends StatelessWidget {
  const InkSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.labelOf,
    this.fill = true,
  });

  final List<T> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final String Function(T)? labelOf;

  /// Stretch segments to fill the width when they fit.
  final bool fill;

  String _label(T v) => labelOf?.call(v) ?? v.toString();

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    return LayoutBuilder(
      builder: (context, box) {
        final style = context.type.labelMedium;
        final painter = TextPainter(textDirection: TextDirection.ltr);
        final widths = <double>[];
        for (final s in segments) {
          painter.text = TextSpan(text: _label(s), style: style?.copyWith(fontWeight: FontWeight.w600));
          painter.layout();
          widths.add(painter.width + 28 + Strokes.panel);
        }
        final natural = widths.fold<double>(0, (a, b) => a + b);
        painter.dispose();
        final fits = fill && natural <= box.maxWidth;

        final children = <Widget>[];
        for (var i = 0; i < segments.length; i++) {
          final value = segments[i];
          final on = value == selected;
          final cell = Semantics(
            selected: on,
            button: true,
            child: InkWell(
              onTap: () => onChanged(value),
              child: Container(
                height: 36,
                padding: EdgeInsets.symmetric(horizontal: fits ? 4 : 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on ? c.ink : Colors.transparent,
                  border: i == 0
                      ? null
                      : Border(left: BorderSide(color: c.ink, width: Strokes.panel)),
                ),
                child: Text(
                  _label(value),
                  maxLines: 1,
                  style: style?.copyWith(
                    color: on ? c.paper : c.ink,
                    fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
          // Spare room is shared out by label length, so long labels never clip.
          children.add(fits ? Expanded(flex: (widths[i] * 10).round(), child: cell) : cell);
        }

        final strip = Container(
          decoration: BoxDecoration(
            border: Border.all(color: c.ink, width: Strokes.panel),
            borderRadius: Radii.controlAll,
          ),
          child: ClipRRect(
            borderRadius: Radii.controlAll,
            child: Material(
              color: Colors.transparent,
              child: Row(mainAxisSize: fits ? MainAxisSize.max : MainAxisSize.min, children: children),
            ),
          ),
        );

        if (fits) return strip;
        return SingleChildScrollView(scrollDirection: Axis.horizontal, child: strip);
      },
    );
  }
}
