import 'package:flutter/material.dart';
import 'package:otakuplanner/themes/tokens.dart';
import 'package:otakuplanner/widgets/kicker.dart';
import 'package:otakuplanner/widgets/panel.dart';
import 'package:otakuplanner/widgets/screentone.dart';

/// One labelled value in a [FieldGrid].
class FieldCell {
  const FieldCell(this.label, this.value, {this.wide = false});

  final String label;
  final Widget value;

  /// Take the whole row instead of half.
  final bool wide;
}

/// Field names and values in a ruled two-column grid inside a panel, like a
/// form filled in by hand.
class FieldGrid extends StatelessWidget {
  const FieldGrid({super.key, required this.fields});

  final List<FieldCell> fields;

  /// A plain text value, with the category's screentone when [tone] is set.
  static FieldCell text(BuildContext context, String label, String value,
      {String? tone, bool wide = false}) {
    return FieldCell(
      label,
      Row(
        children: [
          if (tone != null) ...[
            ToneSwatch(category: tone, size: 12),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              value.isEmpty ? '—' : value,
              style: context.type.titleMedium?.copyWith(fontFeatures: TypeScale.tabular),
            ),
          ),
        ],
      ),
      wide: wide,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rule = context.ink.rule;
    final rows = <List<FieldCell>>[];
    for (final f in fields) {
      if (f.wide || rows.isEmpty || rows.last.length == 2 || rows.last.first.wide) {
        rows.add([f]);
      } else {
        rows.last.add(f);
      }
    }

    Widget cell(FieldCell f) => Padding(
          padding: const EdgeInsets.all(Space.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Kicker(f.label),
              const SizedBox(height: Space.xs),
              f.value,
            ],
          ),
        );

    return Panel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const InkRule(),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: cell(rows[i][0])),
                  if (!rows[i][0].wide) ...[
                    Container(width: Strokes.hairline, color: rule),
                    Expanded(child: rows[i].length > 1 ? cell(rows[i][1]) : const SizedBox.shrink()),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
