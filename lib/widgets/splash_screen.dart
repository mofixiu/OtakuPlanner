import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otakuplanner/models/taskMain.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/screens/entryScreens/loginPage.dart';
import 'package:otakuplanner/screens/normalMode/dashboard.dart';
import 'package:otakuplanner/themes/theme.dart';
import 'package:splash_view/splash_view.dart';
import 'package:provider/provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/screens/request.dart';
import 'dart:developer';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isInitialized = false;
  bool _shouldNavigateToDashboard = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize UserProvider first
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Check if Hive is already initialized for UserProvider
      if (!userProvider.isInitialized) {
        await userProvider.initHive();
      }

      // Check authentication
      final hasValidAuth = await _checkAuthStatus();
      
      setState(() {
        _shouldNavigateToDashboard = hasValidAuth;
        _isInitialized = true;
      });

      log('Splash initialization complete. Navigate to Dashboard: $hasValidAuth');
    } catch (e) {
      log('Error during splash initialization: $e');
      setState(() {
        _shouldNavigateToDashboard = false;
        _isInitialized = true;
      });
    }
  }

  Future<bool> _checkAuthStatus() async {
    try {
      log('=== SPLASH AUTH CHECK ===');
      
      final token = await getAuthToken();
      final hasToken = token != null && token.isNotEmpty;
      log('Token found: ${hasToken ? "YES" : "NO"}');
      
      if (!hasToken) {
        return false;
      }
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (!userProvider.isInitialized) {
        await userProvider.initHive();
      }
      
      await userProvider.loadUserData();
      final hasValidUserData = userProvider.hasValidUserData;
      
      log('User data validation: $hasValidUserData');
      
      final isAuthenticated = hasToken && hasValidUserData;
      
      // If authenticated, load tasks before navigating to dashboard
      if (isAuthenticated && userProvider.userId != null) {
        log('Loading tasks for authenticated user...');
        await _loadUserTasks(userProvider.userId!);
      }
      
      return isAuthenticated;
    } catch (e) {
      log('Error checking authentication: $e');
      return false;
    }
  }

  Future<void> _loadUserTasks(int userId) async {
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      
      log('Calling getUserTasks for user ID: $userId');
      final response = await getUserTasks(userId);
      
      if (response != null && response['data'] != null) {
        final tasksData = response['data'] as List;
        log('Successfully loaded ${tasksData.length} tasks in splash screen');
        
        if (tasksData.isEmpty) {
          log('No tasks found for user');
          return;
        }
        
        // Convert TaskMain objects to Task objects and organize by date
        for (final taskJson in tasksData) {
          try {
            log('Processing task: $taskJson');
            
            // Fix the task data first
            final taskData = Map<String, dynamic>.from(taskJson);
            if (taskData['completed'] is int) {
              taskData['completed'] = taskData['completed'] == 1;
            }
            
            // Fix date format
            String dateString = taskData['date'] as String;
            if (dateString.endsWith('.')) {
              dateString = dateString.substring(0, dateString.length - 1) + '000Z';
              taskData['date'] = dateString;
            }
            
            final taskMain = TaskMain.fromJson(taskData);
            final task = _convertTaskMainToTask(taskMain);
            
            final taskDate = _parseTaskDate(taskMain.date);
            final normalizedDate = DateTime(taskDate.year, taskDate.month, taskDate.day);
            
            // Add to TaskProvider using the existing method
            taskProvider.addTaskIfNotExists(normalizedDate, task);
            log('Added task: ${task.title} for date: $normalizedDate');
          } catch (e) {
            log('Error converting task: $e');
            log('Failed task data: $taskJson');
          }
        }
        
        log('Task loading completed successfully');
      } else {
        log('No valid response data from getUserTasks');
      }
    } catch (e) {
      log('Error loading tasks in splash: $e');
    }
  }

  // Helper method to convert TaskMain to Task
  Task _convertTaskMainToTask(TaskMain taskMain) {
    return Task(
      id: taskMain.id,
      title: taskMain.title,
      category: taskMain.category,
      time: taskMain.time,
      date: taskMain.date,
      isChecked: taskMain.completed,
      color: Task.getRandomColor(),
      icon: _getCategoryIcon(taskMain.category),
      isRecurring: false,
    );
  }

  // Helper method to get icon for category
  IconData _getCategoryIcon(String category) {
    const categoryIcons = {
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
    
    return categoryIcons[category] ?? FontAwesomeIcons.listCheck;
  }

  // Add this helper method
  DateTime _parseTaskDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      String fixedDate = dateString;
      if (fixedDate.endsWith('.')) {
        fixedDate = fixedDate.substring(0, fixedDate.length - 1) + '.000Z';
      }
      try {
        return DateTime.parse(fixedDate);
      } catch (e2) {
        return DateTime.now();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Show loading splash while initializing
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/otaku.jpg",
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                'Loading your tasks...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Use SplashView with navigation based on auth status
    return SplashView(
      logo: Image.asset("assets/images/otaku.jpg"),
      done: Done(
        _shouldNavigateToDashboard ? const Dashboard() : const Login(),
      ),
      duration: const Duration(milliseconds: 2000),
    );
  }
}

// In your MyApp widget, make sure you're using the splash screen as initial route
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otaku Planner',
      theme: OtakuPlannerTheme.lightTheme,
      navigatorKey: navigatorKey, // Make sure this is set for request service
      home: SplashScreen(), // Start with splash screen
      routes: {
        '/login': (context) => Login(),
        '/dashboard': (context) => Dashboard(),
        // Add other routes as needed
      },
    );
  }
}
