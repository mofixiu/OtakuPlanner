import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/models/taskMain.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/entryScreens/signup.dart';
import 'package:otakuplanner/screens/normalMode/dashboard.dart';
import 'package:otakuplanner/screens/request.dart';
import 'package:otakuplanner/shared/category_icons.dart';
import 'package:otakuplanner/widgets/ink_kit.dart';
import 'package:provider/provider.dart';

/// Email check shared by log in and sign up.
final RegExp authEmailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _create() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUp()));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(Space.l, Space.m, Space.l, Space.m),
            child: ConstrainedBox(
              // At least a screen tall, so the sign-up link sits at the foot of the page.
              constraints: BoxConstraints(minHeight: viewport.maxHeight - Space.m * 2),
              child: IntrinsicHeight(
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _LoginHero(),
                        const SizedBox(height: Space.l),
                        Text('OtakuPlanner', style: context.type.displaySmall),
                        const SizedBox(height: Space.xs),
                        Text(
                          'Your tasks, shows and streak, on one page.',
                          style: context.type.bodyMedium?.copyWith(color: c.inkMuted),
                        ),
                        const SizedBox(height: Space.l),
                        AuthField(
                          label: 'Email',
                          controller: _emailController,
                          hint: 'you@example.com',
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            } else if (!authEmailPattern.hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: Space.m),
                        AuthField(
                          label: 'Password',
                          controller: _passwordController,
                          // Hidden until the eye is tapped.
                          obscure: !_isPasswordVisible,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            if (!_isLoading) _loginUser();
                          },
                          suffix: PasswordToggle(
                            visible: _isPasswordVisible,
                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: Space.l),
                        if (_errorMessage != null) ...[
                          AuthNotice(_errorMessage!),
                          const SizedBox(height: Space.m),
                        ],
                        InkButton(
                          label: 'Log in',
                          expand: true,
                          loading: _isLoading,
                          onPressed: _loginUser,
                        ),
                        const Spacer(),
                        const SizedBox(height: Space.l),
                        Container(height: Strokes.hairline, color: c.rule),
                        const SizedBox(height: Space.s),
                        Row(
                          children: [
                            Text('New here?', style: context.type.bodyMedium),
                            const SizedBox(width: Space.xs),
                            InkButton.quiet(label: 'Create an account', small: true, onPressed: _create),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
        log('Attempting login with email: ${_emailController.text}');

        final loginData = {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        };

        log('Sending request to /auth/login');
        final response = await post('/auth/login', loginData);
        log('Received login response: $response');

        // Handle successful login
        if (response != null && response is Map) {
          if (response['status'] == 'success' && response['data'] != null) {
            final token = response['data']['token'];
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

              if (!mounted) return;
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
              await userProvider.saveUserData();

              // Sync tasks from database after successful login
              if (userData['id'] != null && mounted) {
                try {
                  final taskProvider = Provider.of<TaskProvider>(context, listen: false);

                  log('Starting task sync for user ID: ${userData['id']}');

                  // Clear existing tasks to avoid duplicates
                  taskProvider.clearAllTasks();

                  // Fetch and sync ONLY regular tasks for now
                  final response = await getUserTasks(userData['id']);

                  if (response != null && response['data'] != null) {
                    final tasksData = response['data'] as List;
                    log('Retrieved ${tasksData.length} regular tasks from database during login');

                    for (final taskJson in tasksData) {
                      try {
                        // Ensure completed field is boolean
                        final taskData = Map<String, dynamic>.from(taskJson);
                        if (taskData['completed'] is int) {
                          taskData['completed'] = taskData['completed'] == 1;
                        }

                        // Fix the date format issue - handle the trailing dot
                        String dateString = taskData['date'] as String;
                        if (dateString.endsWith('.')) {
                          dateString = '${dateString.substring(0, dateString.length - 1)}000Z';
                          taskData['date'] = dateString;
                        }

                        // Show the stored 24-hour time the way the app does ("4:20 PM").
                        if (taskData['time'] is String) {
                          taskData['time'] = PlannerFormat.time(taskData['time'] as String);
                        }

                        final taskMain = TaskMain.fromJson(taskData);

                        final task = Task(
                          id: taskMain.id,
                          title: taskMain.title,
                          category: taskMain.category,
                          time: taskMain.time,
                          date: taskMain.date,
                          isChecked: taskMain.completed,
                          color: Task.getRandomColor(),
                          icon: categoryIconFor(taskMain.category),
                          isRecurring: false, // All tasks from regular table are non-recurring
                        );

                        final taskDate = _parseTaskDate(taskMain.date);
                        final normalizedDate = DateTime(taskDate.year, taskDate.month, taskDate.day);

                        taskProvider.addTaskIfNotExists(normalizedDate, task);
                      } catch (e) {
                        log('Error converting regular task during login: $e');
                        log('Task JSON that failed: $taskJson');
                      }
                    }
                  } else {
                    log('No response data from getUserTasks: $response');
                  }
                } catch (e) {
                  log('Failed to sync tasks after login: $e');
                }
              } else {
                log('No user ID available for task sync');
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged in')),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()),
                );
              }
            } else {
              setState(() {
                _errorMessage = 'Invalid server response: Missing authentication data';
              });
              log('Login response missing token or user data: $response');
            }
          } else {
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
        log('Login error: $e');
        if (mounted) {
          String errorMsg = 'Login failed';

          if (e is DioException) {
            log('DioException details: ${e.response?.statusCode} - ${e.response?.data}');

            if (e.response?.statusCode == 401) {
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
      return DateTime.parse(dateString);
    } catch (e) {
      String fixedDate = dateString;

      // Remove trailing dot and add proper milliseconds
      if (fixedDate.endsWith('.')) {
        fixedDate = '${fixedDate.substring(0, fixedDate.length - 1)}.000Z';
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

        log('Could not parse date: $dateString, using today instead');
        return DateTime.now();
      }
    }
  }
}

/// The top of the log in page: a manga panel where focus lines close in on the
/// mascot, who has one line to say. The panel's left edge crops the mascot's
/// hair, as a frame would.
class _LoginHero extends StatelessWidget {
  const _LoginHero();

  static const double _height = 236;
  static const double _mascotHeight = 248;
  static const double _mascotWidth = _mascotHeight * 274 / 365; // the line art's proportions

  /// How far the mascot runs past the bottom of the panel.
  static const double _mascotDrop = 44;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    const shape = BoxDecoration(borderRadius: Radii.panelAll);
    return Container(
      height: _height,
      clipBehavior: Clip.antiAlias,
      decoration: shape.copyWith(color: c.paper),
      foregroundDecoration: shape.copyWith(border: Border.all(color: c.ink, width: Strokes.panel)),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: FocusLinesPainter(
                color: c.ink,
                // The middle of the mascot's face.
                focus: const Offset(_mascotWidth / 2, _height + _mascotDrop - _mascotHeight * 0.45),
                clear: const Size(_mascotWidth * 1.3, _mascotHeight * 1.12),
              ),
            ),
          ),
          const Positioned(
            left: -1,
            bottom: -_mascotDrop,
            child: MascotLine(height: _mascotHeight),
          ),
          Positioned(
            right: Space.m,
            top: Space.l,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 168),
              child: SpeechBalloon(
                tail: BalloonTail.left,
                child: Text("Don't break the streak.", style: context.type.titleLarge),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Pieces shared by the log in, sign up and reset screens ----

/// The logo mark, a heading and one plain line under it, left-aligned.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.line, this.markHeight = 64});

  final String title;
  final String line;
  final double markHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LogoMark(height: markHeight),
        const SizedBox(height: Space.m),
        Text(title, style: context.type.displaySmall),
        const SizedBox(height: Space.xs),
        Text(line, style: context.type.bodyMedium?.copyWith(color: context.ink.inkMuted)),
      ],
    );
  }
}

/// A labelled, outlined text field.
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Kicker(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscure,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          textCapitalization: textCapitalization,
          autocorrect: !obscure && keyboardType != TextInputType.emailAddress,
          enableSuggestions: !obscure,
          style: context.type.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

/// The eye button that shows or hides a password.
class PasswordToggle extends StatelessWidget {
  const PasswordToggle({super.key, required this.visible, required this.onPressed});

  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: visible ? 'Hide password' : 'Show password',
      icon: Icon(visible ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
      onPressed: onPressed,
    );
  }
}

/// A message in an ink panel: what went wrong, or what happened.
class AuthNotice extends StatelessWidget {
  const AuthNotice(this.message, {super.key, this.icon = Icons.error_outline});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Panel(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: context.ink.ink),
            const SizedBox(width: Space.s),
            Expanded(child: Text(message, style: context.type.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
