import 'dart:developer';


import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:otakuplanner/screens/entryScreens/loginPage.dart';
import 'package:otakuplanner/screens/request.dart';
import 'package:otakuplanner/themes/theme.dart';
import 'package:otakuplanner/widgets/customButton.dart';


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
   void next() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );}
    @override
void dispose() {
  _usernameController.dispose();
  _emailController.dispose();
  _passwordController.dispose();
  _confirmPasswordController.dispose();
  _fullNameController.dispose();
  super.dispose();
}
  @override
  Widget build(BuildContext context) {
    return Theme(
            data:OtakuPlannerTheme.lightTheme,

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
                    height: MediaQuery.of(context).size.height / 2 - 150,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                  Text(
                    "SIGN UP",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Text(
                    "Join the Otaku Community today!",
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
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                    child: TextFormField(
                      controller: _fullNameController,
                      validator: (value) { 
                      if (value == null || value.isEmpty) {
                        return 'Please enter your fullname';
                      
                      }
                      if( !RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                        return 'Please enter a valid fullname';
                      }
                      return null;
                    },
                      decoration: InputDecoration(
                        hintText: "Fullname",
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        filled: false,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1.0),
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
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                    child: TextFormField(
                      controller: _usernameController,
                      validator: (value) { 
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                      decoration: InputDecoration(
                        hintText: "Username",
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        filled: false,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1.0),
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
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1.0),
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
                          borderRadius: BorderRadius.circular(1.0),
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
                    
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _isPasswordVisible ? false : true,
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
                          borderRadius: BorderRadius.circular(1.0),
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
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _isPasswordVisible ? false : true,
                       validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        filled: false,
                        fillColor: Colors.white12,
                    
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1.0),
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
                  Row(
                    children: [
                      Checkbox(
                        value: checkedValue,
                        // checkColor: Color(0xFF1E293B),
                        focusColor: Color(0xFF1E293B),
                        onChanged: (newValue) {
                          setState(() {
                            checkedValue = newValue!;
                          });
                        },
                      ),
                      Text("I agree to the "),
                      Text(
                        "Terms & Conditions",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
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
                    ontap: _isLoading ? null : _signUpUser,
                    data: "CREATE ACCOUNT",
                    textcolor: Colors.white,
                    backgroundcolor: Color(0xFF1E293B),
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    
                  GestureDetector(
                    onTap: next,
                    child: Text(
                          "Already have an account? Log in",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );}
    Future<void> _signUpUser() async {
  // Check if form key is valid before validating
  if (_formKey.currentState?.validate() != true) {
    return;
  }

  // Check if terms are accepted
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
    // Add debug logging
    log('Attempting signup for: ${_emailController.text}');
    
    // Prepare signup data - make sure field names match backend
    final signupData = {
      'username': _usernameController.text.trim(),
      'fullName': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
    };
    
    log('Sending request to /auth/register with data: $signupData');
    
    // Use the exact endpoint from your userRoute.js
    final response = await post('/auth/register', signupData);
    log('Received signup response: $response');
    
    // Handle successful signup
    if (response != null && response is Map) {
      // Check for success status
      if (response['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to login
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
      
      // Handle different types of errors
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
//   Future<void> _signUpUser() async {
//   // Check if form key is valid before validating
//   if (_formKey.currentState?.validate() != true) {
//     return;
//   }

//   // Check if terms are accepted
//   if (!checkedValue) {
//     setState(() {
//       _errorMessage = 'Please accept the Terms & Conditions';
//     });
//     return;
//   }

//   setState(() {
//     _isLoading = true;
//     _errorMessage = null;
//   });

//   try {
//     // Add debug logging
//     log('Attempting signup for: ${_emailController.text}');
    
//     // Prepare signup data
//     final signupData = {
//       'username': _usernameController.text.trim(),
//       'email': _emailController.text.trim(),
//       'password': _passwordController.text,
//     };
    
//     log('Sending request to /auth/register with data: $signupData');
//     final response = await post('/auth/register', signupData);
//     log('Received signup response: $response');
    
//     // Handle successful signup
//     if (response != null) {
//       // Some APIs return a token immediately after signup
//       final token = response is Map ? 
//                   (response['data']?['token'] ?? 
//                    response['data']?['access_token'] ?? 
//                    response['token'] ?? 
//                    response['access_token']) : null;
                   
//       if (token != null) {
//         // Save token using the authentication system
//         log('Token received, saving: ${token.toString().substring(0, min(10, token.toString().length))}...');
//         await setAuthToken(token);
        
//         // Save username in provider
//         if (mounted) {
//           Provider.of<UserProvider>(context, listen: false).setUsername(_usernameController.text);

//           // Show success message
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Account created successfully!'),
//               backgroundColor: Colors.green,
//             ),
//           );

//           // Navigate to setup page
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const SetupPage1()),
//           );
//         }
//       } else {
//         // Handle the case where signup was successful but no token was returned
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Account created! Please check your email for verification.'),
//               backgroundColor: Colors.green,
//             ),
//           );

//           // Navigate back to login
//           Navigator.pop(context);
//         }
//       }
//     } else {
//       setState(() {
//         _errorMessage = 'Server returned empty response';
//       });
//       log('Empty response from server');
//     }
//   } catch (e) {
//     log('Signup error: $e');
//     if (mounted) {
//       String errorMsg = 'Registration failed';
      
//       // Handle different types of errors
//       if (e is DioException) {
//         switch (e.type) {
//           case DioExceptionType.connectionTimeout:
//           case DioExceptionType.sendTimeout:
//           case DioExceptionType.receiveTimeout:
//             errorMsg = 'Connection timeout. Please check your internet connection.';
//             break;
//           case DioExceptionType.connectionError:
//             errorMsg = 'Cannot connect to server. Please check your internet connection.';
//             break;
//           case DioExceptionType.unknown:
//             if (e.error is HttpException) {
//               errorMsg = 'Server connection error. Please try again later.';
//             } else {
//               errorMsg = 'Network error. Please try again.';
//             }
//             break;
//           default:
//             if (e.response?.data != null) {
//               final data = e.response!.data;
//               if (data is Map && data['message'] != null) {
//                 errorMsg = data['message'];
//               } else if (data is Map && data['error'] != null) {
//                 errorMsg = data['error'];
//               }
//             }
//         }
//       }
      
//       setState(() {
//         _errorMessage = errorMsg;
//       });
//     }
//   } finally {
//     if (mounted) {
//       setState(() => _isLoading = false);
//     }
//   }
// }
//   Future<void> _signUpUser() async {
//   // Check if form key is valid before validating
//   if (_formKey.currentState?.validate() != true) {
//     return;
//   }

//   // Check if terms are accepted
//   if (!checkedValue) {
//     setState(() {
//       _errorMessage = 'Please accept the Terms & Conditions';
//     });
//     return;
//   }

//   setState(() {
//     _isLoading = true;
//     _errorMessage = null;
//   });

//   try {
//     // Add debug logging
//     log('Attempting signup for: ${_emailController.text}');
    
//     // Prepare signup data
//     final signupData = {
//       'username': _usernameController.text.trim(),
//       'email': _emailController.text.trim(),
//       'password': _passwordController.text,
//     };
    
//     log('Sending request to /auth/register with data: $signupData');
//     final response = await post('/auth/register', signupData);
//     log('Received signup response: $response');
    
//     // Handle successful signup
//     if (response != null) {
//       // Some APIs return a token immediately after signup
//       final token = response is Map ? 
//                   (response['data']?['token'] ?? 
//                    response['data']?['access_token'] ?? 
//                    response['token'] ?? 
//                    response['access_token']) : null;
                   
//       if (token != null) {
//         // Save token using the authentication system
//         log('Token received, saving: ${token.toString().substring(0, min(10, token.toString().length))}...');
//         await setAuthToken(token);
        
//         // Save username in provider
//         if (mounted) {
//           Provider.of<UserProvider>(context, listen: false).setUsername(_usernameController.text);

//           // Show success message
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Account created successfully!'),
//               backgroundColor: Colors.green,
//             ),
//           );

//           // Navigate to setup page
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const SetupPage1()),
//           );
//         }
//       } else {
//         // Handle the case where signup was successful but no token was returned
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Account created! Please check your email for verification.'),
//               backgroundColor: Colors.green,
//             ),
//           );

//           // Navigate back to login
//           Navigator.pop(context);
//         }
//       }
//     } else {
//       setState(() {
//         _errorMessage = 'Server returned empty response';
//       });
//       log('Empty response from server');
//     }
//   } catch (e) {
//     log('Signup error: $e');
//     if (mounted) {
//       // Server might return specific error messages
//       String errorMsg = 'Registration failed';
      
//       // Try to extract error message from response
//       if (e is DioException && e.response?.data != null) {
//         final data = e.response!.data;
//         if (data is Map && data['message'] != null) {
//           errorMsg = data['message'];
//         } else if (data is Map && data['error'] != null) {
//           errorMsg = data['error'];
//         }
//       }
      
//       setState(() {
//         _errorMessage = errorMsg;
//       });
//     }
//   } finally {
//     if (mounted) {
//       setState(() => _isLoading = false);
//     }
//   }
// }
//   Future<void> _signUpUser() async {
//   // Validate the for
// first
//   if (_formKey.currentState!.validate()) {
//     // Check if terms are accepted
//     if (!checkedValue) {
//       setState(() {
//         _errorMessage = 'Please accept the Terms & Conditions';
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       // Add debug logging
//       log('Attempting signup for: ${_emailController.text}');
      
//       // Prepare signup data
//       final signupData = {
//         'username': _usernameController.text.trim(),
//         'email': _emailController.text.trim(),
//         'password': _passwordController.text,
        
//       };
      
//       // Check if passwords match
//       if (_passwordController.text != _confirmPasswordController.text) {
//         setState(() {
//           _errorMessage = 'Passwords do not match';
//           _isLoading = false;
//         });
//         return;
//       }
      
//       log('Sending request to /auth/register with data: $signupData');
//       final response = await post('/auth/register', signupData);
//       log('Received signup response: $response');
      
//       // Handle successful signup
//       if (response != null) {
//         // Some APIs return a token immediately after signup
//         final token = response is Map ? 
//                     (response['data']?['token'] ?? 
//                      response['data']?['access_token'] ?? 
//                      response['token'] ?? 
//                      response['access_token']) : null;
                     
//         if (token != null) {
//           // Save token using the authentication system
//           log('Token received, saving: ${token.toString().substring(0, min(10, token.toString().length))}...');
//           await setAuthToken(token);
          
//           // Save username in provider
//           Provider.of<UserProvider>(context, listen: false).setUsername(_usernameController.text);

//           // Show success message
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Account created successfully!'),
//                 backgroundColor: Colors.green,
//               ),
//             );

//             // Navigate to setup page
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const SetupPage1()),
//             );
//           }
//         } else {
//           // Handle the case where signup was successful but no token was returned
//           // This is normal for some APIs that require email verification first
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Account created! Please check your email for verification.'),
//                 backgroundColor: Colors.green,
//               ),
//             );

//             // Navigate back to login
//             Navigator.pop(context);
//           }
//         }
//       } else {
//         setState(() {
//           _errorMessage = 'Server returned empty response';
//         });
//         log('Empty response from server');
//       }
//     } catch (e) {
//       log('Signup error: $e');
//       if (mounted) {
//         // Server might return specific error messages
//         String errorMsg = 'Registration failed';
        
//         // Try to extract error message from response
//         if (e is DioException && e.response?.data != null) {
//           final data = e.response!.data;
//           if (data is Map && data['message'] != null) {
//             errorMsg = data['message'];
//           } else if (data is Map && data['error'] != null) {
//             errorMsg = data['error'];
//           }
//         }
        
//         setState(() {
//           _errorMessage = errorMsg;
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
}
