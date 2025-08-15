// ignore_for_file: unused_element, use_build_context_synchronously, sized_box_for_whitespace

import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:otakuplanner/models/taskMain.dart';
import 'package:otakuplanner/providers/category_provider.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/normalMode/profile.dart';
import 'package:otakuplanner/screens/normalMode/task_dialog2.dart';
import 'package:otakuplanner/screens/request.dart';
import 'package:otakuplanner/shared/notifications.dart';
import 'package:otakuplanner/themes/theme.dart';
import 'package:otakuplanner/widgets/bottomNavBar.dart';
import 'package:provider/provider.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:table_calendar/table_calendar.dart';

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
  "Sports": FontAwesomeIcons.futbol,
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
late TaskProvider _taskProvider;

String formatDateWithOrdinal(DateTime date) {
  final day = date.day;
  final suffix =
      (day % 10 == 1 && day != 11)
          ? 'st'
          : (day % 10 == 2 && day != 12)
          ? 'nd'
          : (day % 10 == 3 && day != 13)
          ? 'rd'
          : 'th';
  final formattedDate = DateFormat("MMMM yyyy").format(date);
  return "$day$suffix $formattedDate";
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
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
  _selectedDay = today;
    _focusedDay = today;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Only proceed if the widget is still mounted
    if (!mounted) return;
    
    _taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // Force refresh when navigating to this page
    if (mounted) {
      setState(() {
        // This will trigger a rebuild with the latest tasks from TaskProvider
      });
    }
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NotificationDropdown();
      },
    );
  }

  void showDayOptionsDialog(DateTime selectedDay) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final normalizedSelectedDay = _normalizeDate(selectedDay);
    final hasTasks =
        taskProvider.tasks[normalizedSelectedDay]?.isNotEmpty ?? false;

    // Check if selected day is today
    final bool isToday = DateTime(
      normalizedSelectedDay.year,
      normalizedSelectedDay.month,
      normalizedSelectedDay.day,
    ).isAtSameMomentAs(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Options for ${formatDateWithOrdinal(normalizedSelectedDay)}",
          ),
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
                    dialogTitle:
                        hasTasks
                            ? "Add Another Task for ${formatDateWithOrdinal(normalizedSelectedDay)}"
                            : "Add Task for ${formatDateWithOrdinal(normalizedSelectedDay)}",
                    onSubmit: (title, category, time) async {
                      // Capture providers and context BEFORE any async operations
                      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      // Time validation for today
                      if (isToday) {
                        final now = DateTime.now();
                        final timeFormat = DateFormat("hh:mm a");
                        try {
                          final taskTime = timeFormat.parse(time);
                          final taskDateTime = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            taskTime.hour,
                            taskTime.minute,
                          );

                          if (taskDateTime.isBefore(now)) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Cannot schedule tasks for times that have already passed",
                                ),
                              ),
                            );
                            return;
                          }
                        } catch (e) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text("Please enter a valid time format"),
                            ),
                          );
                          return;
                        }
                      }

                      final formattedCategory =
                          category[0].toUpperCase() +
                          category.substring(1).toLowerCase();

                      // Create local task WITHOUT ID first
                      final localTask = Task(
                        title: title,
                        category: formattedCategory,
                        time: time, // Keep 12-hour format for display
                        date: normalizedSelectedDay.toIso8601String(),
                        color: Task.getRandomColor(),
                        icon:
                            categoryIcons[formattedCategory] ??
                            FontAwesomeIcons.listCheck,
                        isChecked: false,
                      );

                      // Add to TaskProvider immediately
                      taskProvider.addTask(normalizedSelectedDay, localTask);

                      // Save to database in background
                      try {
                        final dateOnlyString =
                            '${normalizedSelectedDay.year}-${normalizedSelectedDay.month.toString().padLeft(2, '0')}-${normalizedSelectedDay.day.toString().padLeft(2, '0')}';

                        // Convert to 24-hour format for database storage
                        final databaseTime = _convertTo24HourFormat(time);

                        final taskMain = TaskMain(
                          title: title,
                          category: formattedCategory,
                          time: databaseTime, // Store 24-hour format in database
                          date: dateOnlyString,
                          userId: userProvider.userId,
                          completed: false,
                        );

                        log('Saving calendar task with time: display=$time, database=$databaseTime');

                        final response = await saveTaskToDatabase(taskMain);
                        if (response != null && response['data'] != null) {
                          final taskId = response['data']['id'];

                          // Update the task with database ID (keep display format)
                          final updatedTask = Task(
                            id: taskId,
                            title: localTask.title,
                            category: localTask.category,
                            time: time, // Keep 12-hour format for display
                            date: localTask.date,
                            color: localTask.color,
                            icon: localTask.icon,
                            isChecked: localTask.isChecked,
                          );

                          // Replace in provider
                          taskProvider.editTask(normalizedSelectedDay, localTask, updatedTask);
                          log('Calendar task saved with ID: $taskId');
                        }
                      } catch (e) {
                        log('Failed to save calendar task: $e');
                      }

                      // Add category if new
                      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

                      if (!categoryProvider.categoryExists(formattedCategory)) {
                        await categoryProvider.addAndSaveCategory(formattedCategory, userProvider.userId);
                      }

                      // Show success message using captured messenger
                      final formattedDate = formatDateWithOrdinal(
                        normalizedSelectedDay,
                      );
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            "'$title' has been scheduled for $formattedDate",
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text("Edit Task"),
                onTap: () {
                  Navigator.pop(context);
                  if (taskProvider.tasks[normalizedSelectedDay]?.isNotEmpty ??
                      false) {
                    showEditTaskDialog(normalizedSelectedDay);
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
                  if (taskProvider.tasks[normalizedSelectedDay]?.isNotEmpty ??
                      false) {
                    showDeleteOptionsDialog(normalizedSelectedDay);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("No tasks to delete for this day."),
                      ),
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
    final normalizedSelectedDay = _normalizeDate(selectedDay);
    final tasks = taskProvider.tasks[normalizedSelectedDay] ?? [];
    final formattedDate = formatDateWithOrdinal(normalizedSelectedDay);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Task"),
          content:
              tasks.isEmpty
                  ? Text("No tasks available to delete.")
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        tasks.map((task) {
                          return ListTile(
                            leading: Icon(
                              task.icon ?? Icons.task,
                              color: task.color,
                            ),
                            title: Text(task.title),
                            subtitle: Text("${task.category} - ${task.time}"),

                            // Update the delete button in the showDeleteOptionsDialog method
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                final deletedTaskTitle = task.title;

                                // Check if this is a recurring task on multiple dates
                                if (task.isRecurring &&
                                    taskProvider.isRecurringTaskOnMultipleDates(
                                      task,
                                    )) {
                                  // Show confirmation dialog
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext dialogContext) {
                                      return AlertDialog(
                                        title: Text('Delete Recurring Task'),
                                        content: Text(
                                          'This is a recurring task. Do you want to delete all instances of "$deletedTaskTitle"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text('This Instance Only'),
                                            onPressed: () {
                                              Navigator.of(dialogContext).pop();
                                              taskProvider.deleteTask(
                                                normalizedSelectedDay,
                                                task,
                                              );
                                              Navigator.of(context).pop();

                                              NotificationService.showToast(
                                                context,
                                                "Task Deleted",
                                                "'$deletedTaskTitle' on $formattedDate has been removed",
                                              );
                                            },
                                          ),
                                          TextButton(
                                            child: Text('All Instances'),
                                            onPressed: () {
                                              Navigator.of(dialogContext).pop();
                                              taskProvider.deleteRecurringTask(
                                                task,
                                              );
                                              Navigator.of(context).pop();

                                              NotificationService.showToast(
                                                context,
                                                "Recurring Tasks Deleted",
                                                "All instances of '$deletedTaskTitle' have been removed",
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  // Regular non-recurring task or single instance
                                  taskProvider.deleteTask(
                                    normalizedSelectedDay,
                                    task,
                                  );
                                  Navigator.pop(context);

                                  // Show notification for task deletion
                                  NotificationService.showToast(
                                    context,
                                    "Task Deleted",
                                    "'$deletedTaskTitle' scheduled for $formattedDate has been removed",
                                  );
                                }
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
    final normalizedSelectedDay = _normalizeDate(selectedDay);
    final tasks = taskProvider.tasks[normalizedSelectedDay] ?? [];
    final formattedDate = formatDateWithOrdinal(normalizedSelectedDay);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Task"),
          content:
              tasks.isEmpty
                  ? Text("No tasks available to edit.")
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        tasks.map((task) {
                          return ListTile(
                            leading: Icon(
                              task.icon ?? Icons.task,
                              color: task.color,
                            ),
                            title: Text(task.title),
                            subtitle: Text("${task.category} - ${task.time}"),
                            trailing: IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                final originalTitle = task.title;
                                final isRecurring = task.isRecurring;

                                // Check if this is a recurring task on multiple dates
                                if (isRecurring &&
                                    taskProvider.isRecurringTaskOnMultipleDates(
                                      task,
                                    )) {
                                  // Show confirmation dialog
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext dialogContext) {
                                      return AlertDialog(
                                        title: Text('Edit Recurring Task'),
                                        content: Text(
                                          'This is a recurring task. Do you want to edit all instances of "$originalTitle"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text('This Instance Only'),
                                            onPressed: () {
                                              Navigator.of(dialogContext).pop();
                                              Navigator.pop(
                                                context,
                                              ); // Close the edit task list dialog

                                              // Create a non-recurring copy for this instance
                                              Task nonRecurringCopy = Task(
                                                title: task.title,
                                                category: task.category,
                                                time: task.time,
                                                color: task.color,
                                                date: task.date,
                                                icon: task.icon,
                                                isChecked: task.isChecked,
                                                isRecurring:
                                                    false, // Make it non-recurring
                                              );

                                              // Replace the recurring task with non-recurring one for this date
                                              taskProvider.editTask(
                                                normalizedSelectedDay,
                                                task,
                                                nonRecurringCopy,
                                              );

                                              // Then show the edit dialog for this specific instance
                                              showTaskDialog(
                                                context: context,
                                                dialogTitle: "Edit Task",
                                                initialTitle:
                                                    nonRecurringCopy.title,
                                                initialCategory:
                                                    nonRecurringCopy.category,
                                                initialTime:
                                                    nonRecurringCopy.time,
                                                onSubmit: (
                                                  title,
                                                  category,
                                                  time,
                                                ) async {
                                                  final formattedCategory =
                                                      category[0]
                                                          .toUpperCase() +
                                                      category
                                                          .substring(1)
                                                          .toLowerCase();
                                                  final updatedTask = Task(
                                                    title: title,
                                                    category: formattedCategory,
                                                    time: time,
                                                    date: task.date,

                                                    color:
                                                        nonRecurringCopy.color,
                                                    icon:
                                                        categoryIcons[formattedCategory] ??
                                                        FontAwesomeIcons
                                                            .listCheck,
                                                    isChecked:
                                                        nonRecurringCopy
                                                            .isChecked,
                                                    isRecurring:
                                                        false, // Keep it as a single instance
                                                  );
                                                  taskProvider.editTask(
                                                    normalizedSelectedDay,
                                                    nonRecurringCopy,
                                                    updatedTask,
                                                  );

                                                  // Add the category if it's new
                                                  final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
                                                  final userProvider = Provider.of<UserProvider>(context, listen: false);

                                                  if (!categoryProvider.categoryExists(formattedCategory)) {
                                                    await categoryProvider.addAndSaveCategory(formattedCategory, userProvider.userId);
                                                  }

                                                  NotificationService.showToast(
                                                    context,
                                                    "Task Updated",
                                                    "'$originalTitle' scheduled for $formattedDate has been updated",
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          TextButton(
                                            child: Text('All Instances'),
                                            onPressed: () {
                                              Navigator.of(dialogContext).pop();
                                              Navigator.pop(
                                                context,
                                              ); // Close the edit task list dialog

                                              showTaskDialog(
                                                context: context,
                                                dialogTitle:
                                                    "Edit All Recurring Tasks",
                                                initialTitle: task.title,
                                                initialCategory: task.category,
                                                initialTime: task.time,
                                                // Fix the incomplete Task constructor around line 587:
onSubmit: (title, category, time) async {
  final formattedCategory = category[0].toUpperCase() + category.substring(1).toLowerCase();
  
  final updatedTask = Task(
    id: task.id, // Add the missing id property
    title: title,
    category: formattedCategory,
    time: time,
    date: task.date,
    color: task.color, // Keep the same color
    icon: categoryIcons[formattedCategory] ?? FontAwesomeIcons.listCheck,
    isChecked: task.isChecked,
    isRecurring: true, // Keep it recurring
  );

  // Update all recurring instances
  taskProvider.editRecurringTask(
    task,
    updatedTask,
  );

  // Add the category if needed
  final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
  final userProvider = Provider.of<UserProvider>(context, listen: false);

  if (!categoryProvider.categoryExists(formattedCategory)) {
    await categoryProvider.addAndSaveCategory(formattedCategory, userProvider.userId);
  }

  NotificationService.showToast(
    context,
    "All Tasks Updated",
    "All instances of '${task.title}' have been updated",
  );
},
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  // Regular task or single recurring instance
                                  Navigator.pop(
                                    context,
                                  ); // Close the edit task list dialog

                                  // Show the standard edit dialog
                                  showTaskDialog(
                                    context: context,
                                    dialogTitle: "Edit Task",
                                    initialTitle: task.title,
                                    initialCategory: task.category,
                                    initialTime: task.time,
                                    onSubmit: (title, category, time) async {
  // Capture any context-dependent objects early
  final mainScaffoldMessenger = ScaffoldMessenger.of(context);
  final formattedCategory = category[0].toUpperCase() + category.substring(1).toLowerCase();
  
  final updatedTask = Task(
    title: title,
    category: formattedCategory,
    time: time,
    date: task.date,
    color: task.color,
    icon: categoryIcons[formattedCategory] ?? FontAwesomeIcons.listCheck,
    isChecked: task.isChecked,
    isRecurring: task.isRecurring,
  );
  
  taskProvider.editTask(normalizedSelectedDay, task, updatedTask);

  // Add the category if it's new
  final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
  final userProvider = Provider.of<UserProvider>(context, listen: false);

  if (!categoryProvider.categoryExists(formattedCategory)) {
    await categoryProvider.addAndSaveCategory(formattedCategory, userProvider.userId);
  }

  // Use captured messenger
  mainScaffoldMessenger.showSnackBar(
    SnackBar( 
      content: Text("'${task.title}' has been updated"),
    ),
  );
}
                                    );
                                }
                              },
                            ),
                          );
                        }).toList(),
                  ),
        );
      },
    );
  }

  // Add this helper method to the _CalendarState class
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Add these helper methods to _CalendarState class in calendar.dart:

// Helper method to convert 24-hour time from database to 12-hour display format
String _convertTo12HourFormat(String time24Hour) {
  try {
    String time = time24Hour.trim();
    
    // If it already has AM/PM, return as is
    if (time.toLowerCase().contains('am') || time.toLowerCase().contains('pm')) {
      return time;
    }
    
    // Split by colon
    List<String> parts = time.split(':');
    if (parts.length < 2) return time; // Return original if can't parse
    
    int hour = int.parse(parts[0]);
    String minute = parts[1];
    
    // Convert from 24-hour to 12-hour format
    String period = hour >= 12 ? 'PM' : 'AM';
    
    if (hour == 0) {
      hour = 12; // 00:xx becomes 12:xx AM
    } else if (hour > 12) {
      hour = hour - 12; // 22:xx becomes 10:xx PM
    }
    // 12:xx stays 12:xx PM, 1-11:xx stay the same with appropriate AM/PM
    
    return '$hour:${minute.padLeft(2, '0')} $period'; // Changed padStart to padLeft
  } catch (e) {
    log('Error converting time format: $e');
    return time24Hour; // Return original if conversion fails
  }
}

// Helper method to convert 12-hour format to 24-hour format for database storage
String _convertTo24HourFormat(String time12Hour) {
  try {
    String time = time12Hour.toLowerCase().trim();
    bool isPM = time.contains('pm');
    bool isAM = time.contains('am');
    
    // Remove AM/PM
    time = time.replaceAll('pm', '').replaceAll('am', '').trim();
    
    // Split by colon
    List<String> parts = time.split(':');
    if (parts.length < 2) return time12Hour; // Return original if can't parse
    
    int hour = int.parse(parts[0]);
    String minute = parts[1];
    
    // Convert to 24-hour format
    if (isPM && hour != 12) {
      hour += 12; // 1 PM = 13, 10 PM = 22
    } else if (isAM && hour == 12) {
      hour = 0; // 12 AM = 00
    }
    
    return '${hour.toString().padLeft(2, '0')}:$minute'; // Changed padStart to padLeft
  } catch (e) {
    log('Error converting time format: $e');
    return time12Hour; // Return original if conversion fails
  }
}

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final profileImagePath =
        Provider.of<UserProvider>(context).profileImagePath;

    // Get theme-specific colors
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // final primaryColor = Theme.of(context).primaryColor;
    final cardColor = OtakuPlannerTheme.getCardColor(context);
    final textColor = OtakuPlannerTheme.getTextColor(context);
    // final borderColor = OtakuPlannerTheme.getBorderColor(context);
    final buttonColor = OtakuPlannerTheme.getButtonColor(context);

    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/images/otaku.jpg", fit: BoxFit.contain),
        centerTitle: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 2,
        scrolledUnderElevation: 2,
        title: Text(
          "OtakuPlanner",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _showNotificationsDialog,
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: NotificationBadge(
                child: CircleAvatar(
                  backgroundColor: buttonColor,
                  child: FaIcon(
                    FontAwesomeIcons.bell,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Profile()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: CircleAvatar(
                backgroundColor: buttonColor,
                backgroundImage:
                    profileImagePath.isNotEmpty
                        ? FileImage(File(profileImagePath))
                        : null,
                child:
                    profileImagePath.isEmpty
                        ? Icon(Icons.person, color: Colors.grey)
                        : null,
              ),
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
                return !day.isBefore(
                  DateTime.now().subtract(Duration(days: 1)),
                );
              },
              onDaySelected: (selectedDay, focusedDay) {
                final normalizedSelectedDay = _normalizeDate(selectedDay);
                setState(() {
                  _selectedDay = normalizedSelectedDay;
                  _focusedDay = focusedDay;
                });
                showDayOptionsDialog(normalizedSelectedDay);
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? Colors.blueGrey.shade700
                          : Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: buttonColor,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                disabledTextStyle: TextStyle(color: Colors.grey.shade400),
                outsideDaysVisible: false,
                // Add theme-specific text styling
                defaultTextStyle: TextStyle(color: textColor),
                weekendTextStyle: TextStyle(
                  color: isDarkMode ? Colors.red.shade300 : Colors.red,
                ),
                selectedTextStyle: TextStyle(color: Colors.white),
                todayTextStyle: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(color: textColor, fontSize: 18),
                leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
                rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  // Normalize the date to check for tasks
                  final tasksForDay = taskProvider.tasks[_normalizeDate(day)];
                  if (tasksForDay != null && tasksForDay.isNotEmpty) {
                    // Get the color from the first task, or use a default color
                    final Color dotColor =
                        tasksForDay.isNotEmpty
                            ? tasksForDay.first.color
                            : buttonColor;

                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: dotColor,
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
              "Tasks for ${_selectedDay != null ? formatDateWithOrdinal(_selectedDay!) : 'Selected Day'}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child:
                  _selectedDay == null
                      ? Center(child: Text("Select a day to view tasks"))
                      : (() {
                        final normalizedSelectedDay = _normalizeDate(
                          _selectedDay!,
                        );
                        final tasksForDay =
                            taskProvider.tasks[normalizedSelectedDay] ?? [];

                        return tasksForDay.isEmpty
                            ? Center(
                              child: Text(
                                "No tasks available for this day.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textColor.withOpacity(0.7),
                                ),
                              ),
                            )
                            : ListView.builder(
                              itemCount: tasksForDay.length,
                              itemBuilder: (context, index) {
                                final task = tasksForDay[index];

                                // Replace the dialog content part with this implementation:

                                return GestureDetector(
                                  onTap: () {
                                    // Show task details modal when the task is tapped
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        return AlertDialog(
                                          backgroundColor: cardColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Task Details",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: textColor,
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.close,
                                                  color: textColor,
                                                ),
                                                onPressed:
                                                    () =>
                                                        Navigator.of(
                                                          dialogContext,
                                                        ).pop(),
                                              ),
                                            ],
                                          ),
                                          content: Container(
                                            width: double.maxFinite,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Task title
                                                  Text(
                                                    task.title,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 22,
                                                      color: textColor,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),

                                                  // Recurring tag - only show if task is recurring
                                                  if (task.isRecurring == true)
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                        bottom: 16,
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            isDarkMode
                                                                ? Colors
                                                                    .blue
                                                                    .shade900
                                                                : Colors
                                                                    .blue
                                                                    .shade100,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.repeat,
                                                            size: 16,
                                                            color:
                                                                isDarkMode
                                                                    ? Colors
                                                                        .blue
                                                                        .shade300
                                                                    : Colors
                                                                        .blue,
                                                          ),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            "Recurring (Custom-Weekly)",
                                                            style: TextStyle(
                                                              color:
                                                                  isDarkMode
                                                                      ? Colors
                                                                          .blue
                                                                          .shade300
                                                                      : Colors
                                                                          .blue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                  // Category
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                          vertical: 8,
                                                        ),
                                                    padding: EdgeInsets.all(16),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          isDarkMode
                                                              ? Colors
                                                                  .grey
                                                                  .shade800
                                                              : Colors
                                                                  .grey
                                                                  .shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          backgroundColor: task
                                                              .color
                                                              .withOpacity(0.2),
                                                          child: Icon(
                                                            task.icon ??
                                                                FontAwesomeIcons
                                                                    .listCheck,
                                                            color: task.color,
                                                            size: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 16),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Category",
                                                              style: TextStyle(
                                                                color: textColor
                                                                    .withOpacity(
                                                                      0.6,
                                                                    ),
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            Text(
                                                              task.category,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                color:
                                                                    textColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Date
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                          vertical: 8,
                                                        ),
                                                    padding: EdgeInsets.all(16),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          isDarkMode
                                                              ? Colors
                                                                  .grey
                                                                  .shade800
                                                              : Colors
                                                                  .grey
                                                                  .shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          backgroundColor:
                                                              (isDarkMode
                                                                  ? Colors
                                                                      .blue
                                                                      .shade700
                                                                  : Colors
                                                                      .blue
                                                                      .shade100),
                                                          child: Icon(
                                                            Icons
                                                                .calendar_today,
                                                            color:
                                                                isDarkMode
                                                                    ? Colors
                                                                        .blue
                                                                        .shade300
                                                                    : Colors
                                                                        .blue,
                                                            size: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 16),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Date",
                                                              style: TextStyle(
                                                                color: textColor
                                                                    .withOpacity(
                                                                      0.6,
                                                                    ),
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            Text(
                                                              DateFormat(
                                                                "EEEE, MMMM d, yyyy",
                                                              ).format(
                                                                normalizedSelectedDay,
                                                              ),
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 12.5,
                                                                color:
                                                                    textColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Time
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                          vertical: 8,
                                                        ),
                                                    padding: EdgeInsets.all(16),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          isDarkMode
                                                              ? Colors
                                                                  .grey
                                                                  .shade800
                                                              : Colors
                                                                  .grey
                                                                  .shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          backgroundColor:
                                                              (isDarkMode
                                                                  ? Colors
                                                                      .orange
                                                                      .shade700
                                                                  : Colors
                                                                      .orange
                                                                      .shade100),
                                                          child: Icon(
                                                            Icons.access_time,
                                                            color:
                                                                isDarkMode
                                                                    ? Colors
                                                                        .orange
                                                                        .shade300
                                                                    : Colors
                                                                        .orange,
                                                            size: 16,
                                                          ),
                                                        ),
                                                        SizedBox(width: 16),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Time",
                                                              style: TextStyle(
                                                                color: textColor
                                                                    .withOpacity(
                                                                      0.6,
                                                                    ),
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            Text(
                                                              task.time,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                color:
                                                                    textColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Completion status - Not editable
                                                  // Replace the existing Completion status section with this checkbox version:

                                                  // Completion status with checkbox
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                          vertical: 8,
                                                        ),
                                                    padding: EdgeInsets.all(16),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          isDarkMode
                                                              ? Colors
                                                                  .grey
                                                                  .shade800
                                                              : Colors
                                                                  .grey
                                                                  .shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Checkbox(
                                                          value: task.isChecked,
                                                          activeColor:
                                                              Colors.green,
                                                          checkColor:
                                                              Colors.white,
                                                          // onChanged: (bool? newValue) {
                                                          //   // Create an updated task with toggled completion status
                                                          //   final updatedTask = Task(
                                                          //     title: task.title,
                                                          //     category: task.category,
                                                          //                                                     date: task.date,

                                                          //     time: task.time,
                                                          //     color: task.color,
                                                          //     icon: task.icon,
                                                          //     isChecked: newValue ?? false,
                                                          //     isRecurring: task.isRecurring,
                                                          //   );

                                                          //   // Update the task in the provider
                                                          //   taskProvider.editTask(
                                                          //     normalizedSelectedDay,
                                                          //     task,
                                                          //     updatedTask,
                                                          //   );

                                                          //   // Close the dialog
                                                          //   Navigator.of(dialogContext).pop();

                                                          //   // Show a toast notification
                                                          //   NotificationService.showToast(
                                                          //     context,
                                                          //     newValue == true ? "Task Completed" : "Task Marked as Incomplete",
                                                          //     "'${task.title}' has been marked as ${newValue == true ? 'complete' : 'incomplete'}",
                                                          //   );

                                                          //   // Force rebuild of the view
                                                          //   setState(() {});
                                                          // },
                                                          onChanged: (bool? newValue) async {
  // Capture ALL context-dependent objects IMMEDIATELY before any async operations
  final taskProvider = Provider.of<TaskProvider>(context, listen: false);
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(dialogContext);
  
  // Store values that might be needed later
  final taskId = task.id;
  final newCompletionStatus = newValue ?? false;

  try {
    // Create updated task
    final updatedTask = Task(
      id: taskId, // Preserve database ID
      title: task.title,
      category: task.category,
      date: task.date,
      time: task.time,
      color: task.color,
      icon: task.icon,
      isChecked: newCompletionStatus,
      isRecurring: task.isRecurring,
    );

    // Update in TaskProvider FIRST
    taskProvider.editTask(normalizedSelectedDay, task, updatedTask);

    // Update in database if task has an ID
    if (taskId != null) {
      try {
        // Convert time to 24-hour format for database
        final databaseTime = _convertTo24HourFormat(task.time);
        
        final taskMain = TaskMain(
          id: taskId,
          title: task.title,
          category: task.category,
          time: databaseTime, // Use 24-hour format for database
          date: task.date,
          userId: userProvider.userId,
          completed: newCompletionStatus,
        );

        log('Updating task completion: display=${task.time}, database=$databaseTime');
        await updateTaskInDatabase(taskMain);
        log('Task completion status updated in database');
      } catch (e) {
        log('Failed to update task completion in database: $e');
      }
    }

    // Close dialog and show notification using captured objects
    navigator.pop();
    
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          newCompletionStatus ? "Task Completed" : "Task Marked as Incomplete",
        ),
      ),
    );

  } catch (e) {
    log('Error in task completion: $e');
    // Still try to close dialog if possible
    try {
      navigator.pop();
    } catch (_) {}
    
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text("Failed to update task completion"),
      ),
    );
  }
  
  // Rebuild the UI only if the widget is still mounted
  if (mounted) {
    setState(() {});
  }
},
                                                        ),
                                                        SizedBox(width: 12),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Status",
                                                              style: TextStyle(
                                                                color: textColor
                                                                    .withOpacity(
                                                                      0.6,
                                                                    ),
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            Text(
                                                              task.isChecked
                                                                  ? "Completed"
                                                                  : "Not completed",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                color:
                                                                    task.isChecked
                                                                        ? Colors
                                                                            .green
                                                                        : textColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  child: TextButton.icon(
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors.white,
                                                    ),
                                                    label: Text(
                                                      "Delete",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(
                                                        dialogContext,
                                                      ).pop();
                                                      // Handle delete - this actually needs to show your existing delete confirmation dialog
                                                      if (task.isRecurring ==
                                                              true &&
                                                          taskProvider
                                                              .isRecurringTaskOnMultipleDates(
                                                                task,
                                                              )) {
                                                        // Show delete options for recurring tasks
                                                        showDialog(
                                                          context: context,
                                                          builder: (
                                                            BuildContext
                                                            confirmContext,
                                                          ) {
                                                            return AlertDialog(
                                                              backgroundColor:
                                                                  cardColor,
                                                              title: Text(
                                                                'Delete Recurring Task',
                                                                style: TextStyle(
                                                                  color:
                                                                      textColor,
                                                                ),
                                                              ),
                                                              content: Text(
                                                                'Do you want to delete all instances of "${task.title}"?',
                                                                style: TextStyle(
                                                                  color:
                                                                      textColor,
                                                                ),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  child: Text(
                                                                    'This Instance Only',
                                                                  ),
                                                                  onPressed: () {
                                                                    Navigator.of(
                                                                      confirmContext,
                                                                    ).pop();

                                                                    // Delete this instance only
                                                                    taskProvider.deleteTask(
                                                                      normalizedSelectedDay,
                                                                      task,
                                                                    );

                                                                    NotificationService.showToast(
                                                                      context,
                                                                      "Task Deleted",
                                                                      "This instance of '${task.title}' has been deleted",
                                                                    );
                                                                  },
                                                                ),
                                                                TextButton(
                                                                  child: Text(
                                                                    'All Instances',
                                                                  ),
                                                                  onPressed: () {
                                                                    Navigator.of(
                                                                      confirmContext,
                                                                    ).pop();

                                                                    // Delete all instances
                                                                    taskProvider.deleteRecurringTask(
                                                                      task,
                                                                    );

                                                                    NotificationService.showToast(
                                                                      context,
                                                                      "Recurring Tasks Deleted",
                                                                      "All instances of '${task.title}' have been deleted",
                                                                    );
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        // For non-recurring tasks
                                                        showDialog(
                                                          context: context,
                                                          builder: (
                                                            BuildContext
                                                            confirmContext,
                                                          ) {
                                                            return AlertDialog(
                                                              backgroundColor:
                                                                  cardColor,
                                                              title: Text(
                                                                'Delete Task',
                                                                style: TextStyle(
                                                                  color:
                                                                      textColor,
                                                                ),
                                                              ),
                                                              content: Text(
                                                                'Are you sure you want to delete "${task.title}"?',
                                                                style: TextStyle(
                                                                  color:
                                                                      textColor,
                                                                ),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  child: Text(
                                                                    'Cancel',
                                                                  ),
                                                                  onPressed: () {
                                                                    Navigator.of(
                                                                      confirmContext,
                                                                    ).pop();
                                                                  },
                                                                ),
                                                                TextButton(
                                                                  child: Text(
                                                                    'Delete',
                                                                  ),
                                                                  onPressed: () {
                                                                    Navigator.of(
                                                                      confirmContext,
                                                                    ).pop();
                                                                    // Delete from database FIRST if task has ID
                                                                    if (task.id !=
                                                                        null) {
                                                                      deleteTaskFromDatabase(
                                                                            task.id!,
                                                                          )
                                                                          .then((
                                                                            _,
                                                                          ) {
                                                                            log(
                                                                              'Task deleted from database',
                                                                            );
                                                                          })
                                                                          .catchError((
                                                                            e,
                                                                          ) {
                                                                            log(
                                                                              'Failed to delete task from database: $e',
                                                                            );
                                                                          });
                                                                    }

                                                                    // Delete from provider
                                                                    taskProvider
                                                                        .deleteTask(
                                                                          normalizedSelectedDay,
                                                                          task,
                                                                        );

                                                                    // Show notification using captured messenger
                                                                    final scaffoldMessenger =
                                                                        ScaffoldMessenger.of(
                                                                          context,
                                                                        );
                                                                    scaffoldMessenger.showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text(
                                                                              "'${task.title}' has been deleted",
                                                                            ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: TextButton.icon(
                                                    icon: Icon(
                                                      Icons.edit,
                                                      color: Colors.white,
                                                    ),
                                                    label: Text(
                                                      "Edit",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          buttonColor,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(
                                                        dialogContext,
                                                      ).pop();

                                                      // Handle edit - use existing showEditTaskDialog or direct implementation
                                                      if (task.isRecurring ==
                                                              true &&
                                                          taskProvider
                                                              .isRecurringTaskOnMultipleDates(
                                                                task,
                                                              )) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (
                                                            BuildContext
                                                            confirmContext,
                                                          ) {
                                                            return AlertDialog(
                                                              backgroundColor:
                                                                  cardColor,
                                                              title: Text(
                                                                'Edit Recurring Task',
                                                                style: TextStyle(
                                                                  color:
                                                                      textColor,
                                                                ),
                                                              ),
                                                              content: Text(
                                                                'Do you want to edit all instances of "${task.title}"?',
                                                                style: TextStyle(
                                                                  color:
                                                                      textColor,
                                                                ),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  child: Text(
                                                                    'This Instance Only',
                                                                  ),
                                                                  onPressed: () {
                                                                    Navigator.of(
                                                                      confirmContext,
                                                                    ).pop();

                                                                    // Create a non-recurring copy for this instance
                                                                    Task
                                                                    nonRecurringCopy = Task(
                                                                      title:
                                                                          task.title,
                                                                      category:
                                                                          task.category,
                                                                      time:
                                                                          task.time,
                                                                      date:
                                                                          task.date,

                                                                      color:
                                                                          task.color,
                                                                      icon:
                                                                          task.icon,
                                                                      isChecked:
                                                                          task.isChecked,
                                                                      isRecurring:
                                                                          false, // Make it non-recurring
                                                                    );

                                                                    // Replace the recurring task with non-recurring one for this date
                                                                    taskProvider.editTask(
                                                                      normalizedSelectedDay,
                                                                      task,
                                                                      nonRecurringCopy,
                                                                    );

                                                                    // Show the edit dialog for this specific instance
                                                                    showTaskDialog(
                                                                      context:
                                                                          context,
                                                                      dialogTitle:
                                                                          "Edit Task",
                                                                      initialTitle:
                                                                          nonRecurringCopy
                                                                              .title,
                                                                      initialCategory:
                                                                          nonRecurringCopy
                                                                              .category,
                                                                      initialTime:
                                                                          nonRecurringCopy
                                                                              .time,
                                                                      onSubmit: (
                                                                        title,
                                                                        category,
                                                                        time,
                                                                      ) async {
                                                                        final formattedCategory =
                                                                            category[0].toUpperCase() +
                                                                            category.substring(1).toLowerCase();
                                                                        final updatedTask = Task(
                                                                          title:
                                                                              title,
                                                                          category:
                                                                              formattedCategory,
                                                                          time:
                                                                              time,
                                                                          date:
                                                                              task.date,

                                                                          color:
                                                                              nonRecurringCopy.color,
                                                                          icon:
                                                                              categoryIcons[formattedCategory] ??
                                                                              FontAwesomeIcons.listCheck,
                                                                          isChecked:
                                                                              nonRecurringCopy.isChecked,
                                                                          isRecurring:
                                                                              false, // Keep it as a single instance
                                                                        );
                                                                        taskProvider.editTask(
                                                                          normalizedSelectedDay,
                                                                          nonRecurringCopy,
                                                                          updatedTask,
                                                                        );

                                                                        // Add the category if it's new
                                                                        final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
                                                                        final userProvider = Provider.of<UserProvider>(context, listen: false);

                                                                        if (!categoryProvider.categoryExists(formattedCategory)) {
                                                                          await categoryProvider.addAndSaveCategory(formattedCategory, userProvider.userId);
                                                                        }

                                                                        NotificationService.showToast(
                                                                          context,
                                                                          "Task Updated",
                                                                          "'${task.title}' for ${formatDateWithOrdinal(normalizedSelectedDay)} has been updated",
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                                TextButton(
                                                                  child: Text(
                                                                    'All Instances',
                                                                  ),
                                                                  onPressed: () {
                                                                    Navigator.of(
                                                                      confirmContext,
                                                                    ).pop();

                                                                    // Show the edit dialog for all recurring instances
                                                                    showTaskDialog(
                                                                      context:
                                                                          context,
                                                                      dialogTitle:
                                                                          "Edit All Recurring Tasks",
                                                                      initialTitle:
                                                                          task.title,
                                                                      initialCategory:
                                                                          task.category,
                                                                      initialTime:
                                                                          task.time,
                                                                      onSubmit: (
                                                                        title,
                                                                        category,
                                                                        time,
                                                                      ) async {
                                                                        final formattedCategory =
                                                                            category[0].toUpperCase() +
                                                                            category.substring(1).toLowerCase();
                                                                        final updatedTask = Task(
                                                                          title:
                                                                              title,
                                                                          category:
                                                                              formattedCategory,
                                                                          time:
                                                                              time,
                                                                          date:
                                                                              task.date,

                                                                          color:
                                                                              task.color,
                                                                          icon:
                                                                              categoryIcons[formattedCategory] ??
                                                                              FontAwesomeIcons.listCheck,
                                                                          isChecked:
                                                                              task.isChecked,
                                                                          isRecurring:
                                                                              true, // Keep it recurring
                                                                        );

                                                                        // Update all recurring instances
                                                                        taskProvider.editRecurringTask(
                                                                          task,
                                                                          updatedTask,
                                                                        );

                                                                        // Add the category if needed
                                                                        final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
                                                                        final userProvider = Provider.of<UserProvider>(context, listen: false);

                                                                        if (!categoryProvider.categoryExists(formattedCategory)) {
                                                                          await categoryProvider.addAndSaveCategory(formattedCategory, userProvider.userId);
                                                                        }

                                                                        NotificationService.showToast(
                                                                          context,
                                                                          "All Tasks Updated",
                                                                          "All instances of '${task.title}' have been updated",
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        // For non-recurring tasks, show the standard edit dialog
                                                        showTaskDialog(
                                                          context: context,
                                                          dialogTitle:
                                                              "Edit Task",
                                                          initialTitle:
                                                              task.title,
                                                          initialCategory:
                                                              task.category,
                                                          initialTime:
                                                              task.time,
                                                          onSubmit: (
                                                            title,
                                                            category,
                                                            time,
                                                          ) async {
                                                            final formattedCategory =
                                                                category[0]
                                                                    .toUpperCase() +
                                                                category
                                                                    .substring(
                                                                      1,
                                                                    )
                                                                    .toLowerCase();
                                                            final updatedTask = Task(
                                                              title: title,
                                                              category:
                                                                  formattedCategory,
                                                              time: time,
                                                              date: task.date,

                                                              color:
                                                                  task.color, // Keep the same color
                                                              icon:
                                                                  categoryIcons[formattedCategory] ??
                                                                  FontAwesomeIcons
                                                                      .listCheck,
                                                              isChecked:
                                                                  task.isChecked,
                                                              isRecurring:
                                                                  task.isRecurring,
                                                            );
                                                            taskProvider.editTask(
                                                              normalizedSelectedDay,
                                                              task,
                                                              updatedTask,
                                                            );

                                                            // Add the category if it's new
                                                            final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
                                                            final userProvider = Provider.of<UserProvider>(context, listen: false);

                                                            if (!categoryProvider.categoryExists(formattedCategory)) {
                                                              await categoryProvider.addAndSaveCategory(formattedCategory, userProvider.userId);
                                                            }

                                                            NotificationService.showToast(
                                                              context,
                                                              "Task Updated",
                                                              "'${task.title}' has been updated",
                                                            );
                                                          },
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Card(
                                    color: cardColor,
                                    elevation: 1,
                                    margin: EdgeInsets.symmetric(vertical: 4),
                                    child: ListTile(
                                      leading: Icon(
                                        task.icon ?? FontAwesomeIcons.listCheck,
                                        color: task.color,
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              task.title,
                                              style: TextStyle(
                                                color: textColor,
                                                decoration:
                                                    task.isChecked
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : null,
                                              ),
                                            ),
                                          ),
                                          if (task.isChecked)
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    "Done",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        "${task.category} - ${task.time}",
                                        style: TextStyle(
                                          color: textColor.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                  ),
                                );

                                // return GestureDetector(
                                //   onTap:() {

                                //   },
                                //   child: Card(
                                //     color: cardColor,
                                //     elevation: 1,
                                //     margin: EdgeInsets.symmetric(vertical: 4),
                                //     child: ListTile(
                                //       leading: Icon(
                                //         task.icon ?? FontAwesomeIcons.listCheck,
                                //         color: task.color,
                                //       ),
                                //       title: Row(
                                //         children: [
                                //           Expanded(
                                //             child: Text(
                                //               task.title,
                                //               style: TextStyle(
                                //                 color: textColor,
                                //                 decoration: task.isChecked ? TextDecoration.lineThrough : null,
                                //               ),
                                //             ),
                                //           ),
                                //           if (task.isChecked)
                                //             Container(
                                //               padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                //               decoration: BoxDecoration(
                                //                 color: Colors.green,
                                //                 borderRadius: BorderRadius.circular(12),
                                //               ),
                                //               child: Row(
                                //                 mainAxisSize: MainAxisSize.min,
                                //                 children: [
                                //                   Icon(Icons.check, color: Colors.white, size: 12),
                                //                   SizedBox(width: 2),
                                //                   Text(
                                //                     "Done",
                                //                     style: TextStyle(
                                //                       color: Colors.white,
                                //                       fontSize: 10,
                                //                       fontWeight: FontWeight.bold,
                                //                     ),
                                //                   ),
                                //                 ],
                                //               ),
                                //             ),
                                //         ],
                                //       ),
                                //       subtitle: Text(
                                //         "${task.category} - ${task.time}",
                                //         style: TextStyle(
                                //           color: textColor.withOpacity(0.7),
                                //         ),
                                //       ),
                                //       trailing: Row(
                                //         mainAxisSize: MainAxisSize.min,
                                //         children: [
                                //           // Remove the checkbox and only keep edit/delete buttons
                                //           IconButton(
                                //             icon: Icon(
                                //               Icons.edit,
                                //               color: isDarkMode ? Colors.lightBlue : Colors.blue,
                                //             ),
                                //             onPressed: () {
                                //               // Keep your existing edit logic
                                //             },
                                //           ),
                                //           IconButton(
                                //             icon: Icon(
                                //               Icons.delete,
                                //               color: Colors.red,
                                //             ),
                                //             onPressed: () {
                                //               // Keep your existing delete logic
                                //             },
                                //           ),
                                //         ],
                                //       ),
                                //     ),
                                //   ),
                                // );
                                // return Card(
                                //   color: cardColor,
                                //   elevation: 1,
                                //   margin: EdgeInsets.symmetric(vertical: 4),
                                //   child: ListTile(
                                //     leading: Icon(
                                //       task.icon ?? FontAwesomeIcons.listCheck,
                                //       color: task.color,
                                //     ),
                                //     title: Text(
                                //       task.title,
                                //       style: TextStyle(color: textColor),
                                //     ),
                                //     subtitle: Text(
                                //       "${task.category} - ${task.time}",
                                //       style: TextStyle(
                                //         color: textColor.withOpacity(0.7),
                                //       ),
                                //     ),
                                //     trailing: Row(
                                //       mainAxisSize: MainAxisSize.min,
                                //       children: [
                                //         IconButton(
                                //           icon: Icon(
                                //             Icons.edit,
                                //             color:
                                //                 isDarkMode
                                //                     ? Colors.lightBlue
                                //                     : Colors.blue,
                                //           ),
                                //           onPressed: () {
                                //             if (task.isRecurring &&
                                //                 taskProvider
                                //                     .isRecurringTaskOnMultipleDates(
                                //                       task,
                                //                     )) {
                                //               showDialog(
                                //                 context: context,
                                //                 builder: (context) {
                                //                   return AlertDialog(
                                //                     title: Text(
                                //                       'Edit Recurring Task',
                                //                     ),
                                //                     content: Text(
                                //                       'This is a recurring task. Do you want to edit all instances?',
                                //                     ),
                                //                     actions: [
                                //                       TextButton(
                                //                         child: Text(
                                //                           'This Instance Only',
                                //                         ),
                                //                         onPressed: () {
                                //                           Navigator.pop(
                                //                             context,
                                //                           );
                                //                           // Edit just this instance logic
                                //                           // Same as above
                                //                         },
                                //                       ),
                                //                       TextButton(
                                //                         child: Text(
                                //                           'All Instances',
                                //                         ),
                                //                         onPressed: () {
                                //                           Navigator.pop(
                                //                             context,
                                //                           );
                                //                           // Edit all instances logic
                                //                           // Same as above
                                //                         },
                                //                       ),
                                //                     ],
                                //                   );
                                //                 },
                                //               );
                                //             } else {
                                //               // Edit single task
                                //               // Same as above
                                //             }
                                //           },
                                //         ),
                                //         IconButton(
                                //           icon: Icon(
                                //             Icons.delete,
                                //             color: Colors.red,
                                //           ),
                                //           onPressed: () {
                                //             if (task.isRecurring &&
                                //                 taskProvider
                                //                     .isRecurringTaskOnMultipleDates(
                                //                       task,
                                //                     )) {
                                //               showDialog(
                                //                 context: context,
                                //                 builder: (context) {
                                //                   return AlertDialog(
                                //                     title: Text(
                                //                       'Delete Recurring Task',
                                //                     ),
                                //                     content: Text(
                                //                       'This is a recurring task. Do you want to delete all instances?',
                                //                     ),
                                //                     actions: [
                                //                       TextButton(
                                //                         child: Text(
                                //                           'This Instance Only',
                                //                         ),
                                //                         onPressed: () {
                                //                           Navigator.pop(
                                //                             context,
                                //                           );
                                //                           taskProvider.deleteTask(
                                //                             normalizedSelectedDay,
                                //                             task,
                                //                           );
                                //                           NotificationService.showToast(
                                //                             context,
                                //                             "Task Deleted",
                                //                             "This instance of '${task.title}' has been deleted",
                                //                           );
                                //                         },
                                //                       ),
                                //                       TextButton(
                                //                         child: Text(
                                //                           'All Instances',
                                //                         ),
                                //                         onPressed: () {
                                //                           Navigator.pop(
                                //                             context,
                                //                           );
                                //                           taskProvider
                                //                               .deleteRecurringTask(
                                //                                 task,
                                //                               );
                                //                           NotificationService.showToast(
                                //                             context,
                                //                             "Recurring Tasks Deleted",
                                //                             "All instances of '${task.title}' have been deleted",
                                //                           );
                                //                         },
                                //                       ),
                                //                     ],
                                //                   );
                                //                 },
                                //               );
                                //             } else {
                                //               // Delete single task
                                //               // Same as above
                                //             }
                                //           },
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // );
                              },
                            );
                      })(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
      floatingActionButton: FloatingActionButton(
        backgroundColor: buttonColor,
        child: Icon(Icons.add, color: Colors.white),

// Replace the FloatingActionButton onPressed method:
onPressed: () async {
  if (_selectedDay != null) {
    // Capture ALL context-dependent objects IMMEDIATELY
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final normalizedSelectedDay = _normalizeDate(_selectedDay!);
    final hasTasks = taskProvider.tasks[normalizedSelectedDay]?.isNotEmpty ?? false;

    // Check if selected day is today
    final bool isToday = DateTime(
      normalizedSelectedDay.year,
      normalizedSelectedDay.month,
      normalizedSelectedDay.day,
    ).isAtSameMomentAs(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );

    showTaskDialog(
      context: context,
      dialogTitle: hasTasks
          ? "Add Another Task for ${formatDateWithOrdinal(normalizedSelectedDay)}"
          : "Add Task for ${formatDateWithOrdinal(normalizedSelectedDay)}",
      onSubmit: (title, category, time) async {
        // Time validation for today
        if (isToday) {
          final now = DateTime.now();
          final timeFormat = DateFormat("hh:mm a");
          try {
            final taskTime = timeFormat.parse(time);
            final taskDateTime = DateTime(
              now.year,
              now.month,
              now.day,
              taskTime.hour,
              taskTime.minute,
            );

            if (taskDateTime.isBefore(now)) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(
                    "Cannot schedule tasks for times that have already passed",
                  ),
                ),
              );
              return;
            }
          } catch (e) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text("Please enter a valid time format"),
              ),
            );
            return;
          }
        }

        final formattedCategory = category[0].toUpperCase() + category.substring(1).toLowerCase();

        // Create local task WITHOUT ID first (store display time)
        final localTask = Task(
          title: title,
          category: formattedCategory,
          time: time, // Keep 12-hour format for display
          date: normalizedSelectedDay.toIso8601String(),
          color: Task.getRandomColor(),
          icon: categoryIcons[formattedCategory] ?? FontAwesomeIcons.listCheck,
          isChecked: false,
        );

        // Add to TaskProvider immediately
        taskProvider.addTask(normalizedSelectedDay, localTask);

        // Save to database in background with 24-hour format
        try {
          final dateOnlyString = '${normalizedSelectedDay.year}-${normalizedSelectedDay.month.toString().padLeft(2, '0')}-${normalizedSelectedDay.day.toString().padLeft(2, '0')}';

          // Convert to 24-hour format for database storage
          final databaseTime = _convertTo24HourFormat(time);

          final taskMain = TaskMain(
            title: title,
            category: formattedCategory,
            time: databaseTime, // Store 24-hour format in database
            date: dateOnlyString,
            userId: userProvider.userId,
            completed: false,
          );

          log('Saving calendar task with time: display=$time, database=$databaseTime');

          final response = await saveTaskToDatabase(taskMain);
          if (response != null && response['data'] != null) {
            final taskId = response['data']['id'];

            // Update the task with database ID (keep display format)
            final updatedTask = Task(
              id: taskId,
              title: localTask.title,
              category: localTask.category,
              time: time, // Keep 12-hour format for display
              date: localTask.date,
              color: localTask.color,
              icon: localTask.icon,
              isChecked: localTask.isChecked,
            );

            // Replace in provider
            taskProvider.editTask(normalizedSelectedDay, localTask, updatedTask);
            log('Calendar task saved with ID: $taskId');
          }
        } catch (e) {
          log('Failed to save calendar task: $e');
        }

        // Add category if new
        final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

        if (!categoryProvider.categoryExists(formattedCategory)) {
          await categoryProvider.addAndSaveCategory(formattedCategory, userProvider.userId);
        }

        // Show success message using captured messenger
        final formattedDate = formatDateWithOrdinal(normalizedSelectedDay);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("'$title' has been scheduled for $formattedDate"),
          ),
        );
      },
    );
  }
}, ),
    );
  }
}
