import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/models/taskMain.dart';
import 'package:otakuplanner/providers/category_provider.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/normalMode/task_dialog2.dart';
import 'package:otakuplanner/screens/request.dart';
import 'package:otakuplanner/shared/category_icons.dart';
import 'package:otakuplanner/shared/notifications.dart';
import 'package:otakuplanner/widgets/bottomNavBar.dart';
import 'package:otakuplanner/widgets/ink_kit.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

/// The month on one panel and the chosen day's tasks on the panel below.
/// Today carries the vermilion stamp; the chosen day is solid ink.
class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  static final _firstDay = DateTime.utc(2020, 1, 1);
  static final _lastDay = DateTime.utc(2030, 12, 31);

  late DateTime _focusedDay;
  late DateTime _selectedDay;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _selectedDay = _today;
    _focusedDay = _today;
  }

  DateTime get _today => PlannerFormat.dateOnly(DateTime.now());

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  /// Days before today can't be picked, as before.
  bool _isEnabled(DateTime day) => !_normalizeDate(day).isBefore(_today);

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  static String _dateOnlyString(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// The task as the database expects it: 24-hour time.
  static TaskMain _toTaskMain(Task t, int userId) => TaskMain(
        id: t.id,
        title: t.title,
        category: t.category,
        time: PlannerFormat.to24(t.time),
        date: t.date,
        userId: userId,
        completed: t.isChecked,
      );

  void _jumpToToday() {
    setState(() {
      _selectedDay = _today;
      _focusedDay = _today;
    });
  }

  // ---------------------------------------------------------------- add

  void _addTask(DateTime day) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final hasTasks = taskProvider.tasks[day]?.isNotEmpty ?? false;
    showTaskDialog(
      context: context,
      dialogTitle: '${hasTasks ? 'Another task' : 'New task'} · ${PlannerFormat.day(day)}',
      onSubmit: (title, category, time) => _saveNewTask(day, title, category, time),
    );
  }

  Future<void> _saveNewTask(DateTime day, String title, String category, String time) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    final parsed = PlannerFormat.parseTime(time);
    if (parsed == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Pick a time for this task.')));
      return;
    }
    if (PlannerFormat.isSameDay(day, DateTime.now())) {
      final at = DateTime(day.year, day.month, day.day, parsed.hour, parsed.minute);
      if (at.isBefore(DateTime.now())) {
        messenger.showSnackBar(
          const SnackBar(content: Text('That time has already passed today.')),
        );
        return;
      }
    }

    final formattedCategory = _capitalize(category);
    final displayTime = PlannerFormat.clock(parsed.hour, parsed.minute);

    // Shown straight away, then given its database id once saved.
    final localTask = Task(
      title: title,
      category: formattedCategory,
      time: displayTime,
      date: day.toIso8601String(),
      color: Task.getRandomColor(),
      icon: categoryIconFor(formattedCategory),
      isChecked: false,
    );
    taskProvider.addTask(day, localTask);

    try {
      final response = await saveTaskToDatabase(
        TaskMain(
          title: title,
          category: formattedCategory,
          time: PlannerFormat.to24(time),
          date: _dateOnlyString(day),
          userId: userProvider.userId,
          completed: false,
        ),
      );
      if (response != null && response['data'] != null) {
        final rawId = response['data']['id'];
        final withId = Task(
          id: rawId is int ? rawId : int.tryParse('$rawId'),
          title: localTask.title,
          category: localTask.category,
          time: localTask.time,
          date: localTask.date,
          color: localTask.color,
          icon: localTask.icon,
          isChecked: localTask.isChecked,
        );
        taskProvider.editTask(day, localTask, withId);
        log('Calendar task saved with ID: $rawId');
      }
    } catch (e) {
      log('Failed to save calendar task: $e');
    }

    if (!categoryProvider.categoryExists(formattedCategory)) {
      await categoryProvider.addAndSaveCategory(formattedCategory, userProvider.userId);
    }

    messenger.showSnackBar(
      SnackBar(content: Text("'$title' added to ${PlannerFormat.day(day)}")),
    );
  }

  // ---------------------------------------------------------------- done

  Future<void> _setDone(DateTime day, Task task, bool done) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    final updated = Task(
      id: task.id,
      userId: task.userId,
      title: task.title,
      category: task.category,
      date: task.date,
      time: task.time,
      color: task.color,
      icon: task.icon,
      isChecked: done,
      isRecurring: task.isRecurring,
    );
    taskProvider.editTask(day, task, updated);

    if (task.id != null) {
      try {
        await updateTaskInDatabase(_toTaskMain(updated, userProvider.userId));
        log('Task completion status updated in database');
      } catch (e) {
        log('Failed to update task completion in database: $e');
      }
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(done ? "Done: '${task.title}'" : "'${task.title}' is back on the list"),
      ),
    );
  }

  // ---------------------------------------------------------------- edit

  Future<void> _editTask(DateTime day, Task task) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final repeats = task.isRecurring && taskProvider.isRecurringTaskOnMultipleDates(task);

    var editAll = false;
    if (repeats) {
      final choice = await _askAboutRepeats(
        title: 'Edit a repeating task',
        message: '"${task.title}" repeats. Change it on ${PlannerFormat.day(day)} only, '
            'or every time it repeats?',
        oneLabel: 'This day only',
        allLabel: 'Every repeat',
      );
      if (choice == null || !mounted) return;
      editAll = choice;
    }

    showTaskDialog(
      context: context,
      dialogTitle: editAll ? 'Edit every repeat' : 'Edit task',
      initialTitle: task.title,
      initialCategory: task.category,
      initialTime: task.time,
      onSubmit: (title, category, time) => _saveEdit(
        day,
        task,
        title,
        category,
        time,
        editAll: editAll,
        // Changing one day of a repeating task takes it out of the series.
        detach: repeats && !editAll,
      ),
    );
  }

  Future<void> _saveEdit(
    DateTime day,
    Task task,
    String title,
    String category,
    String time, {
    required bool editAll,
    required bool detach,
  }) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    final formattedCategory = _capitalize(category);
    final updated = Task(
      id: task.id,
      userId: task.userId,
      title: title,
      category: formattedCategory,
      time: PlannerFormat.time(time),
      date: task.date,
      color: task.color,
      icon: categoryIconFor(formattedCategory),
      isChecked: task.isChecked,
      isRecurring: detach ? false : task.isRecurring,
    );

    if (editAll) {
      taskProvider.editRecurringTask(task, updated);
    } else {
      taskProvider.editTask(day, task, updated);
      if (task.id != null) {
        try {
          await updateTaskInDatabase(_toTaskMain(updated, userProvider.userId));
          log('Task updated in database');
        } catch (e) {
          log('Failed to update task in database: $e');
        }
      }
    }

    if (!categoryProvider.categoryExists(formattedCategory)) {
      await categoryProvider.addAndSaveCategory(formattedCategory, userProvider.userId);
    }

    if (!mounted) return;
    NotificationService.showToast(
      context,
      editAll ? 'All Tasks Updated' : 'Task Updated',
      editAll
          ? "Every repeat of '${task.title}' has been updated"
          : "'${task.title}' on ${PlannerFormat.day(day)} has been updated",
    );
  }

  // ---------------------------------------------------------------- delete

  Future<void> _deleteTask(DateTime day, Task task) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final title = task.title;

    if (task.isRecurring && taskProvider.isRecurringTaskOnMultipleDates(task)) {
      final all = await _askAboutRepeats(
        title: 'Delete a repeating task',
        message: '"$title" repeats. Delete it on ${PlannerFormat.day(day)} only, '
            'or every time it repeats?',
        oneLabel: 'This day only',
        allLabel: 'Every repeat',
      );
      if (all == null || !mounted) return;
      if (all) {
        taskProvider.deleteRecurringTask(task);
        NotificationService.showToast(
          context,
          'Recurring Tasks Deleted',
          "Every repeat of '$title' has been removed",
        );
      } else {
        taskProvider.deleteTask(day, task);
        NotificationService.showToast(
          context,
          'Task Deleted',
          "'$title' on ${PlannerFormat.day(day)} has been removed",
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('"$title" will be removed from ${PlannerFormat.day(day)}.'),
        actions: [
          InkButton.quiet(
            label: 'Cancel',
            small: true,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          InkButton.secondary(
            label: 'Delete',
            small: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final id = task.id;
    if (id != null) {
      // In the background, as before; the row goes from the list right away.
      deleteTaskFromDatabase(id).then(
        (deleted) => log(deleted ? 'Task deleted from database' : 'Task was not deleted from database'),
      );
    }
    taskProvider.deleteTask(day, task);
    messenger.showSnackBar(SnackBar(content: Text("'$title' has been deleted")));
  }

  /// Asks whether a change applies to one day or to every repeat. Returns
  /// true for every repeat, false for one day, null if dismissed.
  Future<bool?> _askAboutRepeats({
    required String title,
    required String message,
    required String oneLabel,
    required String allLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actionsPadding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.m),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkButton(
                label: allLabel,
                expand: true,
                onPressed: () => Navigator.of(dialogContext).pop(true),
              ),
              const SizedBox(height: Space.s),
              InkButton.secondary(
                label: oneLabel,
                expand: true,
                onPressed: () => Navigator.of(dialogContext).pop(false),
              ),
              const SizedBox(height: Space.xs),
              InkButton.quiet(
                label: 'Cancel',
                expand: true,
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- details

  void _showDetails(DateTime day, Task task) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        void close() => Navigator.of(dialogContext).pop();
        return AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(Space.l, Space.m, Space.s, 0),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: Space.s),
                  child: Text(task.title),
                ),
              ),
              IconButton(icon: const Icon(Icons.close), tooltip: 'Close', onPressed: close),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.isRecurring)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.s),
                      child: Row(
                        children: [
                          const Icon(Icons.repeat, size: 16),
                          const SizedBox(width: 6),
                          Text('Repeats', style: dialogContext.type.bodySmall),
                        ],
                      ),
                    ),
                  _DetailLine(
                    label: 'Category',
                    child: Row(
                      children: [
                        ToneSwatch(category: task.category),
                        const SizedBox(width: Space.s),
                        Flexible(child: Text(task.category, style: dialogContext.type.titleSmall)),
                      ],
                    ),
                  ),
                  const InkRule(),
                  _DetailLine(
                    label: 'Date',
                    child: Text(PlannerFormat.dayLong(day), style: dialogContext.type.titleSmall),
                  ),
                  const InkRule(),
                  _DetailLine(
                    label: 'Time',
                    child: Text(
                      PlannerFormat.time(task.time),
                      style: dialogContext.type.titleSmall
                          ?.copyWith(fontFeatures: TypeScale.tabular),
                    ),
                  ),
                  const InkRule(),
                  _DetailLine(
                    label: 'Status',
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: Checkbox(
                            value: task.isChecked,
                            onChanged: (value) {
                              close();
                              _setDone(day, task, value ?? false);
                            },
                          ),
                        ),
                        const SizedBox(width: Space.xs),
                        Text(
                          task.isChecked ? 'Done' : 'Not done yet',
                          style: dialogContext.type.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.m),
          actions: [
            Row(
              children: [
                Expanded(
                  child: InkButton.secondary(
                    label: 'Delete',
                    icon: Icons.delete_outline,
                    expand: true,
                    onPressed: () {
                      close();
                      _deleteTask(day, task);
                    },
                  ),
                ),
                const SizedBox(width: Space.gutter),
                Expanded(
                  child: InkButton(
                    label: 'Edit',
                    icon: Icons.edit_outlined,
                    expand: true,
                    onPressed: () {
                      close();
                      _editTask(day, task);
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final byDay = Provider.of<TaskProvider>(context).tasks;
    final day = _selectedDay;
    final today = _today;
    final isToday = PlannerFormat.isSameDay(day, today);
    final tasks = [...?byDay[day]]
      ..sort((a, b) => PlannerFormat.minutes(a.time).compareTo(PlannerFormat.minutes(b.time)));
    final awayFromToday = !isToday ||
        _focusedDay.month != today.month ||
        _focusedDay.year != today.year;

    return Scaffold(
      appBar: const PlannerAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.page, Space.l, Space.page, Space.l),
        children: [
          Row(
            children: [
              Expanded(child: Text('Calendar', style: context.type.displaySmall)),
              if (awayFromToday)
                InkButton.quiet(label: 'Today', small: true, onPressed: _jumpToToday),
            ],
          ),
          const SizedBox(height: Space.gutter),
          Panel(
            padding: const EdgeInsets.fromLTRB(Space.gutter, Space.gutter, Space.gutter, Space.s),
            child: Column(
              children: [
                _MonthHeader(
                  month: _focusedDay,
                  onPrevious: () => _pageController?.previousPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  ),
                  onNext: () => _pageController?.nextPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  ),
                ),
                const SizedBox(height: Space.s),
                TableCalendar<Task>(
                  firstDay: _firstDay,
                  lastDay: _lastDay,
                  focusedDay: _focusedDay,
                  currentDay: DateTime.now(),
                  headerVisible: false,
                  calendarFormat: CalendarFormat.month,
                  availableGestures: AvailableGestures.horizontalSwipe,
                  rowHeight: 46,
                  daysOfWeekHeight: 22,
                  selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                  enabledDayPredicate: _isEnabled,
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = _normalizeDate(selected);
                      _focusedDay = focused;
                    });
                  },
                  onPageChanged: (focused) => setState(() => _focusedDay = focused),
                  onCalendarCreated: (controller) => _pageController = controller,
                  calendarStyle: const CalendarStyle(outsideDaysVisible: false),
                  calendarBuilders: CalendarBuilders<Task>(
                    dowBuilder: (context, d) => Center(child: Kicker(DateFormat('EEE').format(d))),
                    prioritizedBuilder: (context, d, focused) {
                      final dayTasks = byDay[_normalizeDate(d)] ?? const <Task>[];
                      return _DayCell(
                        day: d,
                        selected: isSameDay(_selectedDay, d),
                        today: isSameDay(d, today),
                        enabled: _isEnabled(d),
                        taskCount: dayTasks.length,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.gutter),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Row(
              children: [
                Expanded(child: Kicker(PlannerFormat.kickerDay(day), stamped: isToday)),
                if (tasks.isNotEmpty)
                  InkButton.secondary(
                    label: 'Add task',
                    icon: Icons.add,
                    small: true,
                    onPressed: () => _addTask(day),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Space.s),
          Panel(
            padding: tasks.isEmpty
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(vertical: Space.xs),
            child: tasks.isEmpty
                ? EmptyState(
                    art: MascotArt.calendar,
                    message: 'Nothing planned for this day.',
                    action: InkButton(
                      label: 'Add a task',
                      icon: Icons.add,
                      onPressed: () => _addTask(day),
                    ),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < tasks.length; i++) ...[
                        if (i > 0) const InkRule(indent: 48),
                        TaskRow(
                          title: tasks[i].title,
                          category: tasks[i].category,
                          time: tasks[i].time,
                          done: tasks[i].isChecked,
                          repeats: tasks[i].isRecurring,
                          onToggle: (done) => _setDone(day, tasks[i], done),
                          onTap: () => _showDetails(day, tasks[i]),
                          onEdit: () => _editTask(day, tasks[i]),
                          onDelete: () => _deleteTask(day, tasks[i]),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}

/// "November 2026" with square ink arrows for the previous and next month.
class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.month, required this.onPrevious, required this.onNext});

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(DateFormat('MMMM yyyy').format(month), style: context.type.titleLarge),
        ),
        InkIconButton(
          icon: Icons.chevron_left,
          tooltip: 'Previous month',
          size: 34,
          onPressed: onPrevious,
        ),
        const SizedBox(width: Space.s),
        InkIconButton(
          icon: Icons.chevron_right,
          tooltip: 'Next month',
          size: 34,
          onPressed: onNext,
        ),
      ],
    );
  }
}

/// One day in the month grid. Today is printed in the vermilion stamp
/// (outlined, or solid when chosen); the chosen day is solid ink; small ink
/// dots under the number count the day's tasks.
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.today,
    required this.enabled,
    required this.taskCount,
  });

  final DateTime day;
  final bool selected;
  final bool today;
  final bool enabled;
  final int taskCount;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    final fill = selected ? (today ? c.stamp : c.ink) : null;
    final fg = selected
        ? c.paper
        : today
            ? c.stamp
            : enabled
                ? c.ink
                : c.ink.withValues(alpha: 0.32);
    final dots = taskCount.clamp(0, 3);

    // A fixed square, so today's stamp and the chosen day read as blocks and
    // the task marks sit under the number, not on it.
    return Center(
      child: Container(
        width: 38,
        height: 40,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: Radii.controlAll,
          border: today && !selected ? Border.all(color: c.stamp, width: Strokes.panel) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: context.type.titleSmall?.copyWith(
                color: fg,
                height: 1.1,
                fontWeight: today || selected ? FontWeight.w700 : FontWeight.w500,
                fontFeatures: TypeScale.tabular,
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              height: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < dots; i++)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      color: fg,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A label and its value on one line in the task details.
class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 84, child: Kicker(label)),
          Expanded(child: child),
        ],
      ),
    );
  }
}
