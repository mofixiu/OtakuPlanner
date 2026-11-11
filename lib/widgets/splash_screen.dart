import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/models/taskMain.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/entryScreens/loginPage.dart';
import 'package:otakuplanner/screens/normalMode/dashboard.dart';
import 'package:otakuplanner/screens/request.dart';
import 'package:otakuplanner/shared/category_icons.dart';
import 'package:otakuplanner/widgets/ink_kit.dart';
import 'package:provider/provider.dart';

/// Shown while the saved login is checked and tasks are loaded, then hands
/// over to the dashboard (logged in) or the log in screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    var toDashboard = false;
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (!userProvider.isInitialized) {
        await userProvider.initHive();
      }
      toDashboard = await _checkAuthStatus();
      log('Splash initialization complete. Navigate to Dashboard: $toDashboard');
    } catch (e) {
      log('Error during splash initialization: $e');
      toDashboard = false;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => toDashboard ? const Dashboard() : const Login(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  Future<bool> _checkAuthStatus() async {
    try {
      final token = await getAuthToken();
      final hasToken = token != null && token.isNotEmpty;
      log('Token found: ${hasToken ? "YES" : "NO"}');

      if (!hasToken || !mounted) {
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
      if (isAuthenticated) {
        await _loadUserTasks(userProvider.userId);
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

      final response = await getUserTasks(userId);

      if (response != null && response['data'] != null) {
        final tasksData = response['data'] as List;
        log('Successfully loaded ${tasksData.length} tasks in splash screen');

        for (final taskJson in tasksData) {
          try {
            final taskData = Map<String, dynamic>.from(taskJson);
            if (taskData['completed'] is int) {
              taskData['completed'] = taskData['completed'] == 1;
            }

            // Fix date format
            String dateString = taskData['date'] as String;
            if (dateString.endsWith('.')) {
              dateString = '${dateString.substring(0, dateString.length - 1)}000Z';
              taskData['date'] = dateString;
            }

            final taskMain = TaskMain.fromJson(taskData);
            final task = _convertTaskMainToTask(taskMain);

            final taskDate = _parseTaskDate(taskMain.date);
            final normalizedDate = DateTime(taskDate.year, taskDate.month, taskDate.day);

            taskProvider.addTaskIfNotExists(normalizedDate, task);
          } catch (e) {
            log('Error converting task: $e');
            log('Failed task data: $taskJson');
          }
        }
      } else {
        log('No valid response data from getUserTasks');
      }
    } catch (e) {
      log('Error loading tasks in splash: $e');
    }
  }

  Task _convertTaskMainToTask(TaskMain taskMain) {
    return Task(
      id: taskMain.id,
      title: taskMain.title,
      category: taskMain.category,
      time: taskMain.time,
      date: taskMain.date,
      isChecked: taskMain.completed,
      color: Task.getRandomColor(),
      icon: categoryIconFor(taskMain.category),
      isRecurring: false,
    );
  }

  DateTime _parseTaskDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      String fixedDate = dateString;
      if (fixedDate.endsWith('.')) {
        fixedDate = '${fixedDate.substring(0, fixedDate.length - 1)}.000Z';
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LogoMark(height: 96),
            const SizedBox(height: Space.l),
            const SizedBox(
              width: 120,
              child: LinearProgressIndicator(minHeight: 3),
            ),
            const SizedBox(height: Space.m),
            Text(
              'Loading your tasks…',
              style: context.type.bodyMedium?.copyWith(color: context.ink.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
