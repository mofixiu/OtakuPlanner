import 'package:flutter/material.dart';
import 'package:otakuplanner/screens/calendar.dart';

class TaskProvider with ChangeNotifier {
  final Map<DateTime, List<Task>> _tasks = {};

  Map<DateTime, List<Task>> get tasks => _tasks;

  void addTask(DateTime date, Task task) {
    if (_tasks[date] == null) {
      _tasks[date] = [];
    }
    _tasks[date]!.add(task);
    notifyListeners();
  }

  void deleteTask(DateTime date, Task task) {
    _tasks[date]?.remove(task);
    if (_tasks[date]?.isEmpty ?? false) {
      _tasks.remove(date);
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