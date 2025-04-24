import 'package:flutter/material.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/shared/notifications.dart';
import 'package:otakuplanner/themes/theme.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      "specificDate":null,
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
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
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

    result['isRecurring'] = lowerText.contains('every') || lowerText.contains('weekly');

    final categories = ['Anime', 'Manga', 'Gaming', 'Study', 'Work', 'Personal'];
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
          title = text.substring(0, lowerText.indexOf(day, lowerText.indexOf(day))).trim();
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
  // Format the parsing result for display
  String _formatParsingResult(Map<String, dynamic> data) {
    if (data['title'].isEmpty && data['day'].isEmpty && data['time'].isEmpty) {
      return 'Could not understand the task. Please try again with a clearer description.';
    }

    final List<String> parts = [];

    if (data['title'].isNotEmpty) {
      parts.add('Task: ${data['title']}');
    }

    if (data['day'].isNotEmpty) {
      parts.add('Day: ${data['day']}');
    }

    if (data['time'].isNotEmpty) {
      parts.add('Time: ${data['time']}');
    }

    parts.add('Category: ${data['category']}');
    parts.add('Recurring: ${data['isRecurring'] ? 'Yes' : 'No'}');

    return parts.join('\n');
  }

  // Format the parsing result without category for display
  String _formatParsingResultWithoutCategory(Map<String, dynamic> data) {
    if (data['title'].isEmpty && data['day'].isEmpty && data['time'].isEmpty) {
      return 'Could not understand the task. Please try again with a clearer description.';
    }

    final List<String> parts = [];

    if (data['title'].isNotEmpty) {
      parts.add('Task: ${data['title']}');
    }

    if (data['day'].isNotEmpty) {
      parts.add('Day: ${data['day']}');
    }

    if (data['time'].isNotEmpty) {
      parts.add('Time: ${data['time']}');
    }

    // Include recurring information but exclude category
    parts.add('Recurring: ${data['isRecurring'] ? 'Yes' : 'No'}');

    return parts.join('\n');
  }

  // Create the task and add it to calendar
  void _createAutomatedTask() {
    if (_extractedData.isEmpty || _extractedData['title'].isEmpty) {
      NotificationService.showToast(
        context, 
        "Processing Error", 
        "Please process a valid task description first"
      );
      return;
    }
  final String taskTitle = _extractedData['title'];

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    // Calculate task dates - for recurring tasks, use more future dates
    final List<DateTime> taskDates = _getTaskDates();
    
    // Create task for each date - use _selectedCategory instead of _extractedData['category']
    for (final date in taskDates) {
      final task = Task(
        title: taskTitle,
        category: _selectedCategory, // Use the selected category
        time: _extractedData['time'] ?? '12:00 PM',
        color: Task.getRandomColor(),
        icon: categoryIcons[_selectedCategory] ?? FontAwesomeIcons.listCheck, // Use selected category icon
        isChecked: false,
        isRecurring: _extractedData['isRecurring'] ?? false, // Add null check
      );
      
      taskProvider.addTask(date, task);
    }
    
    NotificationService.showToast(
      context,
      "Task Automated",
      _extractedData['isRecurring'] 
        ? "'$taskTitle' has been added as a recurring task"
        : "'$taskTitle' has been added to your calendar",
    );
    
    Navigator.pop(context, true);
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
    
    // For recurring tasks, add more future occurrences
    int occurrencesToAdd = _extractedData['isRecurring'] ? 50 : 1;
    int count = 0;
    
    if (dayOfWeek != -1) {
      // Recurring on specific day of week
      while (count < occurrencesToAdd) {
        // Find the next occurrence of this day
        while (currentDate.weekday != dayOfWeek) {
          currentDate = currentDate.add(Duration(days: 1));
        }
        
        dates.add(DateTime(currentDate.year, currentDate.month, currentDate.day));
        count++;
        
        // Move to the next day
        currentDate = currentDate.add(Duration(days: 1));
      }
    } else {
      // Recurring every day
      for (int i = 0; i < occurrencesToAdd; i++) {
        dates.add(DateTime(
          currentDate.year, 
          currentDate.month, 
          currentDate.day + i
        ));
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
    final backgroundColor = isDarkMode 
        ? OtakuPlannerTheme.darkBackground 
        : OtakuPlannerTheme.lightBackground;
    final cardColor = OtakuPlannerTheme.getCardColor(context);
    final textColor = OtakuPlannerTheme.getTextColor(context);
    final buttonColor = OtakuPlannerTheme.getButtonColor(context);

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
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
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
                    Text('• Watch Solo Leveling every Friday at 7:00 PM', style: TextStyle(color: textColor)),
                    Text('• Study Japanese every Monday at 3 PM', style: TextStyle(color: textColor)),
                 
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
                  child: _isProcessing
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
              if (_parsingResult.isNotEmpty)
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
                        'Parsing Results:',
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
                      
                      // Category chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'General', 'Anime', 'Manga', 'Gaming', 'Study', 'Work', 'Personal'
                        ].map((category) {
                          final isSelected = _selectedCategory == category;
                          return ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            backgroundColor: cardColor,
                            selectedColor: buttonColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : textColor,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      
                      SizedBox(height: 16),
                      if (_extractedData.isNotEmpty && _extractedData['title'].isNotEmpty)
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            onPressed: _createAutomatedTask,
                            child: Text('Create Tasks on Calendar'),
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