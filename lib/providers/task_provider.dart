import 'package:flutter/material.dart';
// Change this import to use the model Task instead of calendar Task
import 'package:otakuplanner/models/task.dart';

class TaskProvider with ChangeNotifier {
  // Convert a DateTime to a string key in format 'yyyy-MM-dd'
  String _dateToKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Convert a string key back to a DateTime
  DateTime _keyToDate(String key) {
    final parts = key.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  // Use a Map<String, List<Task>> instead of Map<DateTime, List<Task>>
  final Map<String, List<Task>> _tasks = {};

  // Modify the getter to convert keys
  Map<DateTime, List<Task>> get tasks {
    Map<DateTime, List<Task>> result = {};
    _tasks.forEach((key, value) {
      result[_keyToDate(key)] = value;
    });
    return result;
  }

  void addTask(DateTime date, Task task) {
    final key = _dateToKey(date);
    if (_tasks[key] == null) {
      _tasks[key] = [];
    }
    _tasks[key]!.add(task);
    notifyListeners();
  }

  void editTask(DateTime date, Task oldTask, Task newTask) {
    final key = _dateToKey(date);
    if (_tasks.containsKey(key)) {
      final index = _tasks[key]!.indexWhere((t) => 
        t.title == oldTask.title && t.time == oldTask.time);
      if (index != -1) {
        _tasks[key]![index] = newTask;
      }
    }
    notifyListeners();
  }

  void deleteTask(DateTime date, Task task) {
    final key = _dateToKey(date);
    if (_tasks.containsKey(key)) {
      _tasks[key]!.removeWhere((t) => 
        t.title == task.title && t.time == task.time);
    }
    notifyListeners();
  }
  // Add these methods to your TaskProvider class

// Edit a recurring task across all dates
void editRecurringTask(Task oldTask, Task newTask) {
  // Go through all dates and update every matching recurring task
  _tasks.forEach((dateKey, taskList) {
    for (int i = 0; i < taskList.length; i++) {
      if (taskList[i].title == oldTask.title && 
          taskList[i].isRecurring == true) {
        taskList[i] = newTask;
      }
    }
  });
  notifyListeners();
}

// Delete a recurring task across all dates
void deleteRecurringTask(Task task) {
  // Go through all dates and remove every matching recurring task
  _tasks.forEach((dateKey, taskList) {
    taskList.removeWhere((t) => 
      t.title == task.title && t.isRecurring == true);
  });
  notifyListeners();
}

// Check if a task is recurring and exists on multiple dates
bool isRecurringTaskOnMultipleDates(Task task) {
  if (!task.isRecurring) return false;
  
  int occurrences = 0;
  for (var taskList in _tasks.values) {
    for (var t in taskList) {
      if (t.title == task.title && t.isRecurring == true) {
        occurrences++;
        if (occurrences > 1) {
          return true;
        }
      }
    }
  }
  
  return occurrences > 1;
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