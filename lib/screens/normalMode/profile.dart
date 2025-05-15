import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:intl/intl.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/normalMode/editProfile.dart';
import 'package:otakuplanner/themes/theme.dart'; // Add theme import
import 'package:otakuplanner/widgets/customButtonwithSmallerTextandanIcon.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  void editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfile()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileImagePath = Provider.of<UserProvider>(context).profileImagePath;

    // Get theme-specific colors
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = OtakuPlannerTheme.getCardColor(context);
    final textColor = OtakuPlannerTheme.getTextColor(context);
    // final borderColor = OtakuPlannerTheme.getBorderColor(context);
    final buttonColor = OtakuPlannerTheme.getButtonColor(context);
    final boxShadow = OtakuPlannerTheme.getBoxShadow(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 30.0, right: 30),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Container(
                height: MediaQuery.of(context).size.height / 3.5,
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'User Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          CustomButton(
                            ontap: editProfile,
                            data: "Edit Profile",
                            textcolor: Colors.white,
                            backgroundcolor: buttonColor,
                            width: 100,
                            height: 30,
                            icon: Icons.edit,
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 40,
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
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.025,
                      ),
                      Text(
                        "Full Name",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005,
                      ),
                      Text(
                        'User Name Placeholder',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.015,
                      ),
                      Text(
                        "Email Address",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005,
                      ),
                      Text(
                        'user@email.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              Container(
                height: MediaQuery.of(context).size.height / 4,
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
                    children: [
                      Text(
                        'Account Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.016,
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isDarkMode ? Colors.blueGrey.shade700 : const Color.fromARGB(255, 132, 190, 237),
                            child: FaIcon(
                              FontAwesomeIcons.person,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Username',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor.withOpacity(0.6),
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                '@user',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isDarkMode ? Colors.green.shade900 : const Color.fromARGB(255, 99, 186, 101),
                            child: FaIcon(
                              FontAwesomeIcons.calendar,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Join Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor.withOpacity(0.6),
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                'DD-MM-YYYY',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                            child: FaIcon(
                              FontAwesomeIcons.listCheck,
                              color: isDarkMode ? Colors.white : Colors.black54,
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Completed Tasks',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor.withOpacity(0.6),
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                '4',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              Container(
                height: MediaQuery.of(context).size.height / 3,
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
                    children: [
                      Text(
                        'Activity Snapshot',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.016),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isDarkMode ? Colors.orange.shade900 : const Color.fromARGB(255, 223, 157, 59),
                            child: FaIcon(
                              FontAwesomeIcons.arrowTrendUp,
                              color: const Color.fromARGB(255, 168, 124, 56),
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Longest Streak',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor.withOpacity(0.6),
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                'X Days',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isDarkMode ? Colors.purple.shade900 : const Color.fromARGB(255, 244, 179, 241),
                            child: FaIcon(
                              FontAwesomeIcons.chartBar,
                              color: Colors.purple,
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Most Productive Day',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor.withOpacity(0.6),
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                'TestDay',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isDarkMode ? Colors.pink.shade900 : const Color.fromARGB(255, 239, 187, 204),
                            child: FaIcon(
                              FontAwesomeIcons.tag,
                              color: Colors.pink,
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Top Categories',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor.withOpacity(0.6),
                                ),
                              ),
                              SizedBox(height: 1),
                              Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? Colors.blueGrey.shade700 : const Color.fromARGB(255, 155, 201, 239),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Work",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Container(
                                    height: 20,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? Colors.blueGrey.shade700 : const Color.fromARGB(255, 155, 201, 239),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Study",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Container(
                                    height: 20,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? Colors.blueGrey.shade700 : const Color.fromARGB(255, 155, 201, 239),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Personal",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isDarkMode ? Colors.yellow.shade900 : Colors.yellow.withOpacity(0.2),
                            child: FaIcon(
                              FontAwesomeIcons.tag,
                              color: const Color.fromARGB(255, 131, 121, 33),
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Achievements Unlocked',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor.withOpacity(0.6),
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                '12/30',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
