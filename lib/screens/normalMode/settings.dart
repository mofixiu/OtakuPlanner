// ignore_for_file: deprecated_member_use
// import 'package:animated_switch/animated_switch.dart';
import 'dart:io';

import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otakuplanner/screens/entryScreens/changePassword.dart';
import 'package:otakuplanner/providers/theme_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/normalMode/profile.dart';
import 'package:otakuplanner/themes/theme.dart';
import 'package:otakuplanner/widgets/bottomNavBar.dart';
import 'package:otakuplanner/widgets/customButtonWithAnIcon.dart';
import 'package:otakuplanner/widgets/tustomButton.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  void profile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Profile()),
    );
  }

  void changePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePassword()),
    );
  }

  final int _currentIndex = 4;
  // ignore: unused_field
  bool _isDarkMode = false;
  bool _isAnimeMode = false;
  bool isApp = false;
  bool isSystem = false;
  bool isEmail = false;
  bool isPopup = false;
  bool _weeklySummary = true;
  bool _taskReminders = true;
  bool _featureAnnouncements = false;
  bool _achievementReports = true;
  bool has2FAEnabled = false;

  void _showEmailPreferencesSheet() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = OtakuPlannerTheme.getCardColor(context);
    final textColor = OtakuPlannerTheme.getTextColor(context);

    FamilyModalSheet.show<void>(
      context: context,
      contentBackgroundColor: cardColor,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.email, color: isDarkMode ? Colors.lightBlue : Colors.blue),
                      SizedBox(width: 10),
                      Text(
                        "Email Notification Preferences",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.lightBlue : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Customize which email notifications you'd like to receive. These will be sent to: placeholder@email.com",
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildPreferenceToggle(
                    "Weekly Summary",
                    "Receive a weekly summary of your tasks and progress",
                    _weeklySummary,
                    (value) => setModalState(() => _weeklySummary = value),
                  ),
                  _buildPreferenceToggle(
                    "Task Reminders",
                    "Get reminders about upcoming and overdue tasks",
                    _taskReminders,
                    (value) => setModalState(() => _taskReminders = value),
                  ),
                  _buildPreferenceToggle(
                    "Feature Announcements",
                    "Receive notifications about new features and updates",
                    _featureAnnouncements,
                    (value) => setModalState(() => _featureAnnouncements = value),
                  ),
                  _buildPreferenceToggle(
                    "Achievement Reports",
                    "Get emails when you unlock new achievements",
                    _achievementReports,
                    (value) => setModalState(() => _achievementReports = value),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            isEmail = false;
                          });
                        },
                        child: Text(
                          "Close",
                          style: TextStyle(color: textColor.withOpacity(0.7)),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            isEmail = _weeklySummary || _taskReminders || 
                                      _featureAnnouncements || _achievementReports;
                          });
                          // Here you would save these preferences to your backend/storage
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? Colors.lightBlue : Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Text("Save Preferences"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildPreferenceToggle(
    String title, 
    String subtitle, 
    bool value, 
    ValueChanged<bool> onChanged
  ) {
    final textColor = OtakuPlannerTheme.getTextColor(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: isDarkMode ? Colors.lightBlue : OtakuPlannerTheme.getButtonColor(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileImagePath = Provider.of<UserProvider>(context).profileImagePath;
    _isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    // Get theme colors
    // final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = OtakuPlannerTheme.getCardColor(context);
    final textColor = OtakuPlannerTheme.getTextColor(context);
    final borderColor = OtakuPlannerTheme.getBorderColor(context);
    final buttonColor = OtakuPlannerTheme.getButtonColor(context);
    final boxShadow = OtakuPlannerTheme.getBoxShadow(context);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset("assets/images/otaku.jpg", fit: BoxFit.contain),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 2,
        scrolledUnderElevation: 2,
        title: Text(
          "OtakuPlanner",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: profile,
            child: Padding(
            
              
              padding: const EdgeInsets.only(
                    top: 12.0,
                    left: 12,
                    right: 12,),
              child: CircleAvatar(
                backgroundColor: buttonColor,
                backgroundImage:
                    profileImagePath.isNotEmpty
                        ? FileImage(File(profileImagePath))
                        : null,
                child:
                    profileImagePath.isEmpty
                        ? Icon(Icons.person, color: Colors.grey)
                        : null,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              GestureDetector(
                onTap: profile,
                child: Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [boxShadow],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: buttonColor,
                          backgroundImage:
                              profileImagePath.isNotEmpty
                                  ? FileImage(File(profileImagePath))
                                  : null,
                          child:
                              profileImagePath.isEmpty
                                  ? Icon(Icons.person, color: Colors.grey)
                                  : null,
                        ),
                        SizedBox(width: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Text(
                              "User",
                              style: TextStyle(
                                fontSize: 18,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "placeholder@email.com",
                              style: TextStyle(
                                fontSize: 12,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Container(
                height: 92,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [boxShadow],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 12.0,
                    left: 12,
                    right: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Theme",
                        style: TextStyle(
                          fontSize: 18,
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Dark Mode",
                            style: TextStyle(
                              fontSize: 15,
                              color: textColor,
                            ),
                          ),
                          Switch(
                            value: _isDarkMode,
                            onChanged: (value) {
                              setState(() {
                                _isDarkMode = value;
                              });
                              Provider.of<ThemeProvider>(
                                context,
                                listen: false,
                              ).toggleTheme(value);
                            },
                            activeColor: buttonColor,
                            inactiveThumbColor: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Container(
                height: MediaQuery.of(context).size.height / 4.3,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [boxShadow],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 12.0,
                    left: 12,
                    right: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Preferences",
                        style: TextStyle(
                          fontSize: 20,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Anime Mode",
                            style: TextStyle(
                              fontSize: 15,
                              color: textColor,
                            ),
                          ),
                          Switch(
                            value: _isAnimeMode,
                            onChanged: (value) {
                              setState(() {
                                _isAnimeMode = value;
                              });
                            },
                            activeColor: buttonColor,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.language),
                              SizedBox(width: 5),
                              Text(
                                "Language",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 140,
                            height: 40,
                            child: DropdownButtonFormField<String>(
                              dropdownColor: cardColor,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: cardColor,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 5.0,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: buttonColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              value: "Option 1",
                              hint: Text(
                                "Select an option",
                                style: TextStyle(fontSize: 12.7),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: "Option 1",
                                  child: Text("English"),
                                ),
                                DropdownMenuItem(
                                  value: "Option 2",
                                  child: Text("French"),
                                ),
                                DropdownMenuItem(
                                  value: "Option 3",
                                  child: Text("Spanish"),
                                ),
                              ],
                              onChanged: (value) {},
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time),
                              SizedBox(width: 5),
                              Text(
                                "Time Zone",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.08,
                          ),
                          SizedBox(
                            width: 70,
                            height: 40,
                            child: DropdownButtonFormField<String>(
                              dropdownColor: cardColor,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: cardColor,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 5.0,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: buttonColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              value: null,
                              hint: Text(
                                "Zone",
                                style: TextStyle(fontSize: 12.7),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: "Option 1",
                                  child: Text("UTC"),
                                ),
                                DropdownMenuItem(
                                  value: "Option 2",
                                  child: Text("CAT"),
                                ),
                                DropdownMenuItem(
                                  value: "Option 3",
                                  child: Text("MAT"),
                                ),
                              ],
                              onChanged: (value) {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Container(
                height: MediaQuery.of(context).size.height / 3.6,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [boxShadow],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 12.0,
                    left: 12,
                    right: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Notifications",
                        style: TextStyle(
                          fontSize: 20,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              FaIcon(FontAwesomeIcons.bell),
                              SizedBox(width: 6),
                              Text(
                                "In App Notifications",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isApp,
                            onChanged: (value) {
                              setState(() {
                                isApp = value;
                              });
                            },
                            activeColor: buttonColor,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              FaIcon(FontAwesomeIcons.bell),
                              SizedBox(width: 5),
                              Text(
                                "Email Notifications",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isEmail,
                            onChanged: (value) {
                              if (value) {
                                _showEmailPreferencesSheet();
                              } else {
                                setState(() {
                                  isEmail = false;
                                });
                              }
                            },
                            activeColor: buttonColor,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              FaIcon(FontAwesomeIcons.bell),
                              SizedBox(width: 5),
                              Text(
                                "System Notifications",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isSystem,
                            onChanged: (value) {
                              setState(() {
                                isSystem = value;
                              });
                            },
                            activeColor: buttonColor,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              FaIcon(FontAwesomeIcons.bell),
                              SizedBox(width: 5),
                              Text(
                                "Popup Notifications",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isPopup,
                            onChanged: (value) {
                              setState(() {
                                isPopup = value;
                              });
                            },
                            activeColor: buttonColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Container(
                height: MediaQuery.of(context).size.height / 5,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [boxShadow],
                ),
                child:Padding(
                  padding: const EdgeInsets.only(
                    top: 12.0,
                    left: 12,
                    right: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star_border_outlined, color: Colors.amber),
                          SizedBox(width: 5),
                          Text(
                            "Premium Plan",
                            style: TextStyle(
                              fontSize: 20,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Padding(
                        padding:const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Current Plan: ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  "Free",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Upgrade to unlock all premium features",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                      Tustom(
                        ontap: () {},
                        data: "Upgrade to Premium",
                        textcolor: Colors.white,
                        backgroundcolor: Colors.amber,
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Container(
                height: MediaQuery.of(context).size.height / 4.3,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [boxShadow],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 12.0,
                    left: 12,
                    right: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Account Settings",
                        style: TextStyle(
                          fontSize: 20,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 5),
                      CustomButton(
                        ontap: changePassword,
                        data: "Change Password",
                        textcolor: Colors.white,
                        backgroundcolor: buttonColor,
                        width: 200,
                        height: 45,
                        icon: Icons.shield_outlined,
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              FaIcon(Icons.shield_outlined),
                              SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Two Factor Authentication",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    "Secure your account with 2FA",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Switch(
                            value: has2FAEnabled,
                            onChanged: (value) {
                              setState(() {
                                has2FAEnabled = value;
                              });
                              if (value) {
                                FamilyModalSheet.show<void>(
                                  context: context,
                                  contentBackgroundColor: cardColor,
                                  builder: (ctx) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Set Up Two-Factor Authentication",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "Follow these steps to secure your account with 2FA:",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: textColor,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "1. Download an authenticator app (e.g., Google Authenticator, Authy).\n"
                                            "2. Scan the QR code below with your app.\n"
                                            "3. Enter the 6-digit verification code generated by the app.\n"
                                            "4. Click Verify & Enable to complete.",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: textColor,
                                            ),
                                          ),
                                          SizedBox(height: 15),
                                          Center(
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(8),
                                                  color: cardColor,
                                                  child: Image.asset(
                                                    "assets/images/qr-code-placeholder.png",
                                                    height: 150,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Icon(
                                                          Icons.qr_code_scanner,
                                                          size: 150,
                                                          color: Colors.grey,
                                                        ),
                                                  ),
                                                ),
                                                SizedBox(height: 15),
                                                TextField(
                                                  maxLength: 6,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    letterSpacing: 3,
                                                    color: textColor,
                                                  ),
                                                  decoration: InputDecoration(
                                                    counterText: "",
                                                    hintText: "------",
                                                    hintStyle: TextStyle(
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontSize: 18,
                                                      letterSpacing: 3,
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.grey[200],
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8.0,
                                                          ),
                                                      borderSide:
                                                          BorderSide.none,
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8.0,
                                                              ),
                                                          borderSide:
                                                              BorderSide(
                                                                color: buttonColor,
                                                                width: 1.5,
                                                              ),
                                                        ),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(ctx);
                                                        setState(() {
                                                          has2FAEnabled = false;
                                                        });
                                                      },
                                                      child: Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(ctx);
                                                      },
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                buttonColor,
                                                            foregroundColor:
                                                                Colors.white,
                                                          ),
                                                      child: Text(
                                                        "Verify & Enable",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              } else {
                                // Add logic to disable 2FA if needed (e.g., show confirmation)
                              }
                            },
                            activeColor: buttonColor,
                            inactiveThumbColor: Colors.grey,
                            inactiveTrackColor: Colors.grey.shade400,
                            activeTrackColor: buttonColor.withOpacity(0.5),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Divider(),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Row(
                                  children: [
                                    Icon(Icons.warning, color: Colors.red),
                                    SizedBox(width: 10),
                                    Text(
                                      "Delete Account",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Text(
                                  "Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textColor,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text("Delete Account"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.trash,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Delete Account",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Container(
                height: MediaQuery.of(context).size.height / 9,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [boxShadow],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 12.0,
                    left: 12,
                    right: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reset",
                        style: TextStyle(
                          fontSize: 20,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Row(
                                      children: [
                                        Icon(
                                          Icons.refresh,
                                          color: buttonColor,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Reset Task Data",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Text(
                                      "This will delete all your tasks, schedules, and progress data. Are you sure you want to proceed? This action cannot be undone.",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textColor,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          setState(() {});
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: buttonColor,
                                        ),
                                        child: Text("Reset Data"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              height: 30,
                              width: 140,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 155, 201, 239),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  "Reset task data",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Row(
                                      children: [
                                        Icon(
                                          Icons.restore,
                                          color: buttonColor,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Restore Defaults",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Text(
                                      "This will reset all your preferences and settings to their default values. Your tasks and user data will not be affected. Would you like to continue?",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textColor,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            _isDarkMode = false;
                                            _isAnimeMode = false;
                                            isApp = false;
                                            isSystem = false;
                                            has2FAEnabled = false;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: buttonColor,
                                        ),
                                        child: Text("Restore Defaults"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              height: 30,
                              width: 140,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 155, 201, 239),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  "Restore defaults",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Tustom(
                ontap: () {},
                data: "LOG OUT",
                textcolor: Colors.white,
  backgroundcolor: const Color(0xFF8B0020), 
                width: MediaQuery.of(context).size.width,
                height: 50,
                
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}
