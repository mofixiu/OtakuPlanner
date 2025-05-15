import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  TextEditingController _searchController = TextEditingController();
  String _searchTerm = "";

  // Add dispose method to clean up the controller
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Add initState to set up listeners
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
                    horizontal: 8,
                    vertical: 8,
                  ),
                  isDense: true, // Makes the TextField more compact
                ),
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                ), // Smaller text
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Wrap(
              spacing: 0.1, // Horizontal spacing between items
              runSpacing: 4.0, // Vertical spacing between rows
              children:
                  Categories.categories.map((category) {
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
                          vertical: 10,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? buttonColor
                                  : isDarkMode
                                  ? OtakuPlannerTheme.darkCardBackground
                                  : Colors.white,
                          border: Border.all(
                            color: borderColor.withOpacity(0.5),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow:
                              isSelected
                                  ? [OtakuPlannerTheme.getBoxShadow(context)]
                                  : null,
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
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
                          return Card(
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
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                (() {
                                  String dateInfo = "";
                                  bool isRecurring =
                                      task.isRecurring ??
                                      false; // Use ?? to provide a default

                                  if (isRecurring) {
                                    // For recurring tasks, show "Recurring" instead of date
                                    dateInfo = " • Recurring";
                                  } else {
                                    // For normal tasks, show the date
                                    taskProvider.tasks.forEach((
                                      date,
                                      taskList,
                                    ) {
                                      if (taskList.contains(task)) {
                                        dateInfo =
                                            " • ${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
                                      }
                                    });
                                  }

                                  // Return the formatted subtitle
                                  return "${task.category} - ${task.time}$dateInfo";
                                })(),
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
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
