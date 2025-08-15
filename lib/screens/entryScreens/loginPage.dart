import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otakuplanner/models/recurring_task.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/models/taskMain.dart';
import 'package:otakuplanner/providers/category_provider.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/screens/entryScreens/SetUpPage1.dart';
import 'package:otakuplanner/screens/entryScreens/forgotPassword.dart';
import 'package:otakuplanner/screens/entryScreens/signup.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/normalMode/dashboard.dart';
import 'package:otakuplanner/screens/request.dart';
import 'package:otakuplanner/themes/theme.dart';
import 'package:otakuplanner/widgets/customButton.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  void login1() {
    String username = _emailController.text.trim();
    if (username.isNotEmpty && _passwordController.text.isNotEmpty) {
      // sav>e the username in the provider
      Provider.of<UserProvider>(context, listen: false).setUsername(username);

      // navigate to setup page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SetupPage1()),
      );
    }
  }

  void forgot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPassword()),
    );
  }

  void create() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUp()),
    );
  }

  void login() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SetupPage1()),
    );
  }

  String? _errorMessage;

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: OtakuPlannerTheme.lightTheme,

      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 30.0,
              left: 40,
              right: 40,
              bottom: 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/otaku.jpg",
                    height: MediaQuery.of(context).size.height / 2 - 130,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    "LOG IN",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Text(
                    "Plan like a true otaku!🎌",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      fontFamily: "AbhayaLibre",
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Email Address",
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        filled: false,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(252, 242, 232, 1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1.0),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(252, 242, 232, 1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Color(0xFF1E293B),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Password",
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(left: 15, right: 10),
                          child: IconButton(
                            icon: Icon(FontAwesomeIcons.eye, color: Colors.grey.shade600, size: 20),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        suffixIconConstraints: BoxConstraints(
                          minHeight: 25,
                          minWidth: 50,
                        ),

                        filled: false,
                        fillColor: Colors.white12,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(252, 242, 232, 1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(252, 242, 232, 1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1.0),
                          borderSide: BorderSide(
                            color: Color(0xFF1E293B),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  CustomButton(
                    ontap: _isLoading ? null : _loginUser,
                    data: "LOG IN",
                    textcolor: Colors.white,
                    backgroundcolor: Color(0xFF1E293B),
                    width: MediaQuery.of(context).size.width,
                    height: 45,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Text(
                    "Or login with",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 3 - 33,
                        height: 40,
                        // margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(252, 242, 232, 1),
                          border: Border.all(
                            color: Colors.grey.shade600,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            "assets/images/google.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Container(
                        width: MediaQuery.of(context).size.width / 3 - 33,
                        height: 40,
                        // margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(252, 242, 232, 1),
                          border: Border.all(
                            color: Colors.grey.shade600,
                            width: 0.7,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            "assets/images/twitter.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Container(
                        width: MediaQuery.of(context).size.width / 3 - 33,
                        height: 40,
                        // margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(252, 242, 232, 1),
                          border: Border.all(
                            color: Colors.grey.shade600,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            "assets/images/apple.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  GestureDetector(
                    onTap: forgot,
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      GestureDetector(
                        onTap: create,
                        child: Text(
                          "Sign Up ",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loginUser() async {
    // Validate the form first
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Add debug logging
        log('Attempting login with email: ${_emailController.text}');

        // Prepare login data
        final loginData = {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        };

        log('Sending request to /auth/login with data: $loginData');
        final response = await post('/auth/login', loginData);
        log('Received login response: $response');

        // Handle successful login
        if (response != null && response is Map) {
          // Check for success status
          if (response['status'] == 'success' && response['data'] != null) {
            // Extract token from response
            final token = response['data']['token'];
            // Extract user data including username
            final userData = response['data']['user'];

            if (token != null && userData != null) {
              // Save token using the authentication system
              await setAuthToken(token);

              // Format the join date properly
              String? formattedJoinDate;
              if (userData['created_at'] != null && userData['created_at'] != '') {
                try {
                  
                  final createdAtDate = DateTime.parse(userData['created_at']);
                  formattedJoinDate = createdAtDate.toIso8601String();
                  log('Parsed join date: $formattedJoinDate');
                } catch (e) {
                  log('Error parsing created_at date: $e');
                  formattedJoinDate = DateTime.now().toIso8601String(); // Fallback
                }
              } else {
                formattedJoinDate = DateTime.now().toIso8601String(); // Fallback
              }

              // Save all user data in provider
              final userProvider = Provider.of<UserProvider>(context, listen: false);

              // Initialize Hive first if not already done
              if (!userProvider.isInitialized) {
                await userProvider.initHive();
              }

              userProvider.setUserData(
                username: userData['username'] ?? 'User',
                token: token,
                email: userData['email'] ?? '',
                userId: userData['id'],
                fullName: userData['fullName'] ?? '',
                joinDate: formattedJoinDate,
              );

              log('User data saved to Hive with join date: $formattedJoinDate');

              // Ensure data is actually saved by calling save explicitly
              await userProvider.saveUserData(); // Change from _saveUserData() to saveUserData()

              // Debug the saved data
              userProvider.debugPrintHiveData();

              // Sync tasks from database after successful login
              if (userData['id'] != null) {
                try {
                  final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                  
                  log('Starting task sync for user ID: ${userData['id']}');
                  
                  // Clear existing tasks to avoid duplicates
                  taskProvider.clearAllTasks();
                  log('Cleared existing tasks from provider');
                  
                  // Fetch and sync ONLY regular tasks for now
                  final response = await getUserTasks(userData['id']);
                  log('getUserTasks response: $response');

                  // Process regular tasks
                  if (response != null && response['data'] != null) {
                    final tasksData = response['data'] as List;
                    log('Retrieved ${tasksData.length} regular tasks from database during login');
                    
                    for (final taskJson in tasksData) {
                      try {
                        log('Converting task JSON: $taskJson');
                        
                        // Ensure completed field is boolean
                        final taskData = Map<String, dynamic>.from(taskJson);
                        if (taskData['completed'] is int) {
                          taskData['completed'] = taskData['completed'] == 1;
                        }
                        
                        // Fix the date format issue - handle the trailing dot
                        String dateString = taskData['date'] as String;
                        if (dateString.endsWith('.')) {
                          // Remove trailing dot and add proper milliseconds
                          dateString = dateString.substring(0, dateString.length - 1) + '000Z';
                          taskData['date'] = dateString;
                        }
                        
                        // Fix time format (convert from 24-hour database format to 12-hour display format)
                        if (taskData['time'] is String) {
                          String timeStr = (taskData['time'] as String).trim();
                          
                          // Convert from 24-hour to 12-hour format with AM/PM
                          timeStr = _convertTo12HourFormat(timeStr);
                          
                          taskData['time'] = timeStr;
                          log('Converted task time to display format: $timeStr');
                        }
                        
                        log('Fixed task data: $taskData');
                        
                        final taskMain = TaskMain.fromJson(taskData);
                        log('Created TaskMain: ${taskMain.toJson()}');
                        
                        final task = Task(
                          id: taskMain.id,
                          title: taskMain.title,
                          category: taskMain.category,
                          time: taskMain.time,
                          date: taskMain.date,
                          isChecked: taskMain.completed,
                          color: Task.getRandomColor(),
                          icon: _getCategoryIcon(taskMain.category),
                          isRecurring: false, // All tasks from regular table are non-recurring
                        );
                        
                        log('Created Task object: ${task.title}');
                        
                        final taskDate = _parseTaskDate(taskMain.date);
                        final normalizedDate = DateTime(taskDate.year, taskDate.month, taskDate.day);
                        
                        log('Parsed task date: $taskDate, normalized: $normalizedDate');
                        
                        taskProvider.addTaskIfNotExists(normalizedDate, task);
                        log('Successfully added task: ${task.title} for date: $normalizedDate');
                        
                        // Verify task was added
                        final addedTasks = taskProvider.tasks[normalizedDate] ?? [];
                        log('Tasks for $normalizedDate after adding: ${addedTasks.length}');
                        
                      } catch (e) {
                        log('Error converting regular task during login: $e');
                        log('Task JSON that failed: $taskJson');
                        log('Stack trace: ${StackTrace.current}');
                      }
                    }
                  } else {
                    log('No response data from getUserTasks or response is null');
                    log('Full response: $response');
                  }
                  
                  // Debug: Print all tasks in provider after sync
                  log('=== TASK PROVIDER DEBUG AFTER SYNC ===');
                  final allDates = taskProvider.tasks.keys.toList();
                  log('Total dates with tasks: ${allDates.length}');
                  for (final date in allDates) {
                    final tasks = taskProvider.tasks[date] ?? [];
                    log('Date $date: ${tasks.length} tasks');
                    for (final task in tasks) {
                      log('  - ${task.title} (${task.category})');
                    }
                  }
                  log('=== END TASK PROVIDER DEBUG ===');
                  
                  // Call dashboard sync after loading tasks
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      final today = DateTime.now();
                      final normalizedToday = DateTime(today.year, today.month, today.day);
                      final todayTasks = taskProvider.tasks[normalizedToday] ?? [];
                      log('Tasks for TODAY after login: ${todayTasks.length}');
                      for (final task in todayTasks) {
                        log('  Today task: ${task.title} - ${task.time}');
                      }
                    }
                  });
                  
                } catch (e) {
                  log('Failed to sync tasks after login: $e');
                  log('Stack trace: ${StackTrace.current}');
                }
              } else {
                log('No user ID available for task sync');
              }

              // Show success message
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Login successful!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()),
                );
              }
            } else {
              setState(() {
                _errorMessage =
                    'Invalid server response: Missing authentication data';
              });
              log('Login response missing token or user data: $response');
            }
          } else {
            // Handle error response
            setState(() {
              _errorMessage = response['message'] ?? 'Login failed';
            });
          }
        } else {
          setState(() {
            _errorMessage = 'Server returned empty response';
          });
          log('Empty response from server');
        }
      } catch (e) {
        // Better error handling
        log('Login error: $e');
        if (mounted) {
          String errorMsg = 'Login failed';

          // Handle different types of errors
          if (e is DioException) {
            log('DioException details: ${e.response?.statusCode} - ${e.response?.data}');
            
            if (e.response?.statusCode == 401) {
              // Check if it's from the login endpoint specifically
              if (e.response?.data != null && e.response!.data is Map) {
                final responseData = e.response!.data as Map;
                errorMsg = responseData['message'] ?? 'Invalid email or password';
              } else {
                errorMsg = 'Invalid email or password';
              }
            } else if (e.response?.statusCode == 400) {
              if (e.response?.data != null && e.response!.data is Map) {
                final responseData = e.response!.data as Map;
                errorMsg = responseData['message'] ?? 'Invalid request';
              } else {
                errorMsg = 'Please check your email and password';
              }
            } else if (e.response?.statusCode == 404) {
              errorMsg = 'Login service not found. Please contact support.';
            } else if (e.response?.statusCode == 500) {
              errorMsg = 'Server error. Please try again later.';
            } else if (e.response?.data != null) {
              final data = e.response!.data;
              if (data is Map && data['message'] != null) {
                errorMsg = data['message'];
              }
            }
          } else {
            // Network or other errors
            errorMsg = 'Network error. Please check your connection.';
          }

          setState(() {
            _errorMessage = errorMsg;
          });
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  DateTime _parseTaskDate(String dateString) {
    try {
      // Try parsing as-is first
      return DateTime.parse(dateString);
    } catch (e) {
      // If it fails, try to fix common issues
      String fixedDate = dateString;
      
      // Remove trailing dot and add proper milliseconds
      if (fixedDate.endsWith('.')) {
        fixedDate = fixedDate.substring(0, fixedDate.length - 1) + '.000Z';
      }
      
      // If no timezone info, assume UTC
      if (!fixedDate.contains('Z') && !fixedDate.contains('+') && !fixedDate.contains('-', 10)) {
        if (!fixedDate.endsWith('Z')) {
          fixedDate += 'Z';
        }
      }
      
      try {
        return DateTime.parse(fixedDate);
      } catch (e2) {
        // As a last resort, try to extract just the date part
        final dateOnlyMatch = RegExp(r'(\d{4}-\d{2}-\d{2})').firstMatch(dateString);
        if (dateOnlyMatch != null) {
          return DateTime.parse('${dateOnlyMatch.group(1)}T00:00:00.000Z');
        }
        
        // If all else fails, return today's date
        log('Could not parse date: $dateString, using today instead');
        return DateTime.now();
      }
    }
  }

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

  // Helper function to convert 24-hour time format to 12-hour format with AM/PM
  String _convertTo12HourFormat(String timeStr) {
    try {
      // Split the time into components
      final parts = timeStr.split(':');
      if (parts.length < 2) return timeStr; // Invalid format, return as is

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));
      
      // Determine the period (AM/PM)
      String period = hour >= 12 ? 'PM' : 'AM';
      
      // Convert to 12-hour format
      if (hour == 0) {
        hour = 12; // 00:xx becomes 12:xx AM
      } else if (hour > 12) {
        hour = hour - 12; // 22:xx becomes 10:xx PM
      }
      // 12:xx stays 12:xx PM, 1-11:xx stay the same with appropriate AM/PM
      
      return '$hour:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      log('Could not convert time format: $timeStr');
      return timeStr; // Return as is if conversion fails
    }
  }
}
//   Future<void> _loginUser() async {
//   // Validate the form first
//   if (_formKey.currentState!.validate()) {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       // Add debug logging
//       log('Attempting login with email: ${_emailController.text}');
      
//       // Prepare login data
//      final loginData = {
//   'email': _emailController.text.trim(), 
//   'password': _passwordController.text,
// };
//       log('Sending request to /auth/login with data: $loginData');
//       final response = await post('/auth/login', loginData);
//       log('Received login response: $response');
      
//       // Handle successful login
//       if (response != null) {
//         // Extract token from response with better error handling
//         final token = response is Map ? 
//                     (response['data']?['token'] ?? 
//                      response['data']?['access_token'] ?? 
//                      response['token'] ?? 
//                      response['access_token']) : null;
                     
//         if (token != null) {
//           // Save token using the authentication system
//           log('Token received, saving: ${token.toString().substring(0, min(10, token.toString().length))}...');
//           await setAuthToken(token);

//           // Show success message
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Login successful!'),
//                 backgroundColor: Colors.green,
//               ),
//             );

//             // Navigate to main screen
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const SetupPage1()),
//             );
//           }
//         } else {
//           // Handle missing token more gracefully
//           setState(() {
//             _errorMessage = 'Invalid server response: Token not found';
//           });
//           log('Login response missing token: $response');
//         }
//       } else {
//         setState(() {
//           _errorMessage = 'Server returned empty response';
//         });
//         log('Empty response from server');
//       }
//     } catch (e) {
//       // Better error handling
//       log('Login error: $e');
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Login failed: ${e.toString()}';
//         });
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
// }

// // Helper function
// int min(int a, int b) => a < b ? a : b;

// }