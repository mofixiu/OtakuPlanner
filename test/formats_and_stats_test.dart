import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/shared/formats.dart';
import 'package:otakuplanner/shared/planner_stats.dart';

Task task(String title, {String time = '10:00', bool done = false, String category = 'Work'}) => Task(
      title: title,
      category: category,
      time: time,
      date: '',
      color: Colors.black,
      isChecked: done,
    );

void main() {
  group('one time format', () {
    test('reads database, picker and older times the same way', () {
      expect(PlannerFormat.time('16:20'), '4:20 PM');
      expect(PlannerFormat.time('4:20 PM'), '4:20 PM');
      expect(PlannerFormat.time('4:20pm'), '4:20 PM');
      expect(PlannerFormat.time('16:20:00'), '4:20 PM');
      expect(PlannerFormat.time('12:05 AM'), '12:05 AM');
      expect(PlannerFormat.time('12:05'), '12:05 PM');
      expect(PlannerFormat.time('0:30'), '12:30 AM');
    });

    test('"16:20 AM" from older rows is 4:20 PM, not a broken time', () {
      expect(PlannerFormat.time('16:20 AM'), '4:20 PM');
      expect(PlannerFormat.to24('16:20 AM'), '16:20');
    });

    test('stores 24-hour times for the database', () {
      expect(PlannerFormat.to24('4:20 PM'), '16:20');
      expect(PlannerFormat.to24('7 am'), '07:00');
      expect(PlannerFormat.to24('12:00 AM'), '00:00');
    });

    test('text that is not a time is left alone', () {
      expect(PlannerFormat.parseTime('soon'), isNull);
      expect(PlannerFormat.parseTime('25:00'), isNull);
      expect(PlannerFormat.parseTime('7'), isNull);
      expect(PlannerFormat.time('soon'), 'soon');
    });

    test('dates read "Sat 1 Nov · 4:20 PM"', () {
      final sat = DateTime(2025, 11, 1);
      expect(PlannerFormat.dayTime(sat, '16:20'), 'Sat 1 Nov · 4:20 PM');
      expect(PlannerFormat.kickerDay(sat, now: sat), 'TODAY · SAT 1 NOV');
      expect(PlannerFormat.kickerDay(sat, now: DateTime(2025, 10, 31)), 'TOMORROW · SAT 1 NOV');
      expect(PlannerFormat.kickerDay(sat, now: DateTime(2025, 10, 20)), 'SAT 1 NOV');
    });

    test('morning, afternoon and night', () {
      expect(PlannerFormat.dayPart('6:30 AM'), DayPart.morning);
      expect(PlannerFormat.dayPart('13:00'), DayPart.afternoon);
      expect(PlannerFormat.dayPart('9:30 PM'), DayPart.night);
      expect(PlannerFormat.dayPart('2:00 AM'), DayPart.night);
    });
  });

  group('streak', () {
    final now = DateTime(2026, 11, 11, 15);
    DateTime day(int offset) => DateTime(2026, 11, 11 + offset);

    test('counts days in a row with a finished task, up to today', () {
      final stats = PlannerStats({
        day(0): [task('a', done: true), task('b')],
        day(-1): [task('c', done: true)],
        day(-2): [task('d', done: true)],
        day(-4): [task('e', done: true)],
      }, now: now);
      expect(stats.currentStreak, 3);
      expect(stats.bestStreak, 3);
    });

    test('a streak that ran to yesterday is still alive today', () {
      final stats = PlannerStats({
        day(0): [task('a')],
        day(-1): [task('b', done: true)],
        day(-2): [task('c', done: true)],
      }, now: now);
      expect(stats.currentStreak, 2);
    });

    test('a missed day ends it', () {
      final stats = PlannerStats({
        day(-2): [task('a', done: true)],
        day(-3): [task('b', done: true)],
      }, now: now);
      expect(stats.currentStreak, 0);
      expect(stats.bestStreak, 2);
    });

    test('today, the next task and badges come from the same tasks', () {
      final stats = PlannerStats({
        day(0): [
          task('late', time: '21:00'),
          task('early', time: '06:30', done: true, category: 'Anime'),
          task('next', time: '17:00'),
        ],
      }, now: now);
      expect(stats.todayTasks.map((t) => t.title), ['early', 'next', 'late']);
      expect(stats.todayDone, 1);
      expect(stats.nextToday?.title, 'next');
      expect(stats.completedIn('anime'), 1);
      final first = stats.badges.firstWhere((b) => b.badge.title == 'First Step');
      expect(first.earned, isTrue);
    });
  });
}
