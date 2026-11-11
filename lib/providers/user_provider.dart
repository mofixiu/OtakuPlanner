import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserProvider with ChangeNotifier {
  String _username = '';
  String _token = '';
  String _profileImagePath = "";
  int? _userId;
  String _email = '';
  String _fullName = '';
  String _joinDate = '';
  bool _isInitialized = false; // Add this flag

  // Hive box name
  static const String _boxName = 'user_data';
  late Box _userBox;

  String get username => _username;
  String get token => _token;
  String get profileImagePath => _profileImagePath;
  int get userId => _userId!;
  String get email => _email;
  String get fullName => _fullName;
  String get joinDate => _joinDate;
  bool get isInitialized => _isInitialized; // Add this getter
  bool get hasValidUserData => _username.isNotEmpty && _email.isNotEmpty && _userId != null;

  // Initialize Hive box
  Future<void> initHive() async {
    if (_isInitialized) return; // Prevent double initialization
    
    try {
      _userBox = await Hive.openBox(_boxName);
      await loadUserData();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
      // Fallback: create a new box if opening fails
      try {
        _userBox = await Hive.openBox(_boxName);
        _isInitialized = true;
      } catch (fallbackError) {
        debugPrint('Fallback initialization failed: $fallbackError');
      }
    }
  }

  // Load user data from Hive
  Future<void> loadUserData() async {
    if (!_isInitialized) {
      return;
    }
    
    try {
      _username = _userBox.get('username', defaultValue: '') ?? '';
      _email = _userBox.get('email', defaultValue: '') ?? '';
      _fullName = _userBox.get('fullName', defaultValue: '') ?? '';
      _joinDate = _userBox.get('joinDate', defaultValue: '') ?? '';
      _profileImagePath = _userBox.get('profileImagePath', defaultValue: '') ?? '';
      _userId = _userBox.get('userId');
      
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data from Hive: $e');
    }
  }

  // Save user data to Hive
  Future<void> _saveUserData() async {
    if (!_isInitialized) {
      return;
    }
    
    try {
      // Save each field individually with explicit await
      await _userBox.put('username', _username);
      await _userBox.put('email', _email);
      await _userBox.put('fullName', _fullName);
      await _userBox.put('joinDate', _joinDate);
      await _userBox.put('profileImagePath', _profileImagePath);
      
      if (_userId != null) {
        await _userBox.put('userId', _userId!);
      }
      
      // Force Hive to flush to disk
      await _userBox.flush();
      
    } catch (e) {
      debugPrint('Error saving user data to Hive: $e');
    }
  }

  // Public wrapper for _saveUserData
  Future<void> saveUserData() async {
    await _saveUserData();
  }

  void setUsername(String username) {
    _username = username;
    _saveUserData();
    notifyListeners();
  }

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void setProfileImagePath(String path) {
    _profileImagePath = path;
    _saveUserData();
    notifyListeners();
  }

  void setUserId(int? userId) {
    _userId = userId;
    _saveUserData();
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    _saveUserData();
    notifyListeners();
  }

  void setFullName(String fullName) {
    _fullName = fullName;
    _saveUserData();
    notifyListeners();
  }

  void setJoinDate(String joinDate) {
    _joinDate = joinDate;
    _saveUserData();
    notifyListeners();
  }

  // Set all user data at once with better error handling
  void setUserData({
    required String username,
    required String token,
    required String email,
    int? userId,
    required String fullName,
    String? joinDate,
  }) async {
    _username = username;
    _token = token;
    _email = email;
    _userId = userId;
    _fullName = fullName;
    if (joinDate != null) {
      _joinDate = joinDate;
    }
    
    // Save immediately and wait for completion
    await _saveUserData();
    
    // Verify data was saved
    await Future.delayed(Duration(milliseconds: 100));
    await loadUserData();
    
    notifyListeners();
  }

  bool get isLoggedIn => _token.isNotEmpty;

  Future<void> logout() async {
    if (!_isInitialized) return;
    
    try {
      // Clear all stored user data from Hive
      await _userBox.clear();
      
      // Reset in-memory values
      _username = '';
      _token = '';
      _email = '';
      _userId = null;
      _profileImagePath = '';
      _fullName = '';
      _joinDate = '';
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing user data from Hive: $e');
    }
  }

  // Close Hive box when provider is disposed
  @override
  void dispose() {
    if (_isInitialized) {
      _userBox.close();
    }
    super.dispose();
  }
}
