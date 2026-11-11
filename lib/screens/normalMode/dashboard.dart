import 'package:flutter/material.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/normalMode/achievements.dart';
import 'package:otakuplanner/screens/normalMode/task_dialog2.dart';
import 'package:otakuplanner/shared/in_app_reminder_service.dart';
import 'package:otakuplanner/shared/planner_stats.dart';
import 'package:otakuplanner/shared/quote_service.dart';
import 'package:otakuplanner/shared/task_actions.dart';
import 'package:otakuplanner/widgets/bottomNavBar.dart';
import 'package:otakuplanner/widgets/ink_kit.dart';
import 'package:provider/provider.dart';

/// Today: the greeting, three stats, a line from an anime, and today's
/// tasks split into morning, afternoon and night.
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  /// Null shows the whole day.
  DayPart? _part;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      InAppReminderService.initialize(context, Provider.of<TaskProvider>(context, listen: false));
    });
  }

  @override
  void dispose() {
    InAppReminderService.dispose();
    super.dispose();
  }

  void _addTask() {
    showTaskDialog(
      context: context,
      dialogTitle: 'New task for today',
      onSubmit: (title, category, time) => TaskActions.add(
        context,
        day: DateTime.now(),
        title: title,
        category: category,
        time: time,
      ),
    );
  }

  void _editTask(DateTime day, Task task) {
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
  }

  @override
  Widget build(BuildContext context) {
    final stats = PlannerStats(Provider.of<TaskProvider>(context).tasks);
    final username = Provider.of<UserProvider>(context).username;
    final name = username.isEmpty
        ? ''
        : '${username[0].toUpperCase()}${username.substring(1).toLowerCase()}';

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: const PlannerAppBar(),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(Space.page, Space.l, Space.page, Space.l),
          children: [
            Kicker(PlannerFormat.kickerDay(stats.today), stamped: true),
            const SizedBox(height: Space.xs),
            Text(
              name.isEmpty
                  ? '${PlannerFormat.greeting(stats.now)}.'
                  : '${PlannerFormat.greeting(stats.now)}, $name.',
              style: context.type.displaySmall,
            ),
            const SizedBox(height: Space.m),
            _StatsRow(stats: stats),
            const SizedBox(height: Space.gutter),
            _QuotePanel(quote: QuoteService.getQuote(now: stats.now)),
            const SizedBox(height: Space.gutter),
            _TodayPanel(
              stats: stats,
              part: _part,
              onPart: (p) => setState(() => _part = p),
              onAdd: _addTask,
              onEdit: (t) => _editTask(stats.today, t),
            ),
          ],
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      ),
    );
  }
}

