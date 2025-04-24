import 'dart:io';

import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/normalMode/calendar.dart';
import 'package:otakuplanner/screens/normalMode/profile.dart';
import 'package:otakuplanner/screens/normalMode/task_dialog2.dart'; // Use the updated dialog
import 'package:otakuplanner/shared/in_app_reminder_service.dart';
import 'package:otakuplanner/shared/notifications.dart';
import 'package:otakuplanner/shared/quote_service.dart';
import 'package:otakuplanner/themes/theme.dart';
import 'package:otakuplanner/widgets/bottomNavBar.dart';
import 'package:otakuplanner/widgets/customButton.dart';
import 'package:otakuplanner/widgets/task_card.dart';
import 'package:provider/provider.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:otakuplanner/models/task.dart' as model;
// import 'package:otakuplanner/shared/categories.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback? resumeCallBack;

  LifecycleEventHandler({this.resumeCallBack});

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && resumeCallBack != null) {
      await resumeCallBack!();
    }
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class Task {
  String title;
  String category;
  String time;
  IconData icon;
  bool isChecked;

  Task({
    required this.title,
    required this.category,
    required this.time,
    required this.icon,
    this.isChecked = false,
  });
}

// Convert dashboard Task to model Task
model.Task convertToModelTask(Task dashboardTask) {
  return model.Task(
    title: dashboardTask.title,
    category: dashboardTask.category,
    time: dashboardTask.time,
    color: Colors.blue, // Default color, will be overridden later
    icon: dashboardTask.icon,
    isChecked: dashboardTask.isChecked,
  );
}

// Convert model Task to dashboard Task
Task convertToDashboardTask(model.Task modelTask) {
  return Task(
    title: modelTask.title,
    category: modelTask.category,
    time: modelTask.time,
    icon: modelTask.icon ?? FontAwesomeIcons.tasks,
    isChecked: modelTask.isChecked,
  );
}

class _DashboardState extends State<Dashboard> {
  final int _currentIndex = 0;
  bool checked1 = false;
  bool checked2 = false;
  bool checked3 = false;
  List<Task> tasks = [];
  Quote? _quote;
  bool _isLoadingQuote = true;

  LifecycleEventHandler? _lifecycleHandler;

