import 'package:flutter/material.dart';
import 'package:otakuplanner/shared/formats.dart';
import 'package:otakuplanner/themes/tokens.dart';
import 'package:otakuplanner/widgets/screentone.dart';

/// A dense task row: a square check, the title, and a meta line with the
/// category's screentone, the category and the time. Rows sit inside a
/// panel, split by hairlines, rather than each in its own card.
class TaskRow extends StatelessWidget {
  const TaskRow({
    super.key,
    required this.title,
    required this.category,
    required this.time,
    required this.done,
    this.onToggle,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.repeats = false,
    this.dayLabel,
  });

  final String title;
  final String category;

  /// Any stored time; shown as "4:20 PM".
  final String time;
  final bool done;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool repeats;

  /// Optional day in the meta line, e.g. "Sat 1 Nov".
  final String? dayLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    final meta = [
      category,
      if (dayLabel != null) dayLabel!,
      PlannerFormat.time(time),
      if (repeats) 'Repeats',
    ].where((s) => s.isNotEmpty).join(' · ');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 6, 0, 6),
        child: Row(
          children: [
            Semantics(
              label: done ? 'Mark $title as not done' : 'Mark $title as done',
              child: SizedBox(
                width: 40,
                height: 40,
                child: Checkbox(
                  value: done,
                  onChanged: onToggle == null ? null : (v) => onToggle!(v ?? false),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.titleMedium?.copyWith(
                      color: done ? c.inkMuted : c.ink,
                      decoration: done ? TextDecoration.lineThrough : null,
                      decorationColor: c.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      ToneSwatch(category: category, size: 10),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.type.bodySmall?.copyWith(fontFeatures: TypeScale.tabular),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                tooltip: 'More for $title',
                icon: Icon(Icons.more_horiz, color: c.ink),
                onSelected: (v) => v == 'edit' ? onEdit?.call() : onDelete?.call(),
                itemBuilder: (_) => [
                  if (onEdit != null) const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (onDelete != null) const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              )
            else
              const SizedBox(width: Space.gutter),
          ],
        ),
      ),
    );
  }
}
