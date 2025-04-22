import 'package:flutter/material.dart';
// Change this import to use the model Task instead of calendar Task
import 'package:otakuplanner/models/task.dart';

class TaskProvider with ChangeNotifier {
  final Map<DateTime, List<Task>> _tasks = {};

  Map<DateTime, List<Task>> get tasks => _tasks;

  void addTask(DateTime date, Task task) {
    if (_tasks.containsKey(date)) {
      _tasks[date]!.add(task);
    } else {
      _tasks[date] = [task];
    }
    notifyListeners();
  }

  void editTask(DateTime date, Task oldTask, Task newTask) {
    if (_tasks.containsKey(date)) {
      final index = _tasks[date]!.indexWhere((t) => 
        t.title == oldTask.title && t.time == oldTask.time);
      if (index != -1) {
        _tasks[date]![index] = newTask;
      }
    }
    notifyListeners();
  }

  void deleteTask(DateTime date, Task task) {
    if (_tasks.containsKey(date)) {
      _tasks[date]!.removeWhere((t) => 
        t.title == task.title && t.time == task.time);
    }
    notifyListeners();
  }

  List<Task> getTasksByCategory(String category) {
    if (category == "All") {
      return _tasks.values.expand((tasks) => tasks).toList();
    }
    return _tasks.values
        .expand((tasks) => tasks)
        .where((task) => task.category == category)
        .toList();
  }
}