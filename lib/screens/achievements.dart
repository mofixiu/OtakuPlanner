// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:otakuplanner/widgets/bottomNavBar.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:otakuplanner/themes/theme.dart';

class Achievement {
  final int id;
  final String title;
  final String description;
  final String icon;
  final String category;
  final int totalRequired;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.totalRequired,
  });
}

const List<Achievement> achievementsData = [
  Achievement(
    id: 1,
    title: "Getting Started",
    description: "Complete 1 task",
    icon: "🥉",
    category: "Tasks",
    totalRequired: 1,
  ),
  Achievement(
    id: 2,
    title: "On a Roll",
    description: "Complete 10 tasks",
    icon: "🥈",
    category: "Tasks",
    totalRequired: 10,
  ),
  Achievement(
    id: 3,
    title: "Task Master",
    description: "Complete 50 tasks",
    icon: "🥇",
    category: "Tasks",
    totalRequired: 50,
  ),
  Achievement(
    id: 4,
    title: "Workaholic",
    description: "Complete 5 work tasks",
    icon: "💼",
    category: "Categories",
    totalRequired: 5,
  ),
  Achievement(
    id: 5,
    title: "Bookworm",
    description: "Complete 5 study tasks",
    icon: "📘",
    category: "Categories",
    totalRequired: 5,
  ),
  Achievement(
    id: 6,
    title: "Self-Care Guru",
    description: "Complete 5 personal tasks",
    icon: "💚",
    category: "Categories",
    totalRequired: 5,
  ),
  Achievement(
    id: 7,
    title: "Health Freak",
    description: "Complete 5 health tasks",
    icon: "🍎",
    category: "Categories",
    totalRequired: 5,
  ),
  Achievement(
    id: 8,
    title: "Habit Builder",
    description: "Use the app 3 days in a row",
    icon: "📅",
    category: "Usage",
    totalRequired: 3,
  ),
  Achievement(
    id: 9,
    title: "Streak Starter",
    description: "Use the app 7 days in a row",
    icon: "🔥",
    category: "Usage",
    totalRequired: 7,
  ),
  Achievement(
    id: 10,
    title: "Month Master",
    description: "Use the app every day for a month",
    icon: "🗓",
    category: "Usage",
    totalRequired: 30,
  ),
  Achievement(
    id: 11,
    title: "Dimension Hopper",
    description: "Switch between Normal and Anime Mode",
    icon: "🌀",
    category: "Modes",
    totalRequired: 1,
  ),
  Achievement(
    id: 12,
    title: "Customizer",
    description: "Change your character or theme",
    icon: "🎨",
    category: "Customization",
    totalRequired: 1,
  ),
  Achievement(
    id: 13,
    title: "Daily Routine",
    description: "Complete 3 daily tasks",
    icon: "☀️",
    category: "Tasks",
    totalRequired: 3,
  ),
  Achievement(
    id: 14,
    title: "Weekend Warrior",
    description: "Complete 5 tasks on a weekend",
    icon: "🎯",
    category: "Tasks",
    totalRequired: 5,
  ),
  Achievement(
    id: 15,
    title: "All-Rounder",
    description: "Complete tasks in all categories",
    icon: "🧭",
    category: "Categories",
    totalRequired: 5,
  ),
  Achievement(
    id: 16,
    title: "Fast Starter",
    description: "Complete a task 5 minutes after creation",
    icon: "⚡️",
    category: "Tasks",
    totalRequired: 1,
  ),
  Achievement(
    id: 17,
    title: "Night Owl",
    description: "Complete a task between 12 AM and 5 AM",
    icon: "🌙",
    category: "Tasks",
    totalRequired: 1,
  ),
  Achievement(
    id: 18,
    title: "Early Bird",
    description: "Complete a task before 7 AM",
    icon: "🌄",
    category: "Tasks",
    totalRequired: 1,
  ),
  Achievement(
    id: 19,
    title: "Motivator",
    description: "Set up daily quote notifications",
    icon: "🗣",
    category: "Customization",
    totalRequired: 1,
  ),
  Achievement(
    id: 20,
    title: "Reflector",
    description: "Review tasks at the end of the day",
    icon: "📝",
    category: "Usage",
    totalRequired: 1,
  ),
  Achievement(
    id: 21,
    title: "Social Butterfly",
    description: "Share your profile or tasks",
    icon: "📤",
    category: "Sharing",
    totalRequired: 1,
  ),
  Achievement(
    id: 22,
    title: "Collaborator",
    description: "Join a multiplayer task group",
    icon: "🤝",
    category: "Collaboration",
    totalRequired: 1,
  ),
  Achievement(
    id: 23,
    title: "Planner Pro",
    description: "Plan your week using the calendar",
    icon: "🗂",
    category: "Planning",
    totalRequired: 1,
  ),
  Achievement(
    id: 24,
    title: "Milestone Marker",
    description: "Mark 5 tasks as important",
    icon: "📌",
    category: "Tasks",
    totalRequired: 5,
  ),
  Achievement(
    id: 25,
    title: "Time Manager",
    description: "Use timers for 10 tasks",
    icon: "⏱️",
    category: "Usage",
    totalRequired: 10,
  ),
  Achievement(
    id: 26,
    title: "Clean Slate",
    description: "Delete 5 completed tasks",
    icon: "🗑",
    category: "Maintenance",
    totalRequired: 5,
  ),
  Achievement(
    id: 27,
    title: "Reminded",
    description: "Set reminders for 10 tasks",
    icon: "🔔",
    category: "Usage",
    totalRequired: 10,
  ),
  Achievement(
    id: 28,
    title: "Goal Getter",
    description: "Complete all tasks in a day",
    icon: "🏁",
    category: "Tasks",
    totalRequired: 1,
  ),
  Achievement(
    id: 29,
    title: "Motivated Mindset",
    description: "Check in with a quote 5 times",
    icon: "💬",
    category: "Motivation",
    totalRequired: 5,
  ),
  Achievement(
    id: 30,
    title: "Achievement Unlocked!",
    description: "Unlock 10 achievements",
    icon: "🏆",
    category: "Meta",
    totalRequired: 10,
  ),
];

