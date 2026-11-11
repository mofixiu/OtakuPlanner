import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/models/taskMain.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/request.dart';
import 'package:otakuplanner/shared/category_icons.dart';
import 'package:otakuplanner/shared/formats.dart';
import 'package:otakuplanner/shared/notifications.dart' show rootScaffoldMessengerKey;
import 'package:provider/provider.dart';

/// Adding, finishing, editing and deleting a task, the same way from every
/// screen: the planner on the phone changes at once and the server is told.
class TaskActions {
  TaskActions._();

  static String dateKey(DateTime day) =>
      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  static void _say(String text) {
    rootScaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 3)));
  }

  /// Saves a new task and shows it in the planner. If the server can't be
  /// reached the task still shows, and the user is told it's only local.
  static Future<Task> add(
    BuildContext context, {
    required DateTime day,
    required String title,
    required String category,
    required String time,
  }) async {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final date = PlannerFormat.dateOnly(day);
    int? id;
    try {
      final response = await saveTaskToDatabase(TaskMain(
        title: title,
        category: category,
        time: PlannerFormat.to24(time),
        date: dateKey(date),
        userId: userId,
        completed: false,
      ));
      final data = response?['data'];
      if (data is Map) id = data['id'] is int ? data['id'] as int : int.tryParse('${data['id']}');
    } catch (e) {
      log('Could not save task: $e');
    }
    final task = Task(
      id: id,
      title: title,
      category: category,
      time: PlannerFormat.time(time),
      date: date.toIso8601String(),
      color: Task.getRandomColor(),
      icon: categoryIconFor(category),
    );
    provider.addTask(date, task);
    _say(id == null ? "Saved '$title' on this phone only. It'll sync when you're back online." : "Added '$title'");
    return task;
  }

  static Task _copy(Task t, {String? title, String? category, String? time, bool? done}) => Task(
        id: t.id,
        userId: t.userId,
        title: title ?? t.title,
        category: category ?? t.category,
        time: time ?? t.time,
        date: t.date,
        color: t.color,
        icon: category == null ? t.icon : categoryIconFor(category),
        isChecked: done ?? t.isChecked,
        isRecurring: t.isRecurring,
        createdAt: t.createdAt,
        updatedAt: t.updatedAt,
      );

  static Future<void> _push(BuildContext context, DateTime day, Task t) async {
    if (t.id == null) return;
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    try {
      await updateTaskInDatabase(TaskMain(
        id: t.id,
        title: t.title,
        category: t.category,
        time: PlannerFormat.to24(t.time),
        date: dateKey(day),
        userId: userId,
        completed: t.isChecked,
      ));
    } catch (e) {
      log('Could not update task ${t.id}: $e');
      _say("Couldn't reach the server. The change is saved on this phone.");
    }
  }

  static Future<void> setDone(BuildContext context, DateTime day, Task task, bool done) async {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final updated = _copy(task, done: done);
    provider.editTask(PlannerFormat.dateOnly(day), task, updated);
    await _push(context, day, updated);
  }

  static Future<void> update(
    BuildContext context,
    DateTime day,
    Task task, {
    required String title,
    required String category,
    required String time,
  }) async {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final updated = _copy(task, title: title, category: category, time: PlannerFormat.time(time));
    provider.editTask(PlannerFormat.dateOnly(day), task, updated);
    await _push(context, day, updated);
    _say("Updated '$title'");
  }

  /// Asks first, then deletes from the server and the planner.
  static Future<bool> confirmDelete(BuildContext context, DateTime day, Task task) async {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this task?'),
        content: Text("'${task.title}' will be removed from your planner."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep it')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (yes != true) return false;
    if (task.id != null) {
      final ok = await deleteTaskFromDatabase(task.id!);
      if (!ok) {
        _say("Couldn't delete '${task.title}' on the server. Try again.");
        return false;
      }
    }
    provider.deleteTask(PlannerFormat.dateOnly(day), task);
    _say("Deleted '${task.title}'");
    return true;
  }
}
