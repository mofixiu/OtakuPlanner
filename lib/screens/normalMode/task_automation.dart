import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/providers/category_provider.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/request.dart';
import 'package:otakuplanner/services/task_text_parser.dart';
import 'package:otakuplanner/shared/category_icons.dart';
import 'package:otakuplanner/shared/notifications.dart';
import 'package:otakuplanner/shared/task_actions.dart';
import 'package:otakuplanner/widgets/ink_kit.dart';
import 'package:provider/provider.dart';

/// Type a task in plain English ("Watch Solo Leveling every Friday at 7 PM")
/// and see what was understood as you type, then add it to the calendar.
class TaskAutomation extends StatefulWidget {
  const TaskAutomation({super.key});

  @override
  State<TaskAutomation> createState() => _TaskAutomationState();
}

class _TaskAutomationState extends State<TaskAutomation> {
  final TextEditingController _taskController = TextEditingController();
  ParsedTask? _parsed;
  String? _category;
  bool _saving = false;

  static const _examples = [
    'Watch Solo Leveling every Friday at 7 PM',
    'Study Japanese every Monday at 3 PM',
    'Send the essay by 5pm tomorrow',
  ];

  @override
  void initState() {
    super.initState();
    _taskController.addListener(_read);
  }

  @override
  void dispose() {
    _taskController.removeListener(_read);
    _taskController.dispose();
    super.dispose();
  }

  void _read() {
    final text = _taskController.text.trim();
    final parsed = text.isEmpty ? null : parseTaskText(text);
    setState(() {
      // A category the user picked by hand stays picked while they edit.
      if (parsed == null || _parsed == null || _category == _parsed!.category) {
        _category = parsed?.category;
      }
      _parsed = parsed;
    });
  }

  /// The dates the task lands on: one, or the next 50 for a repeat.
  List<DateTime> _taskDates(ParsedTask p) {
    final today = PlannerFormat.dateOnly(DateTime.now());
    if (p.date != null && !p.isRecurring) return [p.date!];
    final count = p.isRecurring ? 50 : 1;
    if (p.recurrence == Recurrence.daily) {
      return [for (var i = 0; i < count; i++) DateTime(today.year, today.month, today.day + i)];
    }
    if (p.weekday == null) return [today];
    var day = today;
    while (day.weekday != p.weekday) {
      day = DateTime(day.year, day.month, day.day + 1);
    }
    return [for (var i = 0; i < count; i++) DateTime(day.year, day.month, day.day + 7 * i)];
  }

  String _dayLabel(ParsedTask p) {
    final first = _taskDates(p).first;
    return switch (p.recurrence) {
      Recurrence.daily => 'Every day from ${PlannerFormat.day(first)}',
      Recurrence.weekly => 'Every ${p.dayName} from ${PlannerFormat.day(first)}',
      Recurrence.none => PlannerFormat.relativeDay(first) == null
          ? PlannerFormat.day(first)
          : '${PlannerFormat.relativeDay(first)}, ${PlannerFormat.day(first)}',
    };
  }

  Future<void> _create() async {
    final p = _parsed;
    final category = _category;
    if (p == null || !p.hasTime || category == null || _saving) return;
    setState(() => _saving = true);

    final dates = _taskDates(p);
    if (!p.isRecurring) {
      await TaskActions.add(context, day: dates.first, title: p.title, category: category, time: p.time12);
      if (mounted) Navigator.pop(context, true);
      return;
    }

    // A repeat shows on each date in the planner and is saved once as a
    // recurring task.
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    for (final date in dates) {
      taskProvider.addTask(
        date,
        Task(
          date: date.toIso8601String(),
          title: p.title,
          category: category,
          time: p.time12,
          color: Task.getRandomColor(),
          icon: categoryIconFor(category),
          isRecurring: true,
        ),
      );
    }
    try {
      await saveRecurringTaskToDatabase({
        'user_id': userId,
        'title': p.title,
        'category': category,
        'time': PlannerFormat.to24(p.time12),
        'date': TaskActions.dateKey(dates.first),
        'completed': false,
        'frequency': p.recurrence == Recurrence.daily ? 'daily' : 'weekly',
      });
    } catch (e) {
      log('Error saving recurring task: $e');
    }
    if (!mounted) return;
    NotificationService.showToast(context, 'Task automated', "'${p.title}' now repeats on your calendar");
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    final p = _parsed;
    final known = Provider.of<CategoryProvider>(context).categoriesForDropdown;
    final options = [...known, if (_category != null && !known.contains(_category)) _category!];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const InkBackBar(title: 'Automate a task'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(Space.page, Space.l, Space.page, Space.l),
          children: [
            Text('Type it the way you’d say it', style: context.type.headlineSmall),
            const SizedBox(height: Space.xs),
            Text(
              'Say what, when and how often. Repeats go on your calendar for the next 50 times.',
              style: context.type.bodyMedium?.copyWith(color: c.inkMuted),
            ),
            const SizedBox(height: Space.m),
            TextField(
              controller: _taskController,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Watch Solo Leveling every Friday at 7 PM'),
            ),
            if (p == null) ...[
              const SizedBox(height: Space.l),
              const Kicker('Try one'),
              const SizedBox(height: Space.s),
              Panel(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < _examples.length; i++) ...[
                      if (i > 0) const InkRule(),
                      InkWell(
                        onTap: () => _taskController.text = _examples[i],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Space.gutter, vertical: 14),
                          child: Row(
                            children: [
                              Expanded(child: Text(_examples[i], style: context.type.bodyMedium)),
                              Icon(Icons.north_west, size: 16, color: c.inkMuted),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: Space.l),
              const Kicker('What it read'),
              const SizedBox(height: Space.s),
              FieldGrid(
                fields: [
                  FieldGrid.text(context, 'Task', p.title, wide: true),
                  FieldGrid.text(context, 'Day', _dayLabel(p)),
                  FieldGrid.text(context, 'Time', p.hasTime ? p.time12 : ''),
                  FieldGrid.text(
                    context,
                    'Repeats',
                    switch (p.recurrence) {
                      Recurrence.none => 'No',
                      Recurrence.daily => 'Daily',
                      Recurrence.weekly => 'Weekly',
                    },
                  ),
                  FieldCell(
                    'Category',
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _category,
                        isExpanded: true,
                        isDense: true,
                        dropdownColor: c.paper,
                        style: context.type.titleMedium,
                        items: [
                          for (final cat in options)
                            DropdownMenuItem(
                              value: cat,
                              child: Row(
                                children: [
                                  ToneSwatch(category: cat, size: 12),
                                  const SizedBox(width: 6),
                                  Flexible(child: Text(cat, overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ),
                        ],
                        onChanged: (v) => setState(() => _category = v),
                      ),
                    ),
                  ),
                ],
              ),
              if (!p.hasTime) ...[
                const SizedBox(height: Space.s),
                Text(
                  'Add a time, like 7 PM or 19:30, to put it on the calendar.',
                  style: context.type.bodySmall?.copyWith(color: c.ink),
                ),
              ],
            ],
            const SizedBox(height: Space.l),
            InkButton(
              label: p != null && p.isRecurring ? 'Add the repeats to my calendar' : 'Add to my calendar',
              expand: true,
              loading: _saving,
              onPressed: p != null && p.hasTime && _category != null ? _create : null,
            ),
          ],
        ),
      ),
    );
  }
}
