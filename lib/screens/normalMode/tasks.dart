// ignore_for_file: prefer_final_fields, avoid_function_literals_in_foreach_calls, no_leading_underscores_for_local_identifiers

import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/models/taskMain.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/normalMode/profile.dart';
import 'package:otakuplanner/screens/normalMode/task_automation.dart';
import 'package:otakuplanner/shared/notifications.dart';
import 'package:otakuplanner/themes/theme.dart';
import 'package:otakuplanner/widgets/bottomNavBar.dart';
import 'package:otakuplanner/shared/categories.dart';
import 'package:otakuplanner/widgets/rounderCustomButton.dart';
import 'package:provider/provider.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/screens/request.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  TextEditingController _searchController = TextEditingController();
  String _searchTerm = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  // Search changed handler
  void _onSearchChanged() {
    setState(() {
      _searchTerm = _searchController.text.toLowerCase();
    });
  }

  void profile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Profile()),
    );
  }
// Add this method to the _TasksState class
IconData _getCategoryIcon(String category) {
  switch (category) {
    case 'All':
      return Icons.category;
    case 'Work':
      return Icons.work;
    case 'Personal':
      return Icons.person;
    case 'Shopping':
      return Icons.shopping_cart;
    case 'Health':
      return Icons.favorite;
    case 'Education':
      return Icons.school;
    case 'Entertainment':
      return Icons.movie;
    case 'Anime':
      return Icons.tv;
    case 'Manga':
      return Icons.menu_book;
    default:
      return Icons.label;
  }
}
  final int _currentIndex = 2;

  // Track the selected category
  String _selectedCategory = "All";

  void _navigateToTaskAutomation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskAutomation()),
    ).then((wasTaskCreated) {
      // Refresh the task list if tasks were created
      if (wasTaskCreated == true) {
        setState(() {
          // This will refresh the UI to show any new tasks
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final profileImagePath =
        Provider.of<UserProvider>(context).profileImagePath;

    // Get theme-specific colors
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = OtakuPlannerTheme.getCardColor(context);
    final textColor = OtakuPlannerTheme.getTextColor(context);
    final borderColor = OtakuPlannerTheme.getBorderColor(context);
    final buttonColor = OtakuPlannerTheme.getButtonColor(context);

    // Create a list of unique tasks, making sure recurring tasks only appear once
    final List<dynamic> allTasks = [];
    final Set<String> addedRecurringTaskTitles =
        {}; // Track added recurring tasks by title

    taskProvider.tasks.values.forEach((tasksList) {
      for (var task in tasksList) {
        // For recurring tasks, check if we already added one with the same title
        if (task.isRecurring == true) {
          if (!addedRecurringTaskTitles.contains(task.title)) {
            addedRecurringTaskTitles.add(task.title);
            allTasks.add(task);
          }
        } else {
          // For non-recurring tasks, add all instances
          allTasks.add(task);
        }
      }
    });

    // final filteredTasks =
    //     _selectedCategory == "All"
    //         ? allTasks
    //         : allTasks
    //             .where((task) => task.category == _selectedCategory)
    //             .toList();
    final filteredTasks =
        allTasks.where((task) {
          // First apply category filter
          final categoryMatch =
              _selectedCategory == "All" || task.category == _selectedCategory;

          // Then apply search filter if there's a search term
          final searchMatch =
              _searchTerm.isEmpty ||
              task.title.toLowerCase().contains(_searchTerm) ||
              task.category.toLowerCase().contains(_searchTerm) ||
              (task.time != null &&
                  task.time.toLowerCase().contains(_searchTerm));

          // Task passes filter if it matches both category and search criteria
          return categoryMatch && searchMatch;
        }).toList();
    void _showNotificationsDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return NotificationDropdown();
        },
      );
    }

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
            onTap: profile,
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
        padding: const EdgeInsets.only(
          top: 22.0,
          left: 10,
          right: 10,
          bottom: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "My Tasks",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                RounderButton(
                  ontap: () {
                    _navigateToTaskAutomation();
                  },
                  data: "+ Automate Task",
                  textcolor: Colors.white,
                  backgroundcolor: buttonColor,
                  width: 150,
                  height: 40,
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            // Container(
            //   decoration: BoxDecoration(
            //     color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: TextField(
            //     controller: _searchController,
            //     decoration: InputDecoration(
            //       hintText: "Search tasks...",
            //       prefixIcon: Icon(
            //         Icons.search,
            //         color: textColor.withOpacity(0.7),
            //       ),
            //       border: InputBorder.none,
            //       contentPadding: EdgeInsets.symmetric(
            //         horizontal: 16,
            //         vertical: 12,
            //       ),
            //     ),
            //     style: TextStyle(color: textColor),
            //   ),
            // ),
            Container(
              height: 40, // Reduced height
              width: MediaQuery.of(context).size.width * 0.4, // Reduced width
              margin: EdgeInsets.symmetric(horizontal: 10), // Add margin
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(
                  20,
                ), // Increased radius for circular look
                border: Border.all(
                  color: borderColor.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search tasks...",
                  hintStyle: TextStyle(
                    fontSize: 14, // Smaller text
                    color: textColor.withOpacity(0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: textColor.withOpacity(0.7),
                    size: 18, // Smaller icon
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  isDense: true, 
                ),
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                ), 
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Wrap(
  spacing: 0.1, // Horizontal spacing between items
  runSpacing: 4.0, // Vertical spacing between rows
  children: Categories.categories.map((category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        padding: EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? buttonColor
              : isDarkMode
                  ? OtakuPlannerTheme.darkCardBackground
                  : Colors.white,
          border: Border.all(
            color: borderColor.withOpacity(0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(30), // Increased for pill shape
          boxShadow: isSelected ? [OtakuPlannerTheme.getBoxShadow(context)] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Important for proper sizing
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 16,
              color: isSelected ? Colors.white : textColor,
            ),
            SizedBox(width: 6), // Space between icon and text
            Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }).toList(),
),
            // Wrap(
            //   spacing: 0.1, // Horizontal spacing between items
            //   runSpacing: 4.0, // Vertical spacing between rows
            //   children:
            //       Categories.categories.map((category) {
            //         final isSelected = _selectedCategory == category;
            //         return GestureDetector(
            //           onTap: () {
            //             setState(() {
            //               _selectedCategory = category;
            //             });
            //           },
            //           child: Container(
            //             margin: EdgeInsets.symmetric(horizontal: 5),
            //             padding: EdgeInsets.symmetric(
            //               vertical: 10,
            //               horizontal: 15,
            //             ),
            //             decoration: BoxDecoration(
            //               color:
            //                   isSelected
            //                       ? buttonColor
            //                       : isDarkMode
            //                       ? OtakuPlannerTheme.darkCardBackground
            //                       : Colors.white,
            //               border: Border.all(
            //                 color: borderColor.withOpacity(0.5),
            //                 width: 1,
            //               ),
            //               borderRadius: BorderRadius.circular(8),
            //               boxShadow:
            //                   isSelected
            //                       ? [OtakuPlannerTheme.getBoxShadow(context)]
            //                       : null,
            //             ),
            //             child: Text(
            //               category,
            //               style: TextStyle(
            //                 color: isSelected ? Colors.white : textColor,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //           ),
            //         );
            //       }).toList(),
            // ),
            SizedBox(height: 20),
            Expanded(
              child:
                  filteredTasks.isEmpty
                      ? Center(
                        child: Text(
                          "No tasks available for this category.",
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          // Replace the existing Card/ListTile in the ListView.builder

return GestureDetector(
  onTap: () {
    // Show the same task details modal as in calendar
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task title
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Recurring tag - only show if task is recurring
                  if (task.isRecurring == true)
                    Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.blue.shade900
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.repeat,
                            size: 16,
                            color: isDarkMode
                                ? Colors.blue.shade300
                                : Colors.blue,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Recurring (Custom-Weekly)",
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.blue.shade300
                                  : Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Category
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: task.color.withOpacity(0.2),
                          child: Icon(
                            task.icon ?? FontAwesomeIcons.listCheck,
                            color: task.color,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Category",
                              style: TextStyle(
                                color: textColor.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              task.category,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Date - Find the date this task belongs to
                  Builder(
                    builder: (context) {
                      DateTime? taskDate;
                      // Find which date this task belongs to
                      taskProvider.tasks.forEach((date, taskList) {
                        if (taskList.any((t) => t.title == task.title && t.time == task.time)) {
                          taskDate = date;
                        }
                      });

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: (isDarkMode
                                  ? Colors.blue.shade700
                                  : Colors.blue.shade100),
                              child: Icon(
                                Icons.calendar_today,
                                color: isDarkMode
                                    ? Colors.blue.shade300
                                    : Colors.blue,
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Date",
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  taskDate != null
                                      ? DateFormat("EEEE, MMMM d, yyyy").format(taskDate!)
                                      : task.isRecurring == true
                                          ? "Recurring Task"
                                          : "Date not found",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Time
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: (isDarkMode
                              ? Colors.orange.shade700
                              : Colors.orange.shade100),
                          child: Icon(
                            Icons.access_time,
                            color: isDarkMode
                                ? Colors.orange.shade300
                                : Colors.orange,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Time",
                              style: TextStyle(
                                color: textColor.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              task.time,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Completion status with checkbox
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: task.isChecked,
                          activeColor: Colors.green,
                          checkColor: Colors.white,
                          onChanged: (bool? newValue) async {
                            // Find the actual date this task belongs to
                            DateTime? actualTaskDate;
                            taskProvider.tasks.forEach((date, taskList) {
                              for (var t in taskList) {
                                if (t.title == task.title && t.time == task.time) {
                                  actualTaskDate = date;
                                  break;
                                }
                              }
                            });

                            if (actualTaskDate != null) {
                              // Update the task completion
                              final updatedTask = Task(
                                id: task.id,
                                title: task.title,
                                category: task.category,
                                date: task.date,
                                time: task.time,
                                color: task.color,
                                icon: task.icon,
                                isChecked: newValue ?? false,
                                isRecurring: task.isRecurring,
                              );

                              // Update in TaskProvider
                              taskProvider.editTask(actualTaskDate!, task, updatedTask);

                              // Update in database if task has an ID
                              if (task.id != null) {
                                try {
                                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                                  final taskMain = TaskMain(
                                    id: task.id,
                                    title: task.title,
                                    category: task.category,
                                    time: task.time,
                                    date: task.date,
                                    userId: userProvider.userId,
                                    completed: newValue ?? false,
                                  );

                                  await updateTaskInDatabase(taskMain);
                                  log('Task completion status updated in database from tasks page');
                                } catch (e) {
                                  log('Failed to update task completion in database: $e');
                                }
                              }

                              // Close dialog and show notification
                              Navigator.of(dialogContext).pop();
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    newValue == true ? "Task Completed" : "Task Marked as Incomplete",
                                  ),
                                ),
                              );

                              // Rebuild the UI
                              if (mounted) {
                                setState(() {});
                              }
                            }
                          },
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Status",
                              style: TextStyle(
                                color: textColor.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              task.isChecked ? "Completed" : "Not completed",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: task.isChecked ? Colors.green : textColor,
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: Icon(Icons.delete, color: Colors.white),
                    label: Text("Delete", style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      
                      // Find the actual date this task belongs to for deletion
                      DateTime? actualTaskDate;
                      taskProvider.tasks.forEach((date, taskList) {
                        for (var t in taskList) {
                          if (t.title == task.title && t.time == task.time) {
                            actualTaskDate = date;
                            break;
                          }
                        }
                      });

                      if (actualTaskDate != null) {
                        // Show delete confirmation
                        showDialog(
                          context: context,
                          builder: (BuildContext confirmContext) {
                            return AlertDialog(
                              backgroundColor: cardColor,
                              title: Text(
                                'Delete Task',
                                style: TextStyle(color: textColor),
                              ),
                              content: Text(
                                'Are you sure you want to delete "${task.title}"?',
                                style: TextStyle(color: textColor),
                              ),
                              actions: [
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () => Navigator.of(confirmContext).pop(),
                                ),
                                TextButton(
                                  child: Text('Delete'),
                                  onPressed: () async {
                                    Navigator.of(confirmContext).pop();
                                    
                                    // Delete from database if task has ID
                                    if (task.id != null) {
                                      try {
                                        await deleteTaskFromDatabase(task.id!);
                                        log('Task deleted from database');
                                      } catch (e) {
                                        log('Failed to delete task from database: $e');
                                      }
                                    }

                                    // Delete from provider
                                    taskProvider.deleteTask(actualTaskDate!, task);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("'${task.title}' has been deleted"),
                                      ),
                                    );

                                    // Refresh the tasks list
                                    setState(() {});
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
                    icon: Icon(Icons.edit, color: Colors.white),
                    label: Text("Edit", style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      // Edit functionality can be added here later if needed
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Edit functionality - navigate to calendar to edit tasks"),
                        ),
                      );
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
    margin: EdgeInsets.symmetric(vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(
        color: borderColor.withOpacity(0.2),
        width: 0.5,
      ),
    ),
    child: ListTile(
      leading: Icon(
        task.icon ?? Icons.task,
        color: task.color,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                decoration: task.isChecked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (task.isChecked)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: Colors.white, size: 12),
                  SizedBox(width: 2),
                  Text(
                    "Done",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      subtitle: Text(
        (() {
          String dateInfo = "";
          bool isRecurring = task.isRecurring ?? false;

          if (isRecurring) {
            dateInfo = " • Recurring";
          } else {
            taskProvider.tasks.forEach((date, taskList) {
              if (taskList.contains(task)) {
                dateInfo = " • ${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
              }
            });
          }

          return "${task.category} - ${task.time}$dateInfo";
        })(),
        style: TextStyle(
          color: textColor.withOpacity(0.7),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: textColor.withOpacity(0.5),
      ),
    ),
  ),
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
