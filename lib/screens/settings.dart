// ignore_for_file: deprecated_member_use
// import 'package:animated_switch/animated_switch.dart';
import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otakuplanner/entryScreens/changePassword.dart';
import 'package:otakuplanner/providers/theme_provider.dart';
import 'package:otakuplanner/screens/profile.dart';
import 'package:otakuplanner/widgets/bottomNavBar.dart';
import 'package:otakuplanner/widgets/customButtonWithAnIcon.dart';
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
  bool has2FAEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/images/otaku.jpg", fit: BoxFit.contain),
        centerTitle: false,
        backgroundColor: Color.fromRGBO(255, 249, 233, 1),
        elevation: 2,
        scrolledUnderElevation: 2,
        title: Text(
          "OtakuPlanner",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: profile,
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: CircleAvatar(child: Icon(Icons.person)),
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
              Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 249, 233, 1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(radius: 50),
                      SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            "User",
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "placeholder@email.com",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1E293B),
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
                height: 92,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 249, 233, 1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
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
                          color: Color(0xFF1E293B),
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
                              color: Color(0xFF1E293B),
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
                            activeColor: Colors.black,
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
                height: MediaQuery.of(context).size.height / 4.45,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 249, 233, 1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
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
                          color: Color(0xFF1E293B),
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
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          
                          Switch(
                            value: _isAnimeMode,
                            onChanged: (value) {
                              setState(() {
                                _isAnimeMode = value;
                              });
                            },
                            activeColor: Color(0xFF1E293B),
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
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 140,
                            height: 40,
                            child: DropdownButtonFormField<String>(
                              dropdownColor: Colors.white,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 5.0,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF1E293B),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              value: "Option 1", // Set a default value like "Option 1" (English)
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
                                  color: Color(0xFF1E293B),
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
                              dropdownColor: Colors.white,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 5.0,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF1E293B),
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
                height: MediaQuery.of(context).size.height / 6,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 249, 233, 1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
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
                          color: Color(0xFF1E293B),
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
                                  color: Color(0xFF1E293B),
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
                            activeColor: Color(0xFF1E293B),
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
                                  color: Color(0xFF1E293B),
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
                            activeColor: Color(0xFF1E293B),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Container(
                height: MediaQuery.of(context).size.height / 4.4,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 249, 233, 1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
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
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 5),
                      CustomButton(
                        ontap: changePassword,
                        data: "Change Password",
                        textcolor: Colors.white,
                        backgroundcolor: Color(0xFF1E293B),
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
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    "Secure your account with 2FA",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF1E293B),
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
                                  contentBackgroundColor: Colors.white,
                                  builder: (ctx) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Set Up Two-Factor Authentication",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "Follow these steps to secure your account with 2FA:",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF1E293B),
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
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          SizedBox(height: 15),
                                          Center(
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(8),
                                                  color: Colors.white,
                                                  child: Image.asset(
                                                    "assets/images/qr-code-placeholder.png",
                                                    height: 150,
                                                    errorBuilder: (context, error, stackTrace) =>
                                                        Icon(Icons.qr_code_scanner, size: 150, color: Colors.grey),
                                                  ),
                                                ),
                                                SizedBox(height: 15),
                                                TextField(
                                                  // keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                                                  maxLength: 6,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    letterSpacing: 3,
                                                    color: Colors.black,
                                                  ),
                                                  decoration: InputDecoration(
                                                    counterText: "",
                                                    hintText: "------",
                                                    hintStyle: TextStyle(
                                                      color: Colors.grey.shade500,
                                                      fontSize: 18,
                                                      letterSpacing: 3,
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.grey[200],
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8.0),
                                                      borderSide: BorderSide.none,
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8.0),
                                                      borderSide: BorderSide(
                                                        color: Color(0xFF1E293B),
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                                        style: TextStyle(color: Colors.grey),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(ctx);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Color(0xFF1E293B),
                                                        foregroundColor: Colors.white,
                                                      ),
                                                      child: Text("Verify & Enable"),
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
                            activeColor: Colors.black,
                            inactiveThumbColor: Colors.grey,
                            inactiveTrackColor: Colors.grey.shade400,
                            activeTrackColor: Colors.black.withOpacity(0.5),
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
                                    color: Color(0xFF1E293B),
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
                  color: Color.fromRGBO(255, 249, 233, 1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
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
                          color: Color(0xFF1E293B),
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
                                          color: Color(0xFF1E293B),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Reset Task Data",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Text(
                                      "This will delete all your tasks, schedules, and progress data. Are you sure you want to proceed? This action cannot be undone.",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1E293B),
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
                                          backgroundColor: Color(0xFF1E293B),
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
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
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
                                          color: Color(0xFF1E293B),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Restore Defaults",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Text(
                                      "This will reset all your preferences and settings to their default values. Your tasks and user data will not be affected. Would you like to continue?",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1E293B),
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
                                          backgroundColor: Color(0xFF1E293B),
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
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
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
              SizedBox(height: MediaQuery.of(context).size.height*0.02),
              CustomButton(ontap: (){}, data: "LOG OUT", textcolor: Colors.white, backgroundcolor: Colors.red, width: MediaQuery.of(context).size.width, height: 50)
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }
}