/// Done today, the streak and badges, side by side in unequal panels.
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final PlannerStats stats;

  @override
  Widget build(BuildContext context) {
    final total = stats.todayTasks.length;
    final done = stats.todayDone;
    final streak = stats.currentStreak;
    final badges = stats.badgesEarned;
    final statStyle = TypeScale.stat(context.ink.ink);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 11,
            child: Panel(
              semanticLabel: '$done of $total tasks done today',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker('Done today'),
                  const SizedBox(height: Space.s),
                  Text.rich(
                    TextSpan(
                      text: '$done',
                      children: [
                        TextSpan(
                          text: '/$total',
                          style: statStyle.copyWith(color: context.ink.inkMuted),
                        ),
                      ],
                    ),
                    style: statStyle,
                  ),
                  const Spacer(),
                  const SizedBox(height: Space.s),
                  ToneBar(value: total == 0 ? 0 : done / total),
                ],
              ),
            ),
          ),
          const SizedBox(width: Space.gutter),
          Expanded(
            flex: 9,
            child: Panel(
              semanticLabel: streak == 1 ? '1 day streak' : '$streak day streak',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Kicker('Streak', stamped: streak > 0),
                  const SizedBox(height: Space.s + 2),
                  Stamp('Ep. ${streak.toString().padLeft(2, '0')}', large: true, filled: streak > 0),
                  const Spacer(),
                  const SizedBox(height: Space.s),
                  Text(
                    streak == 0 ? 'Finish a task to start' : (streak == 1 ? '1 day running' : '$streak days running'),
                    style: context.type.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: Space.gutter),
          Expanded(
            flex: 8,
            child: Panel(
              semanticLabel: '$badges of ${PlannerBadge.all.length} badges earned',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Achievements()),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker('Badges'),
                  const SizedBox(height: Space.s),
                  Text.rich(
                    TextSpan(
                      text: '$badges',
                      children: [
                        TextSpan(
                          text: '/${PlannerBadge.all.length}',
                          style: statStyle.copyWith(color: context.ink.inkMuted),
                        ),
                      ],
                    ),
                    style: statStyle,
                  ),
                  const Spacer(),
                  const SizedBox(height: Space.s),
                  Text('See all', style: context.type.bodySmall?.copyWith(decoration: TextDecoration.underline)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotePanel extends StatelessWidget {
  const _QuotePanel({required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.fromLTRB(Space.m, Space.gutter, Space.m, Space.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Kicker('Line of the day'),
          const SizedBox(height: Space.s),
          Text(
            '“${quote.text}”',
            style: context.type.titleMedium?.copyWith(fontWeight: FontWeight.w600, height: 1.35),
          ),
          const SizedBox(height: Space.s),
          Text('— ${quote.attribution}', style: context.type.bodySmall),
        ],
      ),
    );
  }
}

class _TodayPanel extends StatelessWidget {
  const _TodayPanel({
    required this.stats,
    required this.part,
    required this.onPart,
    required this.onAdd,
    required this.onEdit,
  });

  final PlannerStats stats;
  final DayPart? part;
  final ValueChanged<DayPart?> onPart;
  final VoidCallback onAdd;
  final ValueChanged<Task> onEdit;

  @override
  Widget build(BuildContext context) {
    final tasks = stats.todayTasks;
    final next = stats.nextToday;
    final shown = part == null ? DayPart.values : [part!];
    final groups = {
      for (final p in shown) p: tasks.where((t) => PlannerFormat.dayPart(t.time) == p).toList(),
    };
    final anything = groups.values.any((g) => g.isNotEmpty);

    return Panel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.gutter, Space.gutter, Space.gutter, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's tasks", style: context.type.titleLarge),
                      if (next != null)
                        Text(
                          'Next: ${PlannerFormat.time(next.time)}',
                          style: context.type.bodySmall?.copyWith(fontFeatures: TypeScale.tabular),
                        ),
                    ],
                  ),
                ),
                InkButton.secondary(label: 'Add', icon: Icons.add, small: true, onPressed: onAdd),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Space.gutter),
            child: InkSegmented<DayPart?>(
              segments: const [null, ...DayPart.values],
              selected: part,
              labelOf: (p) => p?.label ?? 'All',
              onChanged: onPart,
            ),
          ),
          if (!anything)
            EmptyState(
              message: tasks.isEmpty
                  ? 'Nothing planned for today yet.'
                  : 'Nothing in the ${part!.label.toLowerCase()}.',
              action: tasks.isEmpty
                  ? InkButton.secondary(label: 'Add a task', small: true, onPressed: onAdd)
                  : null,
            )
          else
            for (final entry in groups.entries)
              if (entry.value.isNotEmpty) ...[
                const InkRule(strong: true),
                Padding(
                  padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, 2),
                  child: Kicker(entry.key.label),
                ),
                for (var i = 0; i < entry.value.length; i++) ...[
                  if (i > 0) const InkRule(indent: 52),
                  TaskRow(
                    title: entry.value[i].title,
                    category: entry.value[i].category,
                    time: entry.value[i].time,
                    done: entry.value[i].isChecked,
                    repeats: entry.value[i].isRecurring,
                    onToggle: (v) => TaskActions.setDone(context, stats.today, entry.value[i], v),
                    onTap: () => onEdit(entry.value[i]),
                    onEdit: () => onEdit(entry.value[i]),
                    onDelete: () => TaskActions.confirmDelete(context, stats.today, entry.value[i]),
                  ),
                ],
              ],
          const SizedBox(height: Space.xs),
        ],
      ),
    );
  }
}
