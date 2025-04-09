import 'dart:math';

import 'package:flutter/material.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/screens/profile.dart';
import 'package:otakuplanner/screens/task_dialog2.dart';
import 'package:otakuplanner/widgets/bottomNavBar.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:otakuplanner/shared/categories.dart'; // Import the shared categories

String formatDateWithOrdinal(DateTime date) {
  final day = date.day;
  final suffix = (day % 10 == 1 && day != 11)
      ? 'st'
      : (day % 10 == 2 && day != 12)
          ? 'nd'
          : (day % 10 == 3 && day != 13)
              ? 'rd'
              : 'th';
  final formattedDate = DateFormat("MMMM yyyy").format(date); // Format as "January 2025"
  return "$day$suffix $formattedDate"; // Combine day with suffix and formatted date
}

class Task {
  String title;
  String category;
  String time; // Use String for time
  Color color;

  Task({
    required this.title,
    required this.category,
    required this.time,
    required this.color,
  });

  static Color getRandomColor() {
    final random = Random();
    final color = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
    print("Generated color: $color");
    return color;
  }
}

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final int _currentIndex = 1;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Task>> _tasks = {};
  final Map<DateTime, Color> _dateColors = {}; 

  void delete(Task task, DateTime taskDate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Task"),
          content: Text(
            "Are you sure you want to delete ${task.title}?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _tasks[taskDate]?.remove(task);
                  if (_tasks[taskDate]?.isEmpty ?? false) {
                    _tasks.remove(taskDate);
                    _dateColors.remove(taskDate);
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void deleteTasksForDay(DateTime selectedDay) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete All Tasks"),
          content: Text("Are you sure you want to delete all tasks for ${selectedDay.toLocal().toString().split(' ')[0]}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _tasks.remove(selectedDay);
                  _dateColors.remove(selectedDay);
                });
                Navigator.pop(context);
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void showDeleteSingleTaskDialog(DateTime selectedDay) {
    final tasksForDay = _tasks[selectedDay] ?? [];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete a Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: tasksForDay.map((task) {
              return ListTile(
                title: Text(task.title),
                subtitle: Text("${task.category} - ${task.time}"),
                trailing: Icon(Icons.delete, color: Colors.red),
                onTap: () {
                  Navigator.pop(context); // Close the delete single task dialog
                  setState(() {
                    tasksForDay.remove(task);
                    if (tasksForDay.isEmpty) {
                      _tasks.remove(selectedDay);
                      _dateColors.remove(selectedDay);
                    }
                  });
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void showDeleteOptionsDialog(DateTime selectedDay) {
    final tasksForDay = _tasks[selectedDay] ?? [];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Tasks"),
          content: tasksForDay.isEmpty
              ? Text("No tasks available to delete.")
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: tasksForDay.map((task) {
                    return ListTile(
                      title: Text(task.title),
                      subtitle: Text("${task.category} - ${task.time}"),
                      trailing: Icon(Icons.delete, color: Colors.red),
                      onTap: () {
                        Navigator.pop(context); // Close the dialog
                        setState(() {
                          tasksForDay.remove(task);
                          if (tasksForDay.isEmpty) {
                            _tasks.remove(selectedDay);
                            _dateColors.remove(selectedDay);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            if (tasksForDay.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  deleteTasksForDay(selectedDay);
                },
                child: Text(
                  "Delete All",
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  void profile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Profile()),
    );
  }

  void showEditTaskDialog(DateTime selectedDay) {
    final tasksForDay = _tasks[selectedDay] ?? [];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Tasks for ${selectedDay.toLocal().toString().split(' ')[0]}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: tasksForDay.map((task) {
              return ListTile(
                title: Text(task.title),
                subtitle: Text("${task.category} - ${task.time}"),
                trailing: Icon(Icons.edit),
                onTap: () {
                  Navigator.pop(context);
                  showTaskDialog(
                    context: context,
                    dialogTitle: "Edit Task",
                    initialTitle: task.title,
                    initialCategory: task.category,
                    initialTime: task.time,
                    onSubmit: (title, category, time) {
                      setState(() {
                        task.title = title;
                        task.category = category;
                        task.time = time;
                      });
                    },
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void showDayOptionsDialog(DateTime selectedDay) {
    final tasksForDay = _tasks[selectedDay] ?? []; // Get tasks for the selected day
    final hasTasks = tasksForDay.isNotEmpty; // Check if there are existing tasks
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Options for ${selectedDay.toLocal().toString().split(' ')[0]}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose an option",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.add),
                title: Text(hasTasks ? "Add Another Task" : "Add Task"), // Dynamic text
                onTap: () {
                  Navigator.pop(context); // Close the options dialog
                  showTaskDialog(
                    context: context,
                    dialogTitle: "Add Task for ${selectedDay.toLocal().toString().split(' ')[0]}",
                    onSubmit: (title, category, time) {
                    //   final task = Task(
                    //   title: title,
                    //   category: category,
                    //   time: time,
                    //   color: Task.getRandomColor(),
                    // );
                    // taskProvider.addTask(selectedDay, task);
                    //  if (!Categories.categories.contains(category)) {
                    //     Categories.categories.add(category);
                    //   }
                    
                      setState(() {
                        if (_tasks[selectedDay] == null) {
                          _tasks[selectedDay] = [];
                        }
                        if (_dateColors[selectedDay] == null) {
                          _dateColors[selectedDay] = Task.getRandomColor();
                        }
                        _tasks[selectedDay]!.add(
                          Task(
                            title: title,
                            category: category,
                            time: time,
                            color: _dateColors[selectedDay]!,
                          ),
                                              
                        );
                        final task = Task(
                      title: title,
                      category: category,
                      time: time,
                      color: Task.getRandomColor(),
                    );
                        taskProvider.addTask(selectedDay, task);


                        // Add the category to the shared list if it doesn't exist
                        if (!Categories.categories.contains(category)) {
                          Categories.categories.add(category);
                        }
                      }
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text("Edit Task"),
                onTap: () {
                  Navigator.pop(context); // Close the options dialog
                  if (_tasks[selectedDay]?.isNotEmpty ?? false) {
                    showEditTaskDialog(selectedDay);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("No tasks to edit for this day.")),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text("Delete Task"),
                onTap: () {
                  Navigator.pop(context); // Close the options dialog
                  if (_tasks[selectedDay]?.isNotEmpty ?? false) {
                    showDeleteOptionsDialog(selectedDay);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("No tasks to delete for this day.")),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/images/otaku.jpg", fit: BoxFit.contain),
        centerTitle: false,
        backgroundColor: Color.fromRGBO(255, 249, 233, 1),
        elevation: 2,
        scrolledUnderElevation: 2,
        title: Text(
          "OtakuPlanner",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: profile,
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: CircleAvatar(child: Icon(Icons.person)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              enabledDayPredicate: (day) {
                return day.isAfter(DateTime.now().subtract(Duration(days: 1)));
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                showDayOptionsDialog(selectedDay);
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(  
                  color: Colors.brown,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (_tasks[day]?.isNotEmpty ?? false) {
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color:
                              _dateColors[day] ??
                              Colors
                                  .red, 
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              "My Tasks",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Expanded(
              child:
                  _tasks.isEmpty
                      ? Center(
                        child: Text(
                          "No tasks available.",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                      : ListView.builder(
                        itemCount:
                            _tasks.entries
                                .expand((entry) => entry.value)
                                .toList()
                                .length, 
                        itemBuilder: (context, index) {
                          final allTasks =
                              _tasks.entries
                                  .expand(
                                    (entry) => entry.value.map(
                                      (task) => {
                                        'date': entry.key,
                                        'task': task,
                                      },
                                    ),
                                  )
                                  .toList();
                          final taskData = allTasks[index];
                          final taskDate = taskData['date'] as DateTime;
                          final task = taskData['task'] as Task;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.task,
                                  color: task.color,
                                ), 
                                title: Text(task.title),
                                subtitle: Text(
                                  "${taskDate.toLocal().toString().split(' ')[0]} - ${task.category} - ${task.time}",
                                ), 
                              ),
                              
                            ],
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}
