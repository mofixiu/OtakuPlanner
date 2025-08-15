import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:otakuplanner/models/taskMain.dart';

const host = "https://enjoyed-kid-amusing.ngrok-free.app";
const baseUrl = "$host/api";

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class RequestService {
  late final Dio _dio;
  static const String _tokenBoxName = 'token';
  static const String _userBoxName = 'user';

  static RequestService? _instance;

  RequestService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Accept': 'application/json'},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // SINGLE interceptor with all functionality combined
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip adding token for auth routes
          if (!options.path.startsWith('/auth/')) {
            final token = await getAuthToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          
          // Debug logging
          log('Request: ${options.method} ${options.uri}');
          log('Request headers: ${options.headers}');
          if (options.data != null) {
            log('Request data: ${options.data}');
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          log('Response: ${response.statusCode} ${response.statusMessage}');
          log('Response data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) async {
          log('API Error: ${error.message}');
          log('Error Type: ${error.type}');
          log('Request path: ${error.requestOptions.path}');
          
          if (error.response != null) {
            log('Error Response Status: ${error.response?.statusCode}');
            log('Error Response Data: ${error.response?.data}');
            log('Error Response Headers: ${error.response?.headers}');
          }

          // ONLY handle 401 errors as session expiry for NON-AUTH routes
          if (error.response?.statusCode == 401 && 
              !error.requestOptions.path.startsWith('/auth/')) {
            log('Session expired - handling unauthorized access');
            await _handleUnauthorized();
          } else if (error.response?.statusCode == 401 && 
                     error.requestOptions.path.startsWith('/auth/')) {
            log('Login failed - 401 on auth endpoint, not handling as session expiry');
          }

          handler.next(error);
        },
      ),
    );
  }

  static Future<RequestService> getInstance() async {
    if (_instance == null) {
      _instance = RequestService._internal();
      // Initialize after creating the instance
      await _instance!._initHive();
    }
    return _instance!;
  }

  Future<void> _initHive() async {
    try {
      // Ensure the token box is opened
      Box tokenBox;
      Box userBox;
      if (Hive.isBoxOpen(_tokenBoxName)) {
        tokenBox = Hive.box(_tokenBoxName);
      } else {
        tokenBox = await Hive.openBox(_tokenBoxName);
      }

      if (Hive.isBoxOpen(_userBoxName)) {
        userBox = Hive.box(_userBoxName);
      } else {
        userBox = await Hive.openBox(_userBoxName);
      }

      final token = tokenBox.get('token');
      final user = userBox.get('user');
      if (token != null) {
        log('Token found: ${token.substring(0, 10)}...');
      } else {
        log('No token found in storage');
      }
      if (user != null) {
        log('User found: $user');
      } else {
        log('No user found in storage');
      }
    } catch (e) {
      log('Error initializing Hive: $e');
      rethrow;
    }
  }

  // Get authentication token from Hive
  Future<String?> getAuthToken() async {
    try {
      Box tokenBox;
      if (Hive.isBoxOpen(_tokenBoxName)) {
        tokenBox = Hive.box(_tokenBoxName);
      } else {
        tokenBox = await Hive.openBox(_tokenBoxName);
      }

      final token = tokenBox.get('token');
      return token;
    } catch (e) {
      log('Error getting auth token: $e');
      return null;
    }
  }

  // Set authentication token in Hive
  Future<void> setAuthToken(String token) async {
    try {
      Box tokenBox;
      if (Hive.isBoxOpen(_tokenBoxName)) {
        tokenBox = Hive.box(_tokenBoxName);
      } else {
        tokenBox = await Hive.openBox(_tokenBoxName);
      }

      await tokenBox.put('token', token);
      log('Auth token saved successfully');
    } catch (e) {
      log('Error setting auth token: $e');
    }
  }

  // Clear authentication token from Hive
  Future<void> clearAuthToken() async {
    try {
      Box tokenBox;
      if (Hive.isBoxOpen(_tokenBoxName)) {
        tokenBox = Hive.box(_tokenBoxName);
      } else {
        tokenBox = await Hive.openBox(_tokenBoxName);
      }

      await tokenBox.delete('token');
      log('Auth token cleared successfully');
    } catch (e) {
      log('Error clearing auth token: $e');
    }
  }

  // Handle unauthorized access
  Future<void> _handleUnauthorized() async {
    try {
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Show notification to user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your session has expired. Please log in again.'),
            duration: Duration(seconds: 3),
          ),
        );

        // Wait a bit for the user to see the message
        await Future.delayed(const Duration(seconds: 2));
      }

      // Clear the token
      await clearAuthToken();
      log('Authentication token removed due to 401 error');

      // Only navigate if we're not already on the login screen
      if (context != null) {
        final currentRoute = ModalRoute.of(context)?.settings.name;
        if (currentRoute != '/login') {
          // Navigate to login screen when unauthorized
          await Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      }
    } catch (e) {
      log('Error handling unauthorized: $e');
    }
  }

  Future<dynamic> get(
    String url, [
    dynamic queryParameters,
    dynamic headers,
  ]) async {
    try {
      log(baseUrl + url);
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }
  
Future<dynamic> post(
  String url, [
  dynamic data,
  dynamic queryParameters,
  dynamic headers,
]) async {
  try {
    log('POST request to: ${baseUrl + url}');
    if (data != null) log('Request body: $data');
    
    final response = await _dio.post(
      url,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
    
    log('Response status: ${response.statusCode}');
    log('Response data: ${response.data}');
    
    return response.data;
  } on DioException catch (e) {
    // Log the complete error
    log('DioException on POST ${baseUrl + url}: ${e.message}');
    if (e.response != null) {
      log('Error response status: ${e.response?.statusCode}');
      log('Error response data: ${e.response?.data}');
    }
    
    _handleDioError(e);
    rethrow;
  }
}

  Future<dynamic> put(
    String url, [
    dynamic data,
    dynamic queryParameters,
    dynamic headers,
  ]) async {
    try {
      log(baseUrl + url);
      final response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<dynamic> delete(
    String url, [
    dynamic queryParameters,
    dynamic data,
    dynamic headers,
  ]) async {
    try {
      log(baseUrl + url);
      final response = await _dio.delete(
        url,
        queryParameters: queryParameters,
        data: data,
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException error) {
    String errorMessage;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage =
            'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Server response timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            errorMessage = 'Bad request. Please check your input.';
            break;
          case 401:
            errorMessage = 'Unauthorized. Please login again.';
            break;
          case 403:
            errorMessage = 'Access forbidden. You don\'t have permission.';
            break;
          case 404:
            errorMessage = 'Resource not found.';
            break;
          case 500:
            errorMessage = 'Internal server error. Please try again later.';
            break;
          default:
            errorMessage = 'Server error ($statusCode). Please try again.';
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        errorMessage =
            'Connection error. Please check your internet connection.';
        break;
      default:
        errorMessage = 'Network error. Please try again.';
    }
    log('Dio Error: $errorMessage');
  }
}

// Global instance for backward compatibility
late RequestService _requestService;

// Initialize the service (call this in your main function)
Future<void> initRequestService() async {
  _requestService = await RequestService.getInstance();
}

// Backward compatible functions
Future<dynamic> get(
  String url, [
  dynamic queryParameters,
  dynamic headers,
]) async {
  return await _requestService.get(url, queryParameters, headers);
}

Future<dynamic> post(
  String url, [
  dynamic data,
  dynamic queryParameters,
  dynamic headers,
]) async {
  return await _requestService.post(url, data, queryParameters, headers);
}

Future<dynamic> put(
  String url, [
  dynamic data,
  dynamic queryParameters,
  dynamic headers,
]) async {
  return await _requestService.put(url, data, queryParameters, headers);
}

Future<dynamic> delete(
  String url, [
  dynamic queryParameters,
  dynamic data,
  dynamic headers,
]) async {
  return await _requestService.delete(url, queryParameters, data, headers);
}

// Authentication helper functions
Future<void> setAuthToken(String token) async {
  await _requestService.setAuthToken(token);
}

Future<String?> getAuthToken() async {
  return await _requestService.getAuthToken();
}

Future<void> clearAuthToken() async {
  await _requestService.clearAuthToken();
}

// Update your existing saveTaskToDatabase method:

Future<Map<String, dynamic>?> saveTaskToDatabase(TaskMain task) async {
  try {
    final taskData = {
      'user_id': task.userId,
      'title': task.title,
      'date': task.date,
      'category': task.category,
      'time': task.time,
      'completed': task.completed,
    };
    
    log('Saving task to database: $taskData');
    
    // Make API call to save task
    final response = await post('/tasks', taskData);
    
    if (response != null) {
      log('Task saved successfully: $response');
      return response;
    }
    
    return null;
  } catch (e) {
    log('Error saving task to database: $e');
    rethrow;
  }
}

Future<Map<String, dynamic>?> updateTaskInDatabase(TaskMain taskMain) async {
  try {
    log('Updating task in database: ${taskMain.toJson()}');
    
    final response = await put('/tasks/${taskMain.id}', taskMain.toJson());
    
    if (response != null) {
      log('Task updated successfully: $response');
      return response;
    }
    
    return null;
  } catch (e) {
    log('Error updating task in database: $e');
    rethrow;
  }
}

Future<bool> deleteTaskFromDatabase(int taskId) async {
  try {
    log('Deleting task from database with ID: $taskId');
    
    final response = await delete('/tasks/$taskId');
    
    if (response != null) {
      log('Task deleted successfully from database');
      return true;
    }
    
    return false;
  } catch (e) {
    log('Error deleting task from database: $e');
    return false;
  }
}

// Add this method to your request.dart if it doesn't exist:

Future<Map<String, dynamic>?> getUserTasks(int userId) async {
  try {
    log('Fetching tasks for user ID: $userId');
    
    final response = await get('/users/$userId/tasks');
    
    if (response != null) {
      log('Successfully retrieved tasks: $response');
      return response;
    } else {
      log('No response received from getUserTasks');
      return null;
    }
  } catch (e) {
    log('Error fetching user tasks: $e');
    return null;
  }
}

Future<List<TaskMain>?> getAllUserTasks(int userId) async {
  try {
    log('Fetching all tasks for user ID: $userId');
    
    final response = await get('/tasks?user_id=$userId');
    
    if (response != null && response['data'] != null) {
      final tasksData = response['data'] as List;
      final tasks = tasksData.map((taskJson) => TaskMain.fromJson(taskJson)).toList();
      
      log('Retrieved ${tasks.length} tasks from database');
      return tasks;
    }
    
    return [];
  } catch (e) {
    log('Error fetching all user tasks: $e');
    return null;
  }
}

// Add these methods to your request.dart file

Future<Map<String, dynamic>?> getUserProfile(int userId) async {
  try {
    log('Fetching user profile for user ID: $userId');
    
    final response = await get('/users/$userId/profile');
    
    if (response != null) {
      log('Retrieved user profile: $response');
      return response;
    }
    
    return null;
  } catch (e) {
    log('Error fetching user profile: $e');
    return null;
  }
}

Future<int> getCompletedTasksCount(int userId) async {
  try {
    log('Fetching completed tasks count for user ID: $userId');
    
    final response = await get('/users/$userId/completed-tasks');
    
    if (response != null && response['data'] != null) {
      final count = response['data']['completedTasks'] ?? 0;
      log('Retrieved completed tasks count: $count');
      return count;
    }
    
    return 0;
  } catch (e) {
    log('Error fetching completed tasks count: $e');
    return 0;
  }
}

// Recurring task API functions
Future<Map<String, dynamic>?> saveRecurringTaskToDatabase(Map<String, dynamic> recurringTaskData) async {
  try {
    log('Saving recurring task to database: $recurringTaskData');
    
    final response = await post('/recurring-tasks', recurringTaskData);
    
    if (response != null) {
      log('Recurring task saved successfully: $response');
      return response;
    }
    
    return null;
  } catch (e) {
    log('Error saving recurring task to database: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> getUserRecurringTasks(int userId) async {
  try {
    log('Fetching recurring tasks for user: $userId');
    final response = await get('/users/$userId/recurring-tasks');
    
    if (response != null) {
      log('Recurring tasks fetched successfully: $response');
      return response;
    } else {
      log('Failed to fetch recurring tasks');
      return null;
    }
  } catch (e) {
    log('Error fetching recurring tasks: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> updateRecurringTaskInDatabase(Map<String, dynamic> recurringTaskData) async {
  try {
    final taskId = recurringTaskData['id'];
    final response = await put('/recurring-tasks/$taskId', recurringTaskData);
    
    if (response != null) {
      log('Recurring task updated in database: $response');
      return response;
    } else {
      log('Failed to update recurring task');
      return null;
    }
  } catch (e) {
    log('Error updating recurring task in database: $e');
    return null;
  }
}

Future<bool> deleteRecurringTaskFromDatabase(int recurringTaskId) async {
  try {
    final response = await delete('/recurring-tasks/$recurringTaskId');
    
    if (response != null) {
      log('Recurring task deleted from database');
      return true;
    } else {
      log('Failed to delete recurring task');
      return false;
    }
  } catch (e) {
    log('Error deleting recurring task from database: $e');
    return false;
  }
}

// Combined function to save task to appropriate table
Future<Map<String, dynamic>?> saveTaskToAppropriateTable(dynamic task) async {
  if (task.isRecurring == true) {
    // Convert to recurring task data and save to recurring_tasks table
    final recurringTaskData = {
      'user_id': task.userId ?? 0,
      'title': task.title,
      'category': task.category,
      'time': task.time,
      'date': task.date,
      'completed': task.isChecked ?? false,
      'frequency': 'weekly', // Default frequency
    };
    return await saveRecurringTaskToDatabase(recurringTaskData);
  } else {
    // Save to regular tasks table
    final taskMain = TaskMain(
      id: task.id,
      title: task.title,
      category: task.category,
      time: task.time,
      date: task.date,
      userId: task.userId ?? 0,
      completed: task.isChecked ?? false,
    );
    return await saveTaskToDatabase(taskMain);
  }
}

Future<Map<String, dynamic>?> updateTaskInAppropriateTable(dynamic task) async {
  if (task.isRecurring == true) {
    // Update in recurring_tasks table
    final recurringTaskData = {
      'id': task.id,
      'user_id': task.userId ?? 0,
      'title': task.title,
      'category': task.category,
      'time': task.time,
      'date': task.date,
      'completed': task.isChecked ?? false,
      'frequency': 'weekly',
    };
    return await updateRecurringTaskInDatabase(recurringTaskData);
  } else {
    // Update in regular tasks table
    final taskMain = TaskMain(
      id: task.id,
      title: task.title,
      category: task.category,
      time: task.time,
      date: task.date,
      userId: task.userId ?? 0,
      completed: task.isChecked ?? false,
    );
    return await updateTaskInDatabase(taskMain);
  }
}

// Category API functions
Future<Map<String, dynamic>?> saveCategory(String categoryName, int userId) async {
  try {
    final response = await post('/categories', {
      'user_id': userId,
      'name': categoryName,
    });
    
    if (response != null) {
      log('Category saved to database: $response');
      return response;
    } else {
      log('Failed to save category');
      return null;
    }
  } catch (e) {
    log('Error saving category to database: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> getUserCategories(int userId) async {
  try {
    log('Fetching categories for user: $userId');
    final response = await get('/users/$userId/categories');
    
    if (response != null) {
      log('Categories fetched successfully: $response');
      return response;
    } else {
      log('Failed to fetch categories');
      return null;
    }
  } catch (e) {
    log('Error fetching categories: $e');
    return null;
  }
}

Future<bool> deleteCategory(int categoryId) async {
  try {
    final response = await delete('/categories/$categoryId');
    
    if (response != null) {
      log('Category deleted from database');
      return true;
    } else {
      log('Failed to delete category');
      return false;
    }
  } catch (e) {
    log('Error deleting category from database: $e');
    return false;
  }
}