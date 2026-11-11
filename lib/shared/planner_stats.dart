import 'package:flutter/material.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/shared/formats.dart';

/// Numbers worked out from the user's own tasks: today's progress, the
/// streak and the badges. Nothing here is stored or made up.
class PlannerStats {
  PlannerStats(Map<DateTime, List<Task>> tasks, {DateTime? now})
      : now = now ?? DateTime.now(),
        _byDay = {
          for (final e in tasks.entries)
            if (e.value.isNotEmpty) PlannerFormat.dateOnly(e.key): e.value,
        };

  final DateTime now;
  final Map<DateTime, List<Task>> _byDay;

  DateTime get today => PlannerFormat.dateOnly(now);

  List<Task> tasksOn(DateTime day) {
    final list = [...?_byDay[PlannerFormat.dateOnly(day)]];
    list.sort((a, b) => PlannerFormat.minutes(a.time).compareTo(PlannerFormat.minutes(b.time)));
    return list;
  }

  List<Task> get todayTasks => tasksOn(today);
  int get todayDone => todayTasks.where((t) => t.isChecked).length;

  /// The first unfinished task today that hasn't started yet, if any.
  Task? get nextToday {
    final nowMinutes = now.hour * 60 + now.minute;
    for (final t in todayTasks) {
      if (!t.isChecked && PlannerFormat.minutes(t.time) >= nowMinutes) return t;
    }
    return null;
  }

  bool _doneOn(DateTime day) => (_byDay[day] ?? const []).any((t) => t.isChecked);

  /// Days in a row, up to today, with at least one finished task. A streak
  /// that ran until yesterday still counts until today is over.
  int get currentStreak {
    var day = today;
    if (!_doneOn(day)) day = day.subtract(const Duration(days: 1));
    var count = 0;
    while (_doneOn(day)) {
      count++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return count;
  }

  /// The longest run of days with a finished task.
  int get bestStreak {
    final days = _byDay.keys.where(_doneOn).toList()..sort();
    var best = 0, run = 0;
    DateTime? previous;
    for (final d in days) {
      final follows =
          previous != null && DateTime(previous.year, previous.month, previous.day + 1) == d;
      run = follows ? run + 1 : 1;
      if (run > best) best = run;
      previous = d;
    }
    return best;
  }

  Iterable<Task> get _all {
    // Recurring tasks are stored once per date; each date counts once.
    return _byDay.values.expand((l) => l);
  }

  int get completedTotal => _all.where((t) => t.isChecked).length;

  int completedIn(String category) => _all
      .where((t) => t.isChecked && t.category.toLowerCase() == category.toLowerCase())
      .length;

  int get categoriesFinished =>
      _all.where((t) => t.isChecked).map((t) => t.category.toLowerCase()).toSet().length;

  int get weekendDone => _byDay.entries
      .where((e) => e.key.weekday == DateTime.saturday || e.key.weekday == DateTime.sunday)
      .expand((e) => e.value)
      .where((t) => t.isChecked)
      .length;

  int completedWhere(bool Function(TimeOfDay t) test) => _all.where((t) {
        if (!t.isChecked) return false;
        final time = PlannerFormat.parseTime(t.time);
        return time != null && test(time);
      }).length;

  /// Days with at least three tasks where every one was finished.
  int get cleanSweeps => _byDay.values
      .where((l) => l.length >= 3 && l.every((t) => t.isChecked))
      .length;

  /// Different days from today on that already have something planned.
  int get daysPlannedAhead => _byDay.keys.where((d) => !d.isBefore(today)).length;

  List<BadgeProgress> get badges =>
      [for (final b in PlannerBadge.all) BadgeProgress(b, b.measure(this).clamp(0, b.goal))];

  int get badgesEarned => badges.where((b) => b.earned).length;
}

class PlannerBadge {
  const PlannerBadge({
    required this.title,
    required this.description,
    required this.icon,
    required this.group,
    required this.goal,
    required this.measure,
  });

  final String title;
  final String description;
  final IconData icon;
  final String group;
  final int goal;
  final int Function(PlannerStats s) measure;

