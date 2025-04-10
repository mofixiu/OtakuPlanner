import 'dart:math';
import 'package:flutter/material.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/screens/profile.dart';
import 'package:otakuplanner/screens/task_dialog2.dart';
import 'package:otakuplanner/widgets/bottomNavBar.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:otakuplanner/shared/categories.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final Map<String, IconData> categoryIcons = {
  "Study": FontAwesomeIcons.bookAtlas,
  "Health": FontAwesomeIcons.dumbbell,
  "Work": FontAwesomeIcons.briefcase,
  "Personal": FontAwesomeIcons.user,
  "Fitness": FontAwesomeIcons.personRunning,
  "Shopping": FontAwesomeIcons.cartShopping,
  "Travel": FontAwesomeIcons.plane,
  "Coding": FontAwesomeIcons.laptopCode,
  "Programming": FontAwesomeIcons.laptopCode,
  "Sports":FontAwesomeIcons.futbol,
  "Music": FontAwesomeIcons.music,
  "Art": FontAwesomeIcons.paintbrush,
  "Cooking": FontAwesomeIcons.utensils,
  "Gaming": FontAwesomeIcons.gamepad,
  "Reading": FontAwesomeIcons.bookAtlas,
  "Writing": FontAwesomeIcons.penToSquare,
  "Photography": FontAwesomeIcons.camera,
  "Gardening": FontAwesomeIcons.seedling,
  "Cleaning": FontAwesomeIcons.broom,
  "Social": FontAwesomeIcons.peopleGroup,
  "Other": FontAwesomeIcons.listCheck,

};

String formatDateWithOrdinal(DateTime date) {
  final day = date.day;
  final suffix = (day % 10 == 1 && day != 11)
      ? 'st'
      : (day % 10 == 2 && day != 12)
          ? 'nd'
          : (day % 10 == 3 && day != 13)
              ? 'rd'
              : 'th';
  final formattedDate = DateFormat("MMMM yyyy").format(date);
  return "$day$suffix $formattedDate";
}

class Task {
  String title;
  String category;
  String time; // Use String for time
  Color color;
  IconData? icon; // Optional icon property

  Task({
    required this.title,
    required this.category,
    required this.time,
    required this.color,
    this.icon, // Initialize the icon
  });

  static Color getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
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
  @override
  void initState() {
    super.initState();
    // Initialize _selectedDay to the current day
    _selectedDay = DateTime.now();
  }
  void showDayOptionsDialog(DateTime selectedDay) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final hasTasks = taskProvider.tasks[selectedDay]?.isNotEmpty ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Options for ${formatDateWithOrdinal(selectedDay)}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.add),
                title: Text(hasTasks ? "Add Another Task" : "Add Task"),
                onTap: () {
                  Navigator.pop(context);
                  showTaskDialog(
                    context: context,
                    dialogTitle: hasTasks
                        ? "Add Another Task for ${formatDateWithOrdinal(selectedDay)}"
                        : "Add Task for ${formatDateWithOrdinal(selectedDay)}",
                    onSubmit: (title, category, time) {
                      final task = Task(
                        title: title,
                        category: category[0].toUpperCase() +
                            category.substring(1).toLowerCase(),
                        time: time,
                        color: Task.getRandomColor(),
                        icon: categoryIcons[category[0].toUpperCase() +
                                category.substring(1).toLowerCase()] ??
                            FontAwesomeIcons.listCheck, // Default icon if category not found
                      );
                      taskProvider.addTask(selectedDay, task);
                      if (!Categories.categories.contains(category)) {
                        category = category[0].toUpperCase() +
                            category.substring(1).toLowerCase();
                        Categories.categories.add(category);
                      }
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text("Edit Task"),
                onTap: () {
                  Navigator.pop(context);
                  if (taskProvider.tasks[selectedDay]?.isNotEmpty ?? false) {
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
                  Navigator.pop(context);
                  if (taskProvider.tasks[selectedDay]?.isNotEmpty ?? false) {
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

  void showDeleteOptionsDialog(DateTime selectedDay) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final tasks = taskProvider.tasks[selectedDay] ?? [];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Task"),
          content: tasks.isEmpty
              ? Text("No tasks available to delete.")
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: tasks.map((task) {
                    return ListTile(
                      leading: Icon(Icons.task, color: task.color),
                      title: Text(task.title),
                      subtitle: Text("${task.category} - ${task.time}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          taskProvider.deleteTask(selectedDay, task);
                          Navigator.pop(context); 
                        },
                      ),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }

  void showEditTaskDialog(DateTime selectedDay) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final tasks = taskProvider.tasks[selectedDay] ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Task"),
          content: tasks.isEmpty
              ? Text("No tasks available to edit.")
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: tasks.map((task) {
                    return ListTile(
                      leading: Icon(Icons.task, color: task.color),
                      title: Text(task.title),
                      subtitle: Text("${task.category} - ${task.time}"),
                      trailing: IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                          showTaskDialog(
                            context: context,
                            dialogTitle: "Edit Task",
                            initialTitle: task.title,
                            initialCategory: task.category,
                            initialTime: task.time,
                            onSubmit: (title, category, time) {
                              final updatedTask = Task(
                                title: title,
                                category: category,
                                time: time,
                                color: task.color, // Keep the same color
                                icon: categoryIcons[category] ?? FontAwesomeIcons.listCheck, // Default icon if category not found
                              );
                              taskProvider.editTask(selectedDay, task, updatedTask);

                              // Add the category to the shared list if it doesn't exist
                              if (!Categories.categories.contains(category)) {
                                Categories.categories.add(category);
                              }
                            },
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Profile()),
              );
            },
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
                  color: Color(0xFF1E293B),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  final tasksForDay = taskProvider.tasks[day];
                  if (tasksForDay != null && tasksForDay.isNotEmpty) {
                    // Use the color of the first task for the marker
                    final taskColor = tasksForDay.first.color;
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: taskColor, // Set the marker color to the task's color
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
              // if i want to make it three dots under looks ugly though
//               calendarBuilders: CalendarBuilders(
//   markerBuilder: (context, day, events) {
//     final tasksForDay = taskProvider.tasks[day];
//     if (tasksForDay != null && tasksForDay.isNotEmpty) {
//       return Positioned(
//         bottom: 1,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: tasksForDay.take(3).map((task) {
//             // Limit to 3 dots for better UI
//             return Container(
//               margin: EdgeInsets.symmetric(horizontal: 1),
//               width: 6,
//               height: 6,
//               decoration: BoxDecoration(
//                 color: task.color, // Set the marker color to the task's color
//                 shape: BoxShape.circle,
//               ),
//             );
//           }).toList(),
//         ),
//       );
//     }
//     return null;
//   },
// ),
            ),
            SizedBox(height: 16),
            Text(
              "Tasks for ${_selectedDay != null ? formatDateWithOrdinal(_selectedDay!) : 'Selected Day'}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Expanded(
              child: taskProvider.tasks[_selectedDay]?.isEmpty ?? true
                  ? Center(
                      child: Text(
                        "No tasks available for this day.",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: taskProvider.tasks[_selectedDay]?.length ?? 0,
                      itemBuilder: (context, index) {
                        final task = taskProvider.tasks[_selectedDay]![index];
                        return ListTile(
                          leading: Icon(
                            task.icon ?? FontAwesomeIcons.tasks, // Use the task's icon
                            color: task.color, // Set the icon color to match the task's color
                          ),
                          title: Text(task.title),
                          subtitle: Text("${task.category} - ${task.time}"),
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
