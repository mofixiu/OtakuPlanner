import 'package:flutter/material.dart' show TimeOfDay;
import 'package:intl/intl.dart';

/// One way to write dates and times everywhere: "Sat 1 Nov · 4:20 PM".
///
/// Task times arrive in several shapes ("16:20" from the database,
/// "4:20 PM" from the pickers, and older rows like "16:20 AM"), so every
/// screen reads them through [parseTime] instead of guessing.
class PlannerFormat {
  PlannerFormat._();

  static final _day = DateFormat('EEE d MMM');
  static final _dayLong = DateFormat('EEEE d MMMM');

  /// "Sat 1 Nov"
  static String day(DateTime date) => _day.format(date);

  /// "Saturday 1 November"
  static String dayLong(DateTime date) => _dayLong.format(date);

  /// "4:20 PM"
  static String clock(int hour, int minute) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h:${minute.toString().padLeft(2, '0')} ${hour < 12 ? 'AM' : 'PM'}';
  }

  /// Any stored time as "4:20 PM". Text that isn't a time comes back as is.
  static String time(String raw) {
    final t = parseTime(raw);
    return t == null ? raw.trim() : clock(t.hour, t.minute);
  }

  /// "Sat 1 Nov · 4:20 PM"
  static String dayTime(DateTime date, String rawTime) {
    final t = time(rawTime);
    return t.isEmpty ? day(date) : '${day(date)} · $t';
  }

  /// The uppercase label for a day: "TODAY · SAT 1 NOV", "TOMORROW · SUN 2 NOV"
  /// or just "MON 3 NOV".
  static String kickerDay(DateTime date, {DateTime? now}) {
    final rel = relativeDay(date, now: now);
    final d = day(date).toUpperCase();
    return rel == null ? d : '${rel.toUpperCase()} · $d';
  }

  /// "Today", "Tomorrow", "Yesterday" or null.
  static String? relativeDay(DateTime date, {DateTime? now}) {
    final today = dateOnly(now ?? DateTime.now());
    final diff = dateOnly(date).difference(today).inDays;
    return switch (diff) {
      0 => 'Today',
      1 => 'Tomorrow',
      -1 => 'Yesterday',
      _ => null,
    };
  }

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static final _clock = RegExp(
    r'^\s*(\d{1,2})(?:[:.](\d{2}))?(?::\d{2})?\s*([ap])?\.?\s*m?\.?\s*$',
    caseSensitive: false,
  );

  /// Reads "16:20", "4:20 PM", "4:20pm", "4 PM", "16:20:00" and the older
  /// "16:20 AM" (an hour past 12 is already 24-hour, so the AM is ignored).
  static TimeOfDay? parseTime(String raw) {
    final m = _clock.firstMatch(raw);
    if (m == null) return null;
    var hour = int.parse(m[1]!);
    final minute = m[2] == null ? 0 : int.parse(m[2]!);
    final period = m[3]?.toLowerCase();
    if (minute > 59 || hour > 23) return null;
    if (period == null && m[2] == null) return null; // a bare number isn't a time
    if (period != null && hour >= 1 && hour <= 12) {
      hour = hour % 12 + (period == 'p' ? 12 : 0);
    } else if (period != null && hour == 0) {
      hour = 0;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// "16:20", the way the database stores times.
  static String to24(String raw) {
    final t = parseTime(raw);
    if (t == null) return raw.trim();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  /// Minutes after midnight, for sorting. Unreadable times sort last.
  static int minutes(String raw) {
    final t = parseTime(raw);
    return t == null ? 24 * 60 : t.hour * 60 + t.minute;
  }

  /// Morning (5:00–11:59), afternoon (12:00–17:59) or night (the rest).
  static DayPart dayPart(String raw) {
    final t = parseTime(raw);
    final hour = t?.hour ?? 12;
    if (hour >= 5 && hour < 12) return DayPart.morning;
    if (hour >= 12 && hour < 18) return DayPart.afternoon;
    return DayPart.night;
  }

  /// "Good morning", "Good afternoon" or "Good evening".
  static String greeting(DateTime now) {
    if (now.hour >= 5 && now.hour < 12) return 'Good morning';
    if (now.hour >= 12 && now.hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

enum DayPart {
  morning('Morning'),
  afternoon('Afternoon'),
  night('Night');

  const DayPart(this.label);
  final String label;
}