  static final List<PlannerBadge> all = [
    PlannerBadge(
      title: 'First Step',
      description: 'Finish your first task',
      icon: Icons.flag_outlined,
      group: 'Tasks',
      goal: 1,
      measure: (s) => s.completedTotal,
    ),
    PlannerBadge(
      title: 'On a Roll',
      description: 'Finish 10 tasks',
      icon: Icons.done_all,
      group: 'Tasks',
      goal: 10,
      measure: (s) => s.completedTotal,
    ),
    PlannerBadge(
      title: 'Task Master',
      description: 'Finish 50 tasks',
      icon: Icons.military_tech_outlined,
      group: 'Tasks',
      goal: 50,
      measure: (s) => s.completedTotal,
    ),
    PlannerBadge(
      title: 'Clean Sweep',
      description: 'Finish every task on a day with 3 or more',
      icon: Icons.cleaning_services_outlined,
      group: 'Tasks',
      goal: 1,
      measure: (s) => s.cleanSweeps,
    ),
    PlannerBadge(
      title: 'Pilot Episode',
      description: 'Keep a 3-day streak',
      icon: Icons.local_fire_department_outlined,
      group: 'Streaks',
      goal: 3,
      measure: (s) => s.bestStreak,
    ),
    PlannerBadge(
      title: 'Full Week',
      description: 'Keep a 7-day streak',
      icon: Icons.date_range_outlined,
      group: 'Streaks',
      goal: 7,
      measure: (s) => s.bestStreak,
    ),
    PlannerBadge(
      title: 'Season Arc',
      description: 'Keep a 30-day streak',
      icon: Icons.auto_stories_outlined,
      group: 'Streaks',
      goal: 30,
      measure: (s) => s.bestStreak,
    ),
    PlannerBadge(
      title: 'Binge Watcher',
      description: 'Finish 5 Anime tasks',
      icon: Icons.live_tv_outlined,
      group: 'Categories',
      goal: 5,
      measure: (s) => s.completedIn('Anime'),
    ),
    PlannerBadge(
      title: 'Page Turner',
      description: 'Finish 5 Manga tasks',
      icon: Icons.menu_book_outlined,
      group: 'Categories',
      goal: 5,
      measure: (s) => s.completedIn('Manga'),
    ),
    PlannerBadge(
      title: 'Bookworm',
      description: 'Finish 5 Study tasks',
      icon: Icons.school_outlined,
      group: 'Categories',
      goal: 5,
      measure: (s) => s.completedIn('Study'),
    ),
    PlannerBadge(
      title: 'Workhorse',
      description: 'Finish 5 Work tasks',
      icon: Icons.work_outline,
      group: 'Categories',
      goal: 5,
      measure: (s) => s.completedIn('Work'),
    ),
    PlannerBadge(
      title: 'Player One',
      description: 'Finish 5 Gaming tasks',
      icon: Icons.sports_esports_outlined,
      group: 'Categories',
      goal: 5,
      measure: (s) => s.completedIn('Gaming'),
    ),
    PlannerBadge(
      title: 'All-Rounder',
      description: 'Finish tasks in 4 different categories',
      icon: Icons.category_outlined,
      group: 'Categories',
      goal: 4,
      measure: (s) => s.categoriesFinished,
    ),
    PlannerBadge(
      title: 'Early Bird',
      description: 'Finish 3 tasks set before 7 AM',
      icon: Icons.wb_twilight_outlined,
      group: 'Habits',
      goal: 3,
      measure: (s) => s.completedWhere((t) => t.hour < 7),
    ),
    PlannerBadge(
      title: 'Night Owl',
      description: 'Finish 3 tasks set after 10 PM',
      icon: Icons.nightlight_outlined,
      group: 'Habits',
      goal: 3,
      measure: (s) => s.completedWhere((t) => t.hour >= 22),
    ),
    PlannerBadge(
      title: 'Weekend Warrior',
      description: 'Finish 5 tasks on weekends',
      icon: Icons.weekend_outlined,
      group: 'Habits',
      goal: 5,
      measure: (s) => s.weekendDone,
    ),
    PlannerBadge(
      title: 'Planner Pro',
      description: 'Have tasks planned on 5 days ahead',
      icon: Icons.event_note_outlined,
      group: 'Habits',
      goal: 5,
      measure: (s) => s.daysPlannedAhead,
    ),
  ];
}

class BadgeProgress {
  const BadgeProgress(this.badge, this.current);
  final PlannerBadge badge;
  final int current;

  bool get earned => current >= badge.goal;
  bool get started => current > 0;
  double get fraction => badge.goal == 0 ? 1 : current / badge.goal;
}
