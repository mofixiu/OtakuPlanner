import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otakuplanner/screens/normalMode/achievements.dart';
import 'package:otakuplanner/screens/normalMode/calendar.dart';
import 'package:otakuplanner/screens/normalMode/dashboard.dart';
import 'package:otakuplanner/screens/normalMode/settings.dart';
import 'package:otakuplanner/screens/normalMode/tasks.dart';
import 'package:otakuplanner/themes/theme.dart'; // Add this import

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return; 

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const Dashboard();
        break;
      case 1:
        nextPage = const Calendar();
        break;
      case 2:
        nextPage = const Tasks();
        break;
      case 3:
        nextPage = const Achievements();
        break;
      case 4:
        nextPage = const Settings();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get theme-aware colors
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode 
        ? OtakuPlannerTheme.darkCardBackground 
        : OtakuPlannerTheme.lightCardBackground;
    final selectedItemColor = isDarkMode ? Colors.lightBlue : Colors.red;
    final unselectedItemColor = OtakuPlannerTheme.getTextColor(context);
    
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _navigate(context, index),
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendar"),
        BottomNavigationBarItem(icon: Icon(Icons.task_sharp), label: "Tasks"),
        BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.trophy), label: "Achievements"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}
