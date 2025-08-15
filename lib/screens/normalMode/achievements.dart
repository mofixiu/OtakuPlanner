// ignore_for_file: deprecated_member_use, prefer_final_fields, no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/normalMode/otakuPlannerAI.dart';
import 'package:otakuplanner/screens/normalMode/profile.dart';
import 'package:otakuplanner/shared/notifications.dart';
import 'package:otakuplanner/widgets/bottomNavBar.dart';
import 'package:provider/provider.dart';
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
  Map<String, bool> _expandedCategories = {};
  final Set<int> _completedAchievements = {1, 3, 5};
  Map<int, int> _achievementProgress = {};
  final int level = 2;
  @override
  void initState() {
    super.initState();
    _initCategories();
    _initAchievementProgress();
  }

  void _initCategories() {
    final categories = achievementsData.map((a) => a.category).toSet();
    for (final category in categories) {
      _expandedCategories[category] = true;
    }
  }

  void _initAchievementProgress() {
    for (final achievement in achievementsData) {
      if (_completedAchievements.contains(achievement.id)) {
        _achievementProgress[achievement.id] = achievement.totalRequired;
      } else {
        _achievementProgress[achievement.id] =
            (achievement.id % achievement.totalRequired);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void artificialInte() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OtakuPlannerAIPage()),
      );
    }

    void profile() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Profile()),
      );
    }

    void _showNotificationsDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return NotificationDropdown();
        },
      );
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = OtakuPlannerTheme.getCardColor(context);
    final textColor = OtakuPlannerTheme.getTextColor(context);
    final borderColor = OtakuPlannerTheme.getBorderColor(context);
    final buttonColor = OtakuPlannerTheme.getButtonColor(context);

    final profileImagePath =
        Provider.of<UserProvider>(context).profileImagePath;
    final Map<String, List<Achievement>> categorizedAchievements = {};
    for (final achievement in achievementsData) {
      if (!categorizedAchievements.containsKey(achievement.category)) {
        categorizedAchievements[achievement.category] = [];
      }
      categorizedAchievements[achievement.category]!.add(achievement);
    }

    final completedCount = _completedAchievements.length;
    final totalCount = achievementsData.length;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
              onTap: _showNotificationsDialog,
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: NotificationBadge(
                  child: CircleAvatar(
                    backgroundColor: buttonColor,
                    child: FaIcon(
                      FontAwesomeIcons.bell,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: profile,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
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
          padding: const EdgeInsets.only(top: 10.0, left: 16.0, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Achievements",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.16,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 0.4),
                  boxShadow: [OtakuPlannerTheme.getBoxShadow(context)],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "$level",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Level 2: Task Starter",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          "You've unlocked $completedCount of $totalCount achievements ",
                          style: TextStyle(
                            fontSize: 12.2,
                            color: textColor.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          "and earned 150 points",
                          style: TextStyle(
                            fontSize: 12.2,
                            color: textColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFilterTab("All", isSelected: true),
                    _buildFilterTab("Completed"),
                    _buildFilterTab("In Progress"),
                    _buildFilterTab("Locked"),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: categorizedAchievements.length,
                  itemBuilder: (context, index) {
                    final category = categorizedAchievements.keys.elementAt(
                      index,
                    );
                    final achievements = categorizedAchievements[category]!;

                    return _buildCategorySection(
                      context,
                      category,
                      achievements,
                      isDarkMode,
                      cardColor,
                      textColor,
                      borderColor,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: artificialInte,
          backgroundColor: Colors.transparent,
          // elevation: 1,
          child: ClipOval(
            child: Image.asset(
              isDarkMode
                  ? "assets/images/darkai.jpg"
                  : "assets/images/lightai.jpg",
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
        ),

        bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
      ),
    );
  }

  Widget _buildFilterTab(String text, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? OtakuPlannerTheme.accentColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String category,
    List<Achievement> achievements,
    bool isDarkMode,
    Color cardColor,
    Color textColor,
    Color borderColor,
  ) {
    final completedAchievements =
        achievements
            .where((a) => _completedAchievements.contains(a.id))
            .toList();
    final inProgressAchievements =
        achievements
            .where((a) => !_completedAchievements.contains(a.id))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedCategories[category] =
                  !(_expandedCategories[category] ?? true);
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                _getCategoryIcon(category),
                const SizedBox(width: 8),
                Text(
                  "$category Achievements",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                Icon(
                  _expandedCategories[category] ?? true
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: textColor,
                ),
              ],
            ),
          ),
        ),
        if (_expandedCategories[category] ?? true)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (inProgressAchievements.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4, bottom: 8),
                  child: Text(
                    "In Progress",
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ),
              ...inProgressAchievements.map(
                (achievement) => _buildAchievementItem(
                  context,
                  achievement,
                  isDarkMode,
                  cardColor,
                  textColor,
                  borderColor,
                  isCompleted: false,
                ),
              ),
              if (completedAchievements.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 12, bottom: 8),
                  child: Text(
                    "Completed",
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ),
              ...completedAchievements.map(
                (achievement) => _buildAchievementItem(
                  context,
                  achievement,
                  isDarkMode,
                  cardColor,
                  textColor,
                  borderColor,
                  isCompleted: true,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
      ],
    );
  }

  Widget _buildAchievementItem(
    BuildContext context,
    Achievement achievement,
    bool isDarkMode,
    Color cardColor,
    Color textColor,
    Color borderColor, {
    bool isCompleted = false,
  }) {
    final current = _achievementProgress[achievement.id] ?? 0;
    final total = achievement.totalRequired;

    return GestureDetector(
      onTap: () {
        showAchievementDialog(
          context,
          title: achievement.title,
          description: achievement.description,
          icon: achievement.icon,
          current: current,
          total: total,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCompleted ? Colors.green : borderColor,
            width: isCompleted ? 1 : 0.4,
          ),
          // Enhanced elevation with multiple shadows
          boxShadow: [
            BoxShadow(
              color:
                  isDarkMode
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color:
                  isDarkMode
                      ? Colors.black.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        "$current/$total",
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.description,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                          ),
                        ),
                      ),
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "Completed",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: current / total,
                      backgroundColor:
                          isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                      color:
                          isCompleted
                              ? Colors.green
                              : OtakuPlannerTheme.accentColor,
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            if ((achievement.id % 5) == 0)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.thumb_up_alt_outlined,
                  color: Colors.grey.shade500,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String category) {
    switch (category) {
      case 'Tasks':
        return const Icon(Icons.task_alt, color: Colors.blue);
      case 'Categories':
        return const Icon(Icons.category, color: Colors.orange);
      case 'Usage':
        return const Icon(Icons.bar_chart, color: Colors.purple);
      case 'Modes':
        return const Icon(Icons.switch_access_shortcut, color: Colors.indigo);
      case 'Customization':
        return const Icon(Icons.palette, color: Colors.pink);
      case 'Sharing':
        return const Icon(Icons.share, color: Colors.teal);
      case 'Collaboration':
        return const Icon(Icons.people, color: Colors.amber);
      case 'Planning':
        return const Icon(Icons.calendar_today, color: Colors.green);
      case 'Maintenance':
        return const Icon(Icons.cleaning_services, color: Colors.grey);
      case 'Motivation':
        return const Icon(Icons.emoji_emotions, color: Colors.deepOrange);
      case 'Meta':
        return const Icon(Icons.stars, color: Colors.amber);
      default:
        return const Icon(Icons.emoji_events, color: Colors.amber);
    }
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
    builder:
        (context) => Dialog(
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
                  style: TextStyle(fontSize: 16, color: textColor),
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
                      isDarkMode
                          ? Colors.lightBlue
                          : OtakuPlannerTheme.accentColor,
                      isDarkMode
                          ? Colors.lightBlue.shade700
                          : OtakuPlannerTheme.accentColor,
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
