import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _username = '';
    String _profileImagePath = ""; // Store image path


  String get username => _username;
    String get profileImagePath => _profileImagePath;


  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }
   void setProfileImagePath(String path) {
    _profileImagePath = path;
    notifyListeners();
  }
}
