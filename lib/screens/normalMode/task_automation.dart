import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/models/taskMain.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/request.dart';
import 'package:otakuplanner/shared/notifications.dart';
import 'package:otakuplanner/themes/theme.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otakuplanner/providers/category_provider.dart';

class TaskAutomation extends StatefulWidget {
  const TaskAutomation({Key? key}) : super(key: key);

  @override
  State<TaskAutomation> createState() => _TaskAutomationState();
}

class _TaskAutomationState extends State<TaskAutomation> {
  final TextEditingController _taskController = TextEditingController();
  String _parsingResult = '';
  Map<String, dynamic> _extractedData = {};
  bool _isProcessing = false;
  String _selectedCategory = 'General';

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  // Process the text input with basic NLP
  void _processTaskText() {
    setState(() {
      _isProcessing = true;
      _parsingResult = '';
      _extractedData = {};
    });

    final text = _taskController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _parsingResult = 'Please enter a task description';
        _isProcessing = false;
      });
      return;
    }

    // Simulate NLP processing with a delay
    Future.delayed(Duration(milliseconds: 800), () {
      final result = _parseTaskText(text);
      
      // Check if time is specified before proceeding
      if (result['time'] == null || result['time'].isEmpty) {
        setState(() {
          _isProcessing = false;
          // Only set error message but keep _extractedData empty to prevent showing results
          _parsingResult = 'Missing time information. Please include a time in your task description (e.g., 3 PM, 7:30 AM)';
          _extractedData = {}; // Ensure data is empty
        });
        
        // Also show toast notification for extra visibility
        // NotificationService.showToast(
        //   context,
        //   "Missing Information",
        //   "Please include a time in your task description (e.g., 3 PM, 7:30 AM)",
        // );
        return;
      }
      
      setState(() {
        _extractedData = result;
        _selectedCategory = result['category']; // Set the initial category
        _parsingResult = _formatParsingResult(result);
        _isProcessing = false;
      });
    });
  }

  // Basic NLP to extract task information
  Map<String, dynamic> _parseTaskText(String text) {
    final lowerText = text.toLowerCase();
    Map<String, dynamic> result = {
      'title': '',
      'day': '',
      'time': '',
      'isRecurring': false,
      'category': 'General',
      "specificDate": null,
    };
    if (lowerText.contains('tomorrow')) {
      // Calculate tomorrow's date
      final tomorrow = DateTime.now().add(Duration(days: 1));
      result['specificDate'] = tomorrow;
      // Also set the day name for display purposes
      result['day'] = _getDayName(tomorrow.weekday);
    } else if (lowerText.contains('today')) {
      // Handle "today" references
      result['specificDate'] = DateTime.now();
      result['day'] = _getDayName(DateTime.now().weekday);
    }

    // Extract day of week
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    for (var day in days) {
      if (lowerText.contains(day)) {
        result['day'] = day[0].toUpperCase() + day.substring(1);
        break;
      }
    }

    // Extract time
    final timeRegex = RegExp(r'(\d{1,2})[:.]?(\d{2})?\s*(am|pm|AM|PM)');
    final timeMatch = timeRegex.firstMatch(text);
    if (timeMatch != null) {
      final hour = timeMatch.group(1);
      final minute = timeMatch.group(2) ?? '00';
      final ampm = timeMatch.group(3)?.toUpperCase() ?? '';
      result['time'] = '$hour:$minute $ampm';
    } else {
      // Try alternate format (like 5.30pm or just 5pm)
      final altTimeRegex = RegExp(r'(\d{1,2})(?:\s*(am|pm|AM|PM))');
      final altTimeMatch = altTimeRegex.firstMatch(text);
      if (altTimeMatch != null) {
        final hour = altTimeMatch.group(1);
        final ampm = altTimeMatch.group(2)?.toUpperCase() ?? '';
        result['time'] = '$hour:00 $ampm';
      }
    }

    result['isRecurring'] =
        lowerText.contains('every') || lowerText.contains('weekly');

    final categories = [
      'Anime',
      'Manga',
      'Gaming',
      'Study',
      'Work',
      'Personal',
    ];
    for (var category in categories) {
      if (lowerText.contains(category.toLowerCase())) {
        result['category'] = category;
        break;
      }
    }

    // Extract title (everything before "every" or day of week)
    String title = text;
    if (lowerText.contains('every')) {
      title = text.substring(0, lowerText.indexOf('every')).trim();
    } else {
      for (var day in days) {
        if (lowerText.contains(day)) {
          title =
              text
                  .substring(0, lowerText.indexOf(day, lowerText.indexOf(day)))
                  .trim();
          break;
        }
      }
    }
    result['title'] = title;

    return result;
  }

  String _getDayName(int weekday) {
    const Map<int, String> dayNames = {
      DateTime.monday: 'Monday',
      DateTime.tuesday: 'Tuesday',
      DateTime.wednesday: 'Wednesday',
      DateTime.thursday: 'Thursday',
      DateTime.friday: 'Friday',
      DateTime.saturday: 'Saturday',
      DateTime.sunday: 'Sunday',
    };
    return dayNames[weekday] ?? '';
  }
  String _formatParsingResult(Map<String, dynamic> data) {
  // Add null checks before using isEmpty
  if ((data['title'] == null || data['title'].isEmpty) && 
      (data['day'] == null || data['day'].isEmpty) && 
      (data['time'] == null || data['time'].isEmpty)) {
    return 'Could not understand the task. Please try again with a clearer description.';
  }

  final List<String> parts = [];

  if (data['title'] != null && data['title'].isNotEmpty) {
    parts.add('Task: ${data['title']}');
  }

  if (data['day'] != null && data['day'].isNotEmpty) {
    parts.add('Day: ${data['day']}');
  }

  if (data['time'] != null && data['time'].isNotEmpty) {
    parts.add('Time: ${data['time']}');
  }

  parts.add('Category: ${data['category'] ?? 'General'}');
  parts.add('Recurring: ${data['isRecurring'] == true ? 'Yes' : 'No'}');

  return parts.join('\n');
}