  @override
  void initState() {
    super.initState();
    
    // Initialize in-app reminder service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      InAppReminderService.initialize(context, taskProvider);
    });
    
    _loadQuote();

    // Create a single instance of the handler
    final lifecycleHandler = LifecycleEventHandler(
      resumeCallBack: () async {
        if (mounted) {
          _syncTasksWithProvider();
        }
        return Future.value();
      },
    );

    // Store the handler instance for later removal
    _lifecycleHandler = lifecycleHandler;

    // Add the observer
    WidgetsBinding.instance.addObserver(lifecycleHandler);

    // Initial sync with provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncTasksWithProvider();
    });
  }

  @override
  void dispose() {
    // Dispose of reminder service
    InAppReminderService.dispose();
    
    // Remove the observer using the stored instance
    if (_lifecycleHandler != null) {
      WidgetsBinding.instance.removeObserver(_lifecycleHandler!);
    }
    super.dispose();
  }

  Future<void> _loadQuote() async {
    if (mounted) {
      setState(() {
        // Get a quote immediately from the cache or fallback
        _quote = QuoteService.getQuote();
        _isLoadingQuote = false;
      });
    }
  }

  // Update the _syncTasksWithProvider method to ensure better synchronization

  void _syncTasksWithProvider() {
    if (!mounted) return;

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    // Get tasks from provider first and update local list
    final providerTasks = taskProvider.tasks[today] ?? [];

    // Clear existing local tasks and rebuild from provider
    setState(() {
      tasks.clear();
      for (var providerTask in providerTasks) {
        tasks.add(
          Task(
            title: providerTask.title,
            category: providerTask.category,
            time: providerTask.time,
            icon: providerTask.icon ?? FontAwesomeIcons.tasks,
            isChecked: providerTask.isChecked,
          ),
        );
      }
    });
  }

  void _showAddTaskDialog() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    showTaskDialog(
      context: context,
      dialogTitle: "New Task",
      onSubmit: (title, category, time) {
        // Create the dashboard task
        final dashboardTask = Task(
          title: title,
          category: category,
          time: time,
          icon: FontAwesomeIcons.tasks,
        );

        // Add to local tasks list for dashboard
        setState(() {
          tasks.add(dashboardTask);
        });

        // Convert and add to TaskProvider for calendar/tasks page
        final modelTask = model.Task(
          title: title,
          category: category,
          time: time,
          color: model.Task.getRandomColor(),
          icon: categoryIcons[category] ?? FontAwesomeIcons.tasks,
          isChecked: false,
        );

        // Add to provider
        taskProvider.addTask(today, modelTask);

        // Show notification
        NotificationService.showToast(
          context,
          "Task Added",
          "'$title' has been added to your tasks",
        );
      },
    );
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NotificationDropdown();
      },
    );
  }

  void profile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Profile()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<UserProvider>(context).username;
    final profileImagePath =
        Provider.of<UserProvider>(context).profileImagePath;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // final primaryColor = Theme.of(context).primaryColor;
    final cardColor = OtakuPlannerTheme.getCardColor(context);
    final textColor = OtakuPlannerTheme.getTextColor(context);
    final borderColor = OtakuPlannerTheme.getBorderColor(context);
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 15, right: 15),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height *
                      0.1, // Optional: set minimum height
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border(
                    left: BorderSide(color: borderColor, width: 0.4),
                    right: BorderSide(color: borderColor, width: 0.4),
                  ),
                  boxShadow: [OtakuPlannerTheme.getBoxShadow(context)],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'Welcome back, ${username[0].toUpperCase()}${username.substring(1).toLowerCase()}!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Center(
                            child: Text(
                              _quote?.text ?? "Let's make today productive!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          if (_quote?.author != null &&
                              _quote!.author.isNotEmpty)
                            Center(
                              child: Text(
                                "- ${_quote!.author}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                child: Row(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.16,
                      width: MediaQuery.of(context).size.width / 2,
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border(
                          left: BorderSide(color: borderColor, width: 0.4),
                          right: BorderSide(color: borderColor, width: 0.4),
                        ),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [OtakuPlannerTheme.getBoxShadow(context)],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Today's\nTasks",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Icon(
                                  Icons.note_alt_outlined,
                                  color:
                                      isDarkMode
                                          ? Colors.lightBlue
                                          : Colors.blue,
                                ),
                              ],
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005,
                            ),
                            Text(
                              "${tasks.length}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005,
                            ),
                            Text(
                              "${tasks.where((task) => task.isChecked).length} completed",
                              style: TextStyle(fontSize: 15, color: textColor),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.013,
                            ),
                            StepProgressIndicator(
                              totalSteps: 100,
                              currentStep:
                                  tasks.isEmpty
                                      ? 0
                                      : (tasks
                                              .where((task) => task.isChecked)
                                              .length *
                                          100 ~/
                                          tasks.length),
                              size: 8,
                              padding: 0,
                              roundedEdges: Radius.circular(10),
                              selectedGradientColor: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  isDarkMode ? Colors.lightBlue : Colors.blue,
                                  isDarkMode ? Colors.lightBlue : Colors.blue,
                                ],
                              ),
                              unselectedGradientColor: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                                  isDarkMode
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade300,
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.16,
                      width: MediaQuery.of(context).size.width / 2,
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border(
                          left: BorderSide(color: borderColor, width: 0.4),
                          right: BorderSide(color: borderColor, width: 0.4),
                        ),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [OtakuPlannerTheme.getBoxShadow(context)],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Current\nStreak",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                FaIcon(
                                  FontAwesomeIcons.clock,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005,
                            ),
                            Text(
                              "7 days",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.005,
                            ),
                            Text(
                              "1 completed",
                              style: TextStyle(fontSize: 15, color: textColor),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.013,
                            ),
                            StepProgressIndicator(
                              totalSteps: 100,
                              currentStep: 74,
                              size: 8,
                              padding: 0,
                              roundedEdges: Radius.circular(10),
                              selectedGradientColor: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.green, Colors.green],
                              ),
                              unselectedGradientColor: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                                  isDarkMode
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade300,
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.165,
                      width: MediaQuery.of(context).size.width / 2,
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border(
                          left: BorderSide(color: borderColor, width: 0.4),
                          right: BorderSide(color: borderColor, width: 0.4),
                        ),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [OtakuPlannerTheme.getBoxShadow(context)],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Achievements",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                FaIcon(
                                  FontAwesomeIcons.trophy,
                                  color: Colors.yellow,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            Text(
                              "3",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.007,
                            ),
                            Text(
                              "6 more to unlock",
                              style: TextStyle(fontSize: 15, color: textColor),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.013,
                            ),
                            StepProgressIndicator(
                              totalSteps: 100,
                              currentStep: 74,
                              size: 8,
                              padding: 0,
                              roundedEdges: Radius.circular(10),
                              selectedGradientColor: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.yellow, Colors.yellow],
                              ),
                              unselectedGradientColor: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                                  isDarkMode
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade300,
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's tasks",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  CustomButton(
                    ontap: _showAddTaskDialog,
                    data: "+",
                    textcolor: Colors.white,
                    backgroundcolor: buttonColor,
                    width: 40,
                    height: 30,
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              tasks.isEmpty
                  ? Center(
                    child: Text(
                      "No tasks available",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  )
                  : Column(
                    children:
                        tasks.asMap().entries.map((entry) {
                          int index = entry.key;
                          Task task = entry.value;
                          return TaskCard(
                            title: task.title,
                            category: task.category,
                            time: task.time,
                            icon: task.icon,
                            isChecked: task.isChecked,
                            backgroundColor: cardColor,
                            textColor: textColor,
                            borderColor: borderColor,
                            onChanged: (val) {
                              final taskProvider = Provider.of<TaskProvider>(
                                context,
                                listen: false,
                              );
                              final today = DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                              );

                              setState(() {
                                task.isChecked = val ?? false;

                                // Find and update the task in TaskProvider
                                final tasks = taskProvider.tasks[today] ?? [];
                                for (int i = 0; i < tasks.length; i++) {
                                  if (tasks[i].title == task.title &&
                                      tasks[i].time == task.time) {
                                    // Create updated model task
                                    final updatedModelTask = model.Task(
                                      title: task.title,
                                      category: task.category,
                                      time: task.time,
                                      color:
                                          tasks[i].color, // Keep existing color
                                      icon: tasks[i].icon, // Keep existing icon
                                      isChecked: val ?? false,
                                    );

                                    // Update in provider
                                    taskProvider.editTask(
                                      today,
                                      tasks[i],
                                      updatedModelTask,
                                    );
                                    break;
                                  }
                                }

                                if (task.isChecked) {
                                  NotificationService.showToast(
                                    context,
                                    "Task Completed",
                                    "You've completed '${task.title}'",
                                  );
                                }
                              });
                            },
                            onEdit: () {
                              final taskProvider = Provider.of<TaskProvider>(
                                context,
                                listen: false,
                              );
                              final today = DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                              );

                              showTaskDialog(
                                context: context,
                                dialogTitle: "Edit Task",
                                initialTitle: task.title,
                                initialCategory: task.category,
                                initialTime: task.time,
                                onSubmit: (title, category, time) {
                                  // Store original title for notification
                                  String oldTitle = task.title;

                                  // Update local task
                                  setState(() {
                                    task.title = title;
                                    task.category = category;
                                    task.time = time;
                                  });

                                  // Find and update the task in TaskProvider
                                  final tasks = taskProvider.tasks[today] ?? [];
                                  for (int i = 0; i < tasks.length; i++) {
                                    if (tasks[i].title == oldTitle) {
                                      // Create updated model task
                                      final updatedModelTask = model.Task(
                                        title: title,
                                        category: category,
                                        time: time,
                                        color:
                                            tasks[i]
                                                .color, // Keep existing color
                                        icon:
                                            categoryIcons[category] ??
                                            tasks[i]
                                                .icon, // Update icon based on category
                                        isChecked: task.isChecked,
                                      );

                                      // Update in provider
                                      taskProvider.editTask(
                                        today,
                                        tasks[i],
                                        updatedModelTask,
                                      );
                                      break;
                                    }
                                  }

                                  NotificationService.showToast(
                                    context,
                                    "Task Updated",
                                    "'$oldTitle' has been updated",
                                  );
                                },
                              );
                            },
                            onDelete: () {
                              final taskProvider = Provider.of<TaskProvider>(
                                context,
                                listen: false,
                              );
                              final today = DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                              );

                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Delete Task"),
                                    content: Text(
                                      "Are you sure you want to delete ${task.title}?",
                                      style: TextStyle(color: textColor),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(color: textColor),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          String deletedTaskTitle = task.title;

                                          // Remove from local tasks list
                                          setState(() {
                                            tasks.removeAt(index);
                                          });

                                          // Remove from TaskProvider
                                          final providerTasks =
                                              taskProvider.tasks[today] ?? [];
                                          for (var providerTask
                                              in providerTasks) {
                                            if (providerTask.title ==
                                                deletedTaskTitle) {
                                              taskProvider.deleteTask(
                                                today,
                                                providerTask,
                                              );
                                              break;
                                            }
                                          }

                                          Navigator.of(context).pop();
                                          NotificationService.showToast(
                                            context,
                                            "Task Deleted",
                                            "'$deletedTaskTitle' has been removed",
                                          );
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
                            },
                          );
                        }).toList(),
                  ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}
