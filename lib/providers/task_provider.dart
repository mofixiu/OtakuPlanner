import 'dart:developer' show log;

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
    log('Task added: ${task.title} for date: $date');
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

void toggleTaskCompletion(Task task) {
  // If it's a recurring task that appears in multiple places
  if (task.isRecurring == true && isRecurringTaskOnMultipleDates(task)) {
    // Show a dialog asking if they want to mark all instances or just this one
    // For now, we'll update all instances
    final updatedTask = Task(
      title: task.title,
      category: task.category,
      time: task.time,
                                                      date: task.date,

      color: task.color,
      icon: task.icon,
      isChecked: !task.isChecked,
      isRecurring: task.isRecurring,
    );
    
    // Update all instances of this recurring task
    editRecurringTask(task, updatedTask);
  } else {
    // For non-recurring tasks, find and update the specific task
    tasks.forEach((date, taskList) {
      for (int i = 0; i < taskList.length; i++) {
        if (taskList[i] == task) {
          final updatedTask = Task(
            title: task.title,
            category: task.category,
            time: task.time,
            color: task.color,
            date: task.date,

            icon: task.icon,
            isChecked: !task.isChecked,
            isRecurring: task.isRecurring,
          );
          editTask(date, taskList[i], updatedTask);
          return;
        }
      }
    });
  }
  
  notifyListeners();
}

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

// In your task_provider.dart, ensure this method exists:

void addTaskIfNotExists(DateTime date, Task task) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final key = _dateToKey(normalizedDate); // Convert DateTime to String key
  
  // Initialize the list if it doesn't exist
  if (_tasks[key] == null) {
    _tasks[key] = [];
  }
  
  // Check if task already exists (by title and time to avoid duplicates)
  final existingTask = _tasks[key]!.firstWhere(
    (t) => t.title == task.title && t.time == task.time && t.date == task.date,
    orElse: () => Task(title: '', category: '', time: '', date: '', color: Colors.blue, icon: Icons.task, isChecked: false),
  );
  
  if (existingTask.title.isEmpty) {
    _tasks[key]!.add(task);
    log('Added task: ${task.title} to date: $normalizedDate');
  } else {
    log('Task already exists: ${task.title} for date: $normalizedDate');
  }
  
  notifyListeners();
}

void debugPrintTasks() {
  log('=== TASK PROVIDER DEBUG ===');
  log('Total task dates: ${_tasks.keys.length}');
  _tasks.forEach((date, tasks) {
    log('Date: $date - Tasks: ${tasks.length}');
    for (final task in tasks) {
      log('  - ${task.title} (${task.category}) at ${task.time} - Completed: ${task.isChecked}');
    }
  });
  log('=== END TASK DEBUG ===');
}
// Add method to clear all tasks (useful for testing)
void clearAllTasks() {
  _tasks.clear();
  notifyListeners();
  log('All tasks cleared from TaskProvider');
}

// Add this method to your TaskProvider:

void addTaskWithDateFix(String dateString, Task task) {
  try {
    DateTime date;
    
    // Handle different date formats
    if (dateString.contains('T')) {
      // ISO format with time
      try {
        date = DateTime.parse(dateString);
      } catch (e) {
        // Fix common issues like trailing dot
        String fixedDate = dateString;
        if (fixedDate.endsWith('.')) {
          fixedDate = fixedDate.substring(0, fixedDate.length - 1) + '.000Z';
        }
        date = DateTime.parse(fixedDate);
      }
    } else {
      // Date-only format (YYYY-MM-DD)
      final parts = dateString.split('-');
      if (parts.length == 3) {
        date = DateTime(
          int.parse(parts[0]), // year
          int.parse(parts[1]), // month
          int.parse(parts[2]), // day
        );
      } else {
        throw FormatException('Invalid date format: $dateString');
      }
    }
    
    final normalizedDate = DateTime(date.year, date.month, date.day);
    addTaskIfNotExists(normalizedDate, task); // This will now work correctly
    log('Successfully added task ${task.title} for date: $normalizedDate');
  } catch (e) {
    log('Could not parse date for task ${task.title}: $dateString, error: $e');
    // Add to today as fallback
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    addTaskIfNotExists(normalizedToday, task);
  }
}
}