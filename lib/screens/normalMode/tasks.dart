import 'package:flutter/material.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/screens/normalMode/task_automation.dart';
import 'package:otakuplanner/screens/normalMode/task_dialog2.dart';
import 'package:otakuplanner/shared/task_actions.dart';
import 'package:otakuplanner/widgets/bottomNavBar.dart';
import 'package:otakuplanner/widgets/ink_kit.dart';
import 'package:provider/provider.dart';

/// Every task, grouped by day: today and what's coming first, then earlier
/// days. Filter by the user's own categories, or search.
class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  String _category = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _search = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAutomation() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskAutomation()));
  }

  /// A repeating task is stored once per date. Show it once, on its next
  /// date (or its last one if they've all passed).
  static Map<DateTime, List<Task>> _days(Map<DateTime, List<Task>> all, DateTime today) {
    final dates = all.keys.toList()..sort();
    final repeats = <String, List<DateTime>>{};
    for (final date in dates) {
      for (final t in all[date]!) {
        if (t.isRecurring) repeats.putIfAbsent(t.title, () => []).add(date);
      }
    }
    final chosen = {
      for (final e in repeats.entries)
        e.key: e.value.firstWhere((d) => !d.isBefore(today), orElse: () => e.value.last),
    };
    return {
      for (final date in dates)
        date: [
          for (final t in all[date]!)
            if (!t.isRecurring || chosen[t.title] == date) t,
        ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final today = PlannerFormat.dateOnly(DateTime.now());
    final days = _days(provider.tasks, today);

    // The filters are the categories this user actually uses, busiest first.
    final counts = <String, int>{};
    for (final list in days.values) {
      for (final t in list) {
        counts[t.category] = (counts[t.category] ?? 0) + 1;
      }
    }
    final categories = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    if (_category != 'All' && !categories.contains(_category)) _category = 'All';

    bool matches(Task t) =>
        (_category == 'All' || t.category == _category) &&
        (_search.isEmpty ||
            t.title.toLowerCase().contains(_search) ||
            t.category.toLowerCase().contains(_search));

    final upcoming = <MapEntry<DateTime, List<Task>>>[];
    final earlier = <MapEntry<DateTime, List<Task>>>[];
    for (final date in days.keys) {
      final list = days[date]!.where(matches).toList()
        ..sort((a, b) => PlannerFormat.minutes(a.time).compareTo(PlannerFormat.minutes(b.time)));
      if (list.isEmpty) continue;
      (date.isBefore(today) ? earlier : upcoming).add(MapEntry(date, list));
    }
    upcoming.sort((a, b) => a.key.compareTo(b.key));
    earlier.sort((a, b) => b.key.compareTo(a.key));

    final hasAny = counts.isNotEmpty;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const PlannerAppBar(),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(Space.page, Space.l, Space.page, Space.l),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: Text('Tasks', style: context.type.displaySmall)),
                InkButton(
                  label: 'Automate',
                  icon: Icons.edit_note,
                  small: true,
                  onPressed: _openAutomation,
                ),
              ],
            ),
            const SizedBox(height: Space.m),
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search tasks',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _search.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: _searchController.clear,
                      ),
              ),
            ),
            if (categories.length > 1) ...[
              const SizedBox(height: Space.gutter),
              InkSegmented<String>(
                segments: ['All', ...categories],
                selected: _category,
                onChanged: (v) => setState(() => _category = v),
              ),
            ],
            const SizedBox(height: Space.m),
            if (!hasAny)
              EmptyState(
                message: 'No tasks yet. Type one in plain English and it lands on your calendar.',
                action: InkButton.secondary(label: 'Automate a task', small: true, onPressed: _openAutomation),
              )
            else if (upcoming.isEmpty && earlier.isEmpty)
              EmptyState(
                message: _search.isEmpty
                    ? 'No $_category tasks.'
                    : 'Nothing matches “${_searchController.text.trim()}”.',
              )
            else ...[
              for (final day in upcoming) _DayGroup(day: day.key, tasks: day.value, today: today),
              if (earlier.isNotEmpty) ...[
                const SizedBox(height: Space.s),
                const InkRule(strong: true),
                const SizedBox(height: Space.m),
                const Kicker('Earlier'),
                const SizedBox(height: Space.s),
                for (final day in earlier) _DayGroup(day: day.key, tasks: day.value, today: today),
              ],
            ],
          ],
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      ),
    );
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({required this.day, required this.tasks, required this.today});

  final DateTime day;
  final List<Task> tasks;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final isToday = PlannerFormat.isSameDay(day, today);
    final done = tasks.where((t) => t.isChecked).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Kicker(PlannerFormat.kickerDay(day, now: today), stamped: isToday)),
              Text(
                '$done/${tasks.length}',
                style: context.type.labelSmall?.copyWith(fontFeatures: TypeScale.tabular),
              ),
            ],
          ),
          const SizedBox(height: Space.xs + 2),
          Panel(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              children: [
                for (var i = 0; i < tasks.length; i++) ...[
                  if (i > 0) const InkRule(indent: 52),
                  TaskRow(
                    title: tasks[i].title,
                    category: tasks[i].category,
                    time: tasks[i].time,
                    done: tasks[i].isChecked,
                    repeats: tasks[i].isRecurring,
                    onToggle: (v) => TaskActions.setDone(context, day, tasks[i], v),
                    onTap: () => showTaskDetails(context, day, tasks[i]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A task's details as a grid of fields, with Edit, Done and Delete.
void showTaskDetails(BuildContext context, DateTime day, Task task) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (sheet) {
      final fields = [
        FieldGrid.text(sheet, 'Category', task.category, tone: task.category),
        FieldGrid.text(sheet, 'Status', task.isChecked ? 'Done' : 'To do'),
        FieldGrid.text(sheet, 'Day', PlannerFormat.day(day)),
        FieldGrid.text(sheet, 'Time', PlannerFormat.time(task.time)),
        if (task.isRecurring) FieldGrid.text(sheet, 'Repeats', 'Yes', wide: true),
      ];
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Space.page, Space.m, Space.page, Space.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Kicker(PlannerFormat.kickerDay(day), stamped: PlannerFormat.relativeDay(day) == 'Today'),
            const SizedBox(height: Space.xs),
            Text(task.title, style: sheet.type.headlineSmall),
            const SizedBox(height: Space.m),
            FieldGrid(fields: fields),
            const SizedBox(height: Space.l),
            InkButton(
              label: 'Edit',
              expand: true,
              onPressed: () {
                Navigator.pop(sheet);
                showTaskDialog(
                  context: context,
                  dialogTitle: 'Edit task',
                  initialTitle: task.title,
                  initialCategory: task.category,
                  initialTime: task.time,
                  onSubmit: (title, category, time) => TaskActions.update(
                    context,
                    day,
                    task,
                    title: title,
                    category: category,
                    time: time,
                  ),
                );
              },
            ),
            const SizedBox(height: Space.s),
            Row(
              children: [
                Expanded(
                  child: InkButton.secondary(
                    label: task.isChecked ? 'Mark as to do' : 'Mark as done',
                    onPressed: () {
                      Navigator.pop(sheet);
                      TaskActions.setDone(context, day, task, !task.isChecked);
                    },
                  ),
                ),
                const SizedBox(width: Space.gutter),
                Expanded(
                  child: InkButton.secondary(
                    label: 'Delete',
                    onPressed: () {
                      Navigator.pop(sheet);
                      TaskActions.confirmDelete(context, day, task);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
