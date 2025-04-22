import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/profile.dart';
import 'package:otakuplanner/shared/notifications.dart';
import 'package:otakuplanner/themes/theme.dart'; // Add theme import
import 'package:otakuplanner/widgets/bottomNavBar.dart';
import 'package:otakuplanner/widgets/customButtonSmallerTextSize.dart';
import 'package:otakuplanner/shared/categories.dart';
import 'package:provider/provider.dart';
import 'package:otakuplanner/providers/task_provider.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  void profile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Profile()),
    );
  }

  final int _currentIndex = 2;

  // Track the selected category
  String _selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final profileImagePath = Provider.of<UserProvider>(context).profileImagePath;
    
    // Get theme-specific colors
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = OtakuPlannerTheme.getCardColor(context);
    final textColor = OtakuPlannerTheme.getTextColor(context);
    final borderColor = OtakuPlannerTheme.getBorderColor(context);
    final buttonColor = OtakuPlannerTheme.getButtonColor(context);

    final allTasks = taskProvider.tasks.values.expand((tasks) => tasks).toList();

    final filteredTasks =
        _selectedCategory == "All"
            ? allTasks
            : allTasks
                .where((task) => task.category == _selectedCategory)
                .toList();
    
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
                backgroundImage: profileImagePath.isNotEmpty
                    ? FileImage(File(profileImagePath))
                    : null,
                child: profileImagePath.isEmpty
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
                CustomButton(
                  ontap: () {},
                  data: "+ Automate Task",
                  textcolor: Colors.white,
                  backgroundcolor: buttonColor,
                  width: 150,
                  height: 40,
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Wrap(
              spacing: 8.0, // Horizontal spacing between items
              runSpacing: 8.0, // Vertical spacing between rows
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
                          color: isSelected 
                              ? buttonColor 
                              : isDarkMode 
                                  ? OtakuPlannerTheme.darkCardBackground 
                                  : Colors.white,
                          border: Border.all(
                            color: borderColor.withOpacity(0.5),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isSelected 
                              ? [OtakuPlannerTheme.getBoxShadow(context)] 
                              : null,
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected 
                                ? Colors.white 
                                : textColor,
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
                                "${task.category} - ${task.time}",
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