// Format the parsing result without category for display
String _formatParsingResultWithoutCategory(Map<String, dynamic> data) {
  // Add null checks before using isEmpty
  if ((data['title'] == null || data['title'].isEmpty) && 
      (data['day'] == null || data['day'].isEmpty) && 
      (data['time'] == null || data['time'].isEmpty)) {
    return 'Could not understand the task. Please try again with a clearer description.';
  }

  final List<String> parts = [];

  if (data['title'] != null && data['title'].isNotEmpty) {
    parts.add('Task: ${data['title']}');
  }

  if (data['day'] != null && data['day'].isNotEmpty) {
    parts.add('Day: ${data['day']}');
  }

  if (data['time'] != null && data['time'].isNotEmpty) {
    parts.add('Time: ${data['time']}');
  }

  // Include recurring information but exclude category
  parts.add('Recurring: ${data['isRecurring'] == true ? 'Yes' : 'No'}');

  return parts.join('\n');
}

  // Create the task and add it to calendar
  void _createAutomatedTask() {
    if (_extractedData.isEmpty || _extractedData['title'].isEmpty) {
      NotificationService.showToast(
        context,
        "Processing Error",
        "Please process a valid task description first",
      );
      return;
    }
    
    if (_extractedData['time'] == null || _extractedData['time'].isEmpty) {
      return;
    }
    
    final String taskTitle = _extractedData['title'];
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Calculate task dates - for recurring tasks, use more future dates
    final List<DateTime> taskDates = _getTaskDates();
    final bool isRecurring = _extractedData['isRecurring'] ?? false;

    // Create tasks for each date
    for (final date in taskDates) {
      final task = Task(
        date: date.toIso8601String(),
        title: taskTitle,
        category: _selectedCategory,
        time: _extractedData['time'] ?? '12:00 PM',
        color: Task.getRandomColor(),
        icon: categoryIcons[_selectedCategory] ?? FontAwesomeIcons.listCheck,
        isChecked: false,
        isRecurring: isRecurring,
      );

      taskProvider.addTask(date, task);
    }

    // Save to database based on task type
    _saveTaskToDatabase(
      taskTitle,
      _selectedCategory,
      _extractedData['time'],
      taskDates.first,
      isRecurring,
      userProvider.userId,
    );

    NotificationService.showToast(
      context,
      "Task Automated",
      isRecurring
          ? "'$taskTitle' has been added as a recurring task"
          : "'$taskTitle' has been added to your calendar",
    );

    Navigator.pop(context, true);
  }

  // Replace the _saveTaskToDatabase method in task_automation.dart:
  Future<void> _saveTaskToDatabase(
    String title,
    String category,
    String time,
    DateTime date,
    bool isRecurring,
    int userId,
  ) async {
    try {
      // Convert time to 24-hour format for database
      final databaseTime = _convertTo24HourFormat(time);
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (isRecurring) {
        // Save recurring task to recurring_tasks table
        log('Saving recurring task to recurring_tasks table');
        
        final recurringTaskData = {
          'user_id': userId,
          'title': title,
          'category': category,
          'time': databaseTime,
          'date': dateString,
          'completed': false,
          'frequency': 'weekly', // Default frequency
        };

        final response = await saveRecurringTaskToDatabase(recurringTaskData);
        
        if (response != null) {
          log('Recurring task saved successfully: $response');
        }
      } else {
        // Save to regular tasks table
        final taskMain = TaskMain(
          title: title,
          category: category,
          time: databaseTime,
          date: dateString,
          userId: userId,
          completed: false,
        );

        log('Saving regular task to database: ${taskMain.toJson()}');
        final response = await saveTaskToDatabase(taskMain);
        
        if (response != null) {
          log('Regular task saved successfully: $response');
        }
      }
    } catch (e) {
      log('Error saving task to database: $e');
    }
  }

  // Helper method to convert 12-hour to 24-hour format
  String _convertTo24HourFormat(String time12Hour) {
    try {
      String time = time12Hour.toLowerCase().trim();
      bool isPM = time.contains('pm');
      bool isAM = time.contains('am');
      
      // Remove AM/PM
      time = time.replaceAll('pm', '').replaceAll('am', '').trim();
      
      // Split by colon
      List<String> parts = time.split(':');
      if (parts.length < 2) return time12Hour;
      
      int hour = int.parse(parts[0]);
      String minute = parts[1];
      
      // Convert to 24-hour format
      if (isPM && hour != 12) {
        hour += 12;
      } else if (isAM && hour == 12) {
        hour = 0;
      }
      
      return '${hour.toString().padLeft(2, '0')}:$minute';
    } catch (e) {
      log('Error converting time format: $e');
      return time12Hour;
    }
  }

  // Update the _getTaskDates method for better recurring dates
  List<DateTime> _getTaskDates() {
    List<DateTime> dates = [];
    final dayOfWeek = _getDayNumber(_extractedData['day']);

    // If no specific day or not recurring, just add today or tomorrow
    if (dayOfWeek == -1 && !_extractedData['isRecurring']) {
      dates.add(DateTime.now());
      return dates;
    }

    DateTime currentDate = DateTime.now();

    // For recurring tasks, add more occurrences
    int occurrencesToAdd = _extractedData['isRecurring'] ? 50 : 1;
    int count = 0;

    if (dayOfWeek != -1) {
      // Recurring on specific day of week
      while (count < occurrencesToAdd) {
        // Find the next occurrence of this day
        while (currentDate.weekday != dayOfWeek) {
          currentDate = currentDate.add(Duration(days: 1));
        }

        dates.add(
          DateTime(currentDate.year, currentDate.month, currentDate.day),
        );
        count++;

        // Move to the next day
        currentDate = currentDate.add(Duration(days: 1));
      }
    } else {
      // Recurring every day
      for (int i = 0; i < occurrencesToAdd; i++) {
        dates.add(
          DateTime(currentDate.year, currentDate.month, currentDate.day + i),
        );
      }
    }

    return dates;
  }

  // Convert day name to weekday number
  int _getDayNumber(String day) {
    final Map<String, int> dayMapping = {
      'Monday': DateTime.monday,
      'Tuesday': DateTime.tuesday,
      'Wednesday': DateTime.wednesday,
      'Thursday': DateTime.thursday,
      'Friday': DateTime.friday,
      'Saturday': DateTime.saturday,
      'Sunday': DateTime.sunday,
    };

    return dayMapping[day] ?? -1;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode
            ? OtakuPlannerTheme.darkBackground
            : OtakuPlannerTheme.lightBackground;
    final cardColor = OtakuPlannerTheme.getCardColor(context);
    final textColor = OtakuPlannerTheme.getTextColor(context);
    final buttonColor = OtakuPlannerTheme.getButtonColor(context);

    // Update the category dropdown to use CategoryProvider:
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categoriesForDropdown;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Task Automation', style: TextStyle(color: textColor)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Automate Tasks with Natural Language',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Describe your recurring task in plain English:',
                style: TextStyle(fontSize: 16, color: textColor),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [OtakuPlannerTheme.getBoxShadow(context)],
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Examples:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Watch Solo Leveling every Friday at 7:00 PM',
                      style: TextStyle(color: textColor),
                    ),
                    Text(
                      '• Study Japanese every Monday at 3 PM',
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _taskController,
                decoration: InputDecoration(
                  hintText: 'Enter your task description...',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: _isProcessing ? null : _processTaskText,
                  child:
                      _isProcessing
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text('Process Task'),
                ),
              ),
              SizedBox(height: 24),
              if (_parsingResult.isNotEmpty && _extractedData.isNotEmpty)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [OtakuPlannerTheme.getBoxShadow(context)],
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Results:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        // Show parsing result without category (we'll show it separately)
                        _formatParsingResultWithoutCategory(_extractedData),
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Add category selection
                      Text(
                        'Category:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 8),

                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            border: InputBorder.none,
                          ),
                          icon: Icon(Icons.arrow_drop_down, color: buttonColor),
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                          dropdownColor: Colors.white,
                          items: categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Row(
                                children: [
                                  Icon(
                                    categoryIcons[category],
                                    size: 16,
                                    color: buttonColor,
                                  ),
                                  SizedBox(width: 14),
                                  Text(category),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      if (_extractedData.isNotEmpty &&
                          _extractedData['title'].isNotEmpty)
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: _createAutomatedTask,
                            child: Text('Create Tasks on Calendar'),
                          ),
                        ),
                    ],
                  ),
                )
              else if (_parsingResult.isNotEmpty)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _parsingResult,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Map of category names to their corresponding icons
final Map<String, IconData> categoryIcons = {
  'Anime': FontAwesomeIcons.tv,
  'Manga': FontAwesomeIcons.book,
  'Gaming': FontAwesomeIcons.gamepad,
  'Study': FontAwesomeIcons.graduationCap,
  'Work': FontAwesomeIcons.briefcase,
  'Personal': FontAwesomeIcons.user,
  'General': FontAwesomeIcons.tasks,
};
