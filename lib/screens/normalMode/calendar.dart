import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/normalMode/profile.dart';
import 'package:otakuplanner/screens/normalMode/task_dialog2.dart';
import 'package:otakuplanner/shared/categories.dart';
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
    // Ensure we're showing today when first loading
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
    _taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // Force refresh when navigating to this page
    setState(() {
      // This will trigger a rebuild with the latest tasks from TaskProvider
    });
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
                    onSubmit: (title, category, time) {
                      // Time validation for today

                      if (isToday) {
                        // Parse the time string (assuming format like "10:00 AM")
                        final now = DateTime.now();
                        final timeFormat = DateFormat("hh:mm a");
                        try {
                          final taskTime = timeFormat.parse(time);

                          // Create a DateTime with today's date and the task time
                          final taskDateTime = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            taskTime.hour,
                            taskTime.minute,
                          );

                          // Compare with current time
                          if (taskDateTime.isBefore(now)) {
                            NotificationService.showToast(
                              context,
                              "Invalid Time",
                              "Cannot schedule tasks for times that have already passed",
                            );
                            return; // Don't add the task
                          }
                        } catch (e) {
                          // Handle invalid time format
                          NotificationService.showToast(
                            context,
                            "Invalid Format",
                            "Please enter a valid time format",
                          );
                          return;
                        }
                      }

                      // Original task adding logic
                      final formattedCategory =
                          category[0].toUpperCase() +
                          category.substring(1).toLowerCase();
                      final task = Task(
                        title: title,
                        category: formattedCategory,
                        time: time,
                        color: Task.getRandomColor(),
                        icon:
                            categoryIcons[formattedCategory] ??
                            FontAwesomeIcons.listCheck,
                        isChecked: false,
                      );
                      taskProvider.addTask(normalizedSelectedDay, task);
                      if (!Categories.categories.contains(formattedCategory)) {
                        Categories.categories.add(formattedCategory);
                      }

                      // Show notification for task added
                      final formattedDate = formatDateWithOrdinal(
                        normalizedSelectedDay,
                      );
                      NotificationService.showToast(
                        context,
                        "Task Added",
                        "'$title' has been scheduled for $formattedDate",
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
                                                ) {
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
                                                  if (!Categories.categories
                                                      .contains(
                                                        formattedCategory,
                                                      )) {
                                                    Categories.categories.add(
                                                      formattedCategory,
                                                    );
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
                                                onSubmit: (
                                                  title,
                                                  category,
                                                  time,
                                                ) {
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
                                                    color:
                                                        task.color, // Keep the same color
                                                    icon:
                                                        categoryIcons[formattedCategory] ??
                                                        FontAwesomeIcons
                                                            .listCheck,
                                                    isChecked: task.isChecked,
                                                    isRecurring:
                                                        true, // Keep it recurring
                                                  );

                                                  // Update all recurring instances
                                                  taskProvider
                                                      .editRecurringTask(
                                                        task,
                                                        updatedTask,
                                                      );

                                                  // Add the category if needed
                                                  if (!Categories.categories
                                                      .contains(
                                                        formattedCategory,
                                                      )) {
                                                    Categories.categories.add(
                                                      formattedCategory,
                                                    );
                                                  }

                                                  NotificationService.showToast(
                                                    context,
                                                    "Recurring Tasks Updated",
                                                    "All instances of '$originalTitle' have been updated",
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
                                    onSubmit: (title, category, time) {
                                      final formattedCategory =
                                          category[0].toUpperCase() +
                                          category.substring(1).toLowerCase();
                                      final updatedTask = Task(
                                        title: title,
                                        category: formattedCategory,
                                        time: time,
                                        color:
                                            task.color, // Keep the same color
                                        icon:
                                            categoryIcons[formattedCategory] ??
                                            FontAwesomeIcons.listCheck,
                                        isChecked: task.isChecked,
                                        isRecurring:
                                            task.isRecurring, // Maintain recurring status
                                      );
                                      taskProvider.editTask(
                                        normalizedSelectedDay,
                                        task,
                                        updatedTask,
                                      );

                                      // Add the category if it doesn't exist
                                      if (!Categories.categories.contains(
                                        formattedCategory,
                                      )) {
                                        Categories.categories.add(
                                          formattedCategory,
                                        );
                                      }

                                      // Show notification for task update
                                      NotificationService.showToast(
                                        context,
                                        "Task Updated",
                                        "'$originalTitle' scheduled for $formattedDate has been updated",
                                      );
                                    },
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
                    final Color dotColor = tasksForDay.isNotEmpty 
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
                                return Card(
                                  color: cardColor,
                                  elevation: 1,
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: Icon(
                                      task.icon ?? FontAwesomeIcons.listCheck,
                                      color: task.color,
                                    ),
                                    title: Text(
                                      task.title,
                                      style: TextStyle(color: textColor),
                                    ),
                                    subtitle: Text(
                                      "${task.category} - ${task.time}",
                                      style: TextStyle(
                                        color: textColor.withOpacity(0.7),
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color:
                                                isDarkMode
                                                    ? Colors.lightBlue
                                                    : Colors.blue,
                                          ),
                                          onPressed: () {
                                            if (task.isRecurring &&
                                                taskProvider
                                                    .isRecurringTaskOnMultipleDates(
                                                      task,
                                                    )) {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      'Edit Recurring Task',
                                                    ),
                                                    content: Text(
                                                      'This is a recurring task. Do you want to edit all instances?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        child: Text(
                                                          'This Instance Only',
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          // Edit just this instance logic
                                                          // Same as above
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text(
                                                          'All Instances',
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          // Edit all instances logic
                                                          // Same as above
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            } else {
                                              // Edit single task
                                              // Same as above
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            if (task.isRecurring &&
                                                taskProvider
                                                    .isRecurringTaskOnMultipleDates(
                                                      task,
                                                    )) {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      'Delete Recurring Task',
                                                    ),
                                                    content: Text(
                                                      'This is a recurring task. Do you want to delete all instances?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        child: Text(
                                                          'This Instance Only',
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
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
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          taskProvider
                                                              .deleteRecurringTask(
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
                                              // Delete single task
                                              taskProvider.deleteTask(
                                                normalizedSelectedDay,
                                                task,
                                              );
                                              NotificationService.showToast(
                                                context,
                                                "Task Deleted",
                                                "'${task.title}' has been deleted",
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
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

        onPressed: () {
          if (_selectedDay != null) {
            final taskProvider = Provider.of<TaskProvider>(
              context,
              listen: false,
            );
            final normalizedSelectedDay = _normalizeDate(_selectedDay!);

            // Check if selected day is today
            final bool isToday = DateTime(
              normalizedSelectedDay.year,
              normalizedSelectedDay.month,
              normalizedSelectedDay.day,
            ).isAtSameMomentAs(
              DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              ),
            );

            showTaskDialog(
              context: context,
              dialogTitle:
                  "Add Task for ${formatDateWithOrdinal(_selectedDay!)}",
              onSubmit: (title, category, time) {
                // Time validation for today
                if (isToday) {
                  // Parse the time string (assuming format like "10:00 AM")
                  final now = DateTime.now();
                  final timeFormat = DateFormat("hh:mm a");
                  try {
                    final taskTime = timeFormat.parse(time);

                    // Create a DateTime with today's date and the task time
                    final taskDateTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      taskTime.hour,
                      taskTime.minute,
                    );

                    // Compare with current time
                    if (taskDateTime.isBefore(now)) {
                      NotificationService.showToast(
                        context,
                        "Invalid Time",
                        "Cannot schedule tasks for times that have already passed",
                      );
                      return; // Don't add the task
                    }
                  } catch (e) {
                    // Handle invalid time format
                    NotificationService.showToast(
                      context,
                      "Invalid Format",
                      "Please enter a valid time format",
                    );
                    return;
                  }
                }

                // Original task adding logic
                final formattedCategory =
                    category[0].toUpperCase() +
                    category.substring(1).toLowerCase();
                final task = Task(
                  title: title,
                  category: formattedCategory,
                  time: time,
                  color: Task.getRandomColor(),
                  icon:
                      categoryIcons[formattedCategory] ??
                      FontAwesomeIcons.listCheck,
                  isChecked: false,
                );
                taskProvider.addTask(
                  normalizedSelectedDay,
                  task,
                ); // Use the captured provider

                if (!Categories.categories.contains(formattedCategory)) {
                  Categories.categories.add(formattedCategory);
                }

                // Show notification for task added
                final formattedDate = formatDateWithOrdinal(_selectedDay!);
                NotificationService.showToast(
                  context,
                  "Task Added",
                  "'$title' has been scheduled for $formattedDate",
                );
              },
            );
          }
        },
      ),
    );
  }
}
