import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:otakuplanner/screens/entryScreens/loginPage.dart';
import 'package:otakuplanner/screens/request.dart';
import 'package:otakuplanner/widgets/ink_kit.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;
  bool checkedValue = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  /// Back to the log in screen this page was opened from.
  void _toLogin() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final toggle = PasswordToggle(
      visible: _isPasswordVisible,
      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
    );

    return Scaffold(
      appBar: AppBar(shape: const Border(), toolbarHeight: 48),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Space.l, Space.s, Space.l, Space.l),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    title: 'Create your account',
                    line: 'Plan anime nights next to work, study and everything else.',
                    markHeight: 48,
                  ),
                  const SizedBox(height: Space.l),
                  AuthField(
                    label: 'Full name',
                    controller: _fullNameController,
                    autofillHints: const [AutofillHints.name],
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your fullname';
                      }
                      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                        return 'Please enter a valid fullname';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: Space.m),
                  AuthField(
                    label: 'Username',
                    controller: _usernameController,
                    autofillHints: const [AutofillHints.newUsername],
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: Space.m),
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
                    obscure: !_isPasswordVisible,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.next,
                    suffix: toggle,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: Space.m),
                  AuthField(
                    label: 'Confirm password',
                    controller: _confirmPasswordController,
                    obscure: !_isPasswordVisible,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    suffix: toggle,
                    validator: (value) {
                      final basic = _validatePassword(value);
                      if (basic != null) return basic;
                      if (value != _passwordController.text) return "Passwords don't match";
                      return null;
                    },
                  ),
                  const SizedBox(height: Space.gutter),
                  InkWell(
                    onTap: () => setState(() => checkedValue = !checkedValue),
                    child: Row(
                      children: [
                        Checkbox(
                          value: checkedValue,
                          onChanged: (newValue) => setState(() => checkedValue = newValue ?? false),
                        ),
                        Expanded(
                          child: Text(
                            'I agree to the Terms & Conditions',
                            style: context.type.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Space.gutter),
                  if (_errorMessage != null) ...[
                    AuthNotice(_errorMessage!),
                    const SizedBox(height: Space.m),
                  ],
                  InkButton(
                    label: 'Create account',
                    expand: true,
                    loading: _isLoading,
                    onPressed: _signUpUser,
                  ),
                  const SizedBox(height: Space.m),
                  Row(
                    children: [
                      Text('Already have an account?', style: context.type.bodyMedium),
                      const SizedBox(width: Space.xs),
                      InkButton.quiet(label: 'Log in', small: true, onPressed: _toLogin),
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

  Future<void> _signUpUser() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (!checkedValue) {
      setState(() {
        _errorMessage = 'Please accept the Terms & Conditions';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      log('Attempting signup for: ${_emailController.text}');

      // Field names match the backend's /auth/register
      final signupData = {
        'username': _usernameController.text.trim(),
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      };

      final response = await post('/auth/register', signupData);
      log('Received signup response: $response');

      if (response != null && response is Map) {
        if (response['status'] == 'success') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account created. Log in to start planning.')),
            );
            // Back to log in
            Navigator.pop(context);
          }
        } else {
          setState(() {
            _errorMessage = response['message'] ?? 'Registration failed';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server returned empty response';
        });
        log('Empty response from server');
      }
    } catch (e) {
      log('Signup error: $e');
      if (mounted) {
        String errorMsg = 'Registration failed';

        if (e is DioException) {
          if (e.response?.statusCode == 404) {
            errorMsg = 'Registration service not found. Please contact support.';
          } else if (e.response?.data != null) {
            final data = e.response!.data;
            if (data is Map && data['message'] != null) {
              errorMsg = data['message'];
            } else if (data is Map && data['error'] != null) {
              errorMsg = data['error'];
            }
          }
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