class Achievements extends StatefulWidget {
  const Achievements({super.key});

  @override
  State<Achievements> createState() => _AchievementsState();
}

class _AchievementsState extends State<Achievements> {
  final int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = OtakuPlannerTheme.getCardColor(context);
    final textColor = OtakuPlannerTheme.getTextColor(context);
    final borderColor = OtakuPlannerTheme.getBorderColor(context);
    // final buttonColor = OtakuPlannerTheme.getButtonColor(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16),
          child: Column(
            children: [
              Text(
                "Achievements",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: achievementsData.length,
                  itemBuilder: (context, index) {
                    final achievement = achievementsData[index];
                    return GestureDetector(
                      onTap: () {
                        showAchievementDialog(
                          context,
                          title: achievement.title,
                          description: achievement.description,
                          icon: achievement.icon,
                          current: 0,
                          total: achievement.totalRequired,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: borderColor,
                            width: 0.4,
                          ),
                          boxShadow: [OtakuPlannerTheme.getBoxShadow(context)],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Text(
                                achievement.icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  achievement.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  achievement.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
      ),
    );
  }
}

void showAchievementDialog(
  BuildContext context, {
  required String title,
  required String description,
  required String icon,
  required int current,
  required int total,
}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final cardColor = OtakuPlannerTheme.getCardColor(context);
  final textColor = OtakuPlannerTheme.getTextColor(context);
  final buttonColor = OtakuPlannerTheme.getButtonColor(context);

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            StepProgressIndicator(
              totalSteps: total,
              currentStep: current,
              size: 8,
              padding: 0,
              roundedEdges: const Radius.circular(10),
              selectedGradientColor: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDarkMode ? Colors.lightBlue : OtakuPlannerTheme.accentColor,
                  isDarkMode ? Colors.lightBlue.shade700 : OtakuPlannerTheme.accentColor,
                ],
              ),
              unselectedGradientColor: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  isDarkMode ? Colors.grey.shade600 : Colors.grey.shade200,
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "$current/$total tasks complete",
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              current >= total ? "Completed" : "In Progress",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: current >= total ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: isDarkMode ? Colors.white : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("Close"),
            ),
          ],
        ),
      ),
    ),
  );
}
