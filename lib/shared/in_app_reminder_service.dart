import 'dart:async';
import 'package:flutter/material.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/shared/notifications.dart';
import 'package:intl/intl.dart';

class InAppReminderService {
  static Timer? _timer;
  static bool _isInitialized = false;
  static BuildContext? _context;
  static TaskProvider? _taskProvider;
  
  // Keep track of notifications we've already shown to avoid duplicates
  static final Set<String> _notifiedTasks = {};

  // Initialize the reminder service
  static void initialize(BuildContext context, TaskProvider taskProvider) {
    if (_isInitialized) return;
    
    _context = context;
    _taskProvider = taskProvider;
    _isInitialized = true;
    
    // Start checking for upcoming tasks every minute
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _checkUpcomingTasks();
    });
    
    // Also check immediately
    _checkUpcomingTasks();
  }
  
  static void dispose() {
    _timer?.cancel();
    _timer = null;
    _isInitialized = false;
  }
  
  // Check for tasks that are due soon or now
  static void _checkUpcomingTasks() {
    if (_taskProvider == null) return;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final DateFormat timeFormat = DateFormat("hh:mm a");
    
    // Get today's tasks
    final todaysTasks = _taskProvider!.tasks[today] ?? [];
    
    for (var task in todaysTasks) {
      if (task.isChecked) continue; // Skip completed tasks
      
      try {
        // Parse the time string
        final parsedTime = timeFormat.parse(task.time);
        
        // Combine with today's date
        final taskDateTime = DateTime(
          today.year, today.month, today.day,
          parsedTime.hour, parsedTime.minute
        );
        
        // Calculate time until this task
        final difference = taskDateTime.difference(now);
        
        // Create unique ID for this notification
        final String notificationId = '${task.title}_${task.time}';
        
        // Check if task is starting now (within last minute)
        if (difference.inMinutes <= 0 && difference.inMinutes > -1 && 
            !_notifiedTasks.contains('${notificationId}_due')) {
          
          // Task is due now - show notification
          _showTaskNotification(
            title: 'Task Due Now',
            message: '${task.title} is starting now',
            task: task
          );
          _notifiedTasks.add('${notificationId}_due');
        }
        
        // Check if task is starting in 5 minutes
        else if (difference.inMinutes > 4 && difference.inMinutes <= 5 && 
                !_notifiedTasks.contains('${notificationId}_reminder')) {
          
          // Task is due in 5 minutes - show notification
          _showTaskNotification(
            title: 'Task Reminder',
            message: '${task.title} starts in 5 minutes',
            task: task
          );
          _notifiedTasks.add('${notificationId}_reminder');
        }
      } catch (e) {
        // Handle time parsing errors silently
      }
    }
    
    // Clean up notifications older than today
    _cleanupOldNotifications(today);
  }
  
  // Show a notification for a task
  static void _showTaskNotification({
    required String title,
    required String message,
    required Task task,
  }) {
    // Use the existing NotificationService to show the toast
    NotificationService.showToast(_context, title, message);
    
    // Also add to the notification dropdown
    NotificationService.addGlobalNotification(_context, title, message);
  }
  
  // Clean up old notification tracking to prevent memory leaks
  static void _cleanupOldNotifications(DateTime today) {
    // We'll clear notifications older than the current day
    // by recreating the set with only today's notifications
    final Set<String> todaysNotifications = {};
    
    for (String notification in _notifiedTasks) {
      if (notification.contains(today.day.toString())) {
        todaysNotifications.add(notification);
      }
    }
    
    _notifiedTasks.clear();
    _notifiedTasks.addAll(todaysNotifications);
  }
}