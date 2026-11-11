/// Reads a task typed in plain English, such as "Watch anime every Monday at
/// 8pm" or "Revise for the exam tomorrow at 17:30".
library;

enum Recurrence { none, daily, weekly }

class ParsedTask {
  const ParsedTask({
    required this.title,
    required this.category,
    this.weekday,
    this.date,
    this.hour,
    this.minute = 0,
    this.recurrence = Recurrence.none,
  });

  /// What is left once the day, time and repeat words are taken out.
  final String title;
  final String category;

  /// [DateTime.monday] to [DateTime.sunday], when a day was named.
  final int? weekday;

  /// Set for "today", "tonight" and "tomorrow".
  final DateTime? date;

  /// 0–23, or null when no time was found.
  final int? hour;
  final int minute;
  final Recurrence recurrence;

  bool get hasTime => hour != null;
  bool get isRecurring => recurrence != Recurrence.none;

  /// "8:00 PM", the format the rest of the app stores.
  String get time12 {
    if (hour == null) return '';
    final h = hour! % 12 == 0 ? 12 : hour! % 12;
    return '$h:${minute.toString().padLeft(2, '0')} ${hour! < 12 ? 'AM' : 'PM'}';
  }

  String get dayName => weekday == null ? '' : _dayNames[weekday! - 1];

  /// The shape the task automation screen already reads.
  Map<String, dynamic> toMap() => {
        'title': title,
        'day': dayName,
        'time': time12,
        'isRecurring': isRecurring,
        'frequency': recurrence == Recurrence.daily ? 'daily' : 'weekly',
        'category': category,
        'specificDate': date,
      };
}

const _dayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// Day words to weekday numbers. "sat" and "sun" are only read after "on",
/// "every", "next" or "this", so "watch the sun set" stays a title.
final _dayPattern = RegExp(
  r'\b(?:(?:on|every|next|this)\s+)?(mon(?:day)?s?|tue(?:s(?:day)?)?s?|wed(?:s|nesday)?s?|thu(?:r(?:s(?:day)?)?)?s?|fri(?:day)?s?|saturdays?|sundays?)\b\.?'
  r'|\b(?:on|every|next|this)\s+(sat|sun)\b\.?',
  caseSensitive: false,
);

final _relativeDay = RegExp(r'\b(today|tonight|tomorrow|tmrw|tmr)\b', caseSensitive: false);

final _daily = RegExp(
  r'\b(?:every\s*day|every\s+(?:morning|evening|night|weekday)|daily|nightly)\b',
  caseSensitive: false,
);
final _weekly = RegExp(r'\b(?:every\s+week|weekly)\b', caseSensitive: false);
final _every = RegExp(r'\bevery\b', caseSensitive: false);

/// The little word before a time ("at 8pm", "by 5pm") goes with it, so it
/// doesn't stay behind in the title.
const _timeLead = r'(?:(?:at|by|before|around|from|until|till)\s+)?';

/// "8pm", "8 pm", "8:30pm", "8.30 p.m."
final _time12 = RegExp(
  '\\b$_timeLead' r'(\d{1,2})(?:[:.](\d{2}))?\s*([ap])\.?m\b\.?',
  caseSensitive: false,
);

/// "17:30", "08:00"
final _time24 = RegExp('\\b$_timeLead' r'([01]?\d|2[0-3]):([0-5]\d)\b', caseSensitive: false);
final _noon = RegExp('\\b$_timeLead' r'(noon|midday|midnight)\b', caseSensitive: false);

/// Checked in order; the first category with a whole-word hit wins.
const _categories = {
  'Anime': ['anime', 'episode', 'episodes', 'ep', 'season', 'crunchyroll'],
  'Manga': ['manga', 'chapter', 'chapters', 'manhwa', 'webtoon'],
  'Gaming': ['game', 'games', 'gaming', 'play', 'ranked', 'stream'],
  'Study': ['study', 'studying', 'revise', 'revision', 'exam', 'homework', 'assignment', 'lecture', 'class'],
  'Work': ['work', 'meeting', 'office', 'shift', 'standup', 'client'],
  'Personal': ['personal', 'call', 'gym', 'workout', 'laundry', 'groceries', 'birthday'],
};

ParsedTask parseTaskText(String text, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final spans = <(int, int)>[];
  void take(Match m) => spans.add((m.start, m.end));

  // Time. A 12-hour time must have a real hour; "13pm" is not read.
  int? hour;
  var minute = 0;
  final t12 = _time12.allMatches(text).where((m) {
    final h = int.parse(m[1]!);
    final min = m[2] == null ? 0 : int.parse(m[2]!);
    return h >= 1 && h <= 12 && min < 60;
  }).firstOrNull;
  if (t12 != null) {
    final h = int.parse(t12[1]!);
    minute = t12[2] == null ? 0 : int.parse(t12[2]!);
    final pm = t12[3]!.toLowerCase() == 'p';
    hour = (h % 12) + (pm ? 12 : 0);
    take(t12);
  } else if (_time24.firstMatch(text) case final m?) {
    hour = int.parse(m[1]!);
    minute = int.parse(m[2]!);
    take(m);
  } else if (_noon.firstMatch(text) case final m?) {
    hour = m[1]!.toLowerCase() == 'midnight' ? 0 : 12;
    take(m);
  }

  // Repeats.
  var recurrence = Recurrence.none;
  if (_daily.firstMatch(text) case final m?) {
    recurrence = Recurrence.daily;
    take(m);
  } else if (_weekly.firstMatch(text) case final m?) {
    recurrence = Recurrence.weekly;
    take(m);
  }

  // Day of the week. "every Monday" and "Mondays" repeat weekly.
  int? weekday;
  final day = _dayPattern.firstMatch(text);
  if (day != null) {
    final word = (day[1] ?? day[2])!.toLowerCase();
    weekday = _weekdayFor(word);
    final every = day[0]!.toLowerCase().startsWith('every');
    final plural = word.endsWith('days'); // "Mondays"
    if (recurrence == Recurrence.none && (every || plural)) recurrence = Recurrence.weekly;
    take(day);
  }

  // Today or tomorrow.
  DateTime? date;
  final relative = _relativeDay.firstMatch(text);
  if (relative != null) {
    final word = relative[1]!.toLowerCase();
    final base = DateTime(today.year, today.month, today.day);
    final isTomorrow = word == 'tomorrow' || word == 'tmrw' || word == 'tmr';
    date = isTomorrow ? base.add(const Duration(days: 1)) : base;
    weekday ??= date.weekday;
    take(relative);
  }

  // A weekly task with no day repeats on today's weekday.
  if (recurrence == Recurrence.weekly && weekday == null) weekday = today.weekday;

  // A stray "every" ("every other week") still means it repeats.
  if (recurrence == Recurrence.none && _every.hasMatch(text)) {
    recurrence = Recurrence.weekly;
    weekday ??= today.weekday;
    take(_every.firstMatch(text)!);
  }

  return ParsedTask(
    title: _titleFrom(text, spans),
    category: _categoryFor(text),
    weekday: weekday,
    date: date,
    hour: hour,
    minute: minute,
    recurrence: recurrence,
  );
}

int _weekdayFor(String word) {
  const prefixes = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  for (var i = 0; i < prefixes.length; i++) {
    if (word.startsWith(prefixes[i])) return i + 1;
  }
  return DateTime.monday;
}

String _categoryFor(String text) {
  final words = text.toLowerCase().split(RegExp(r'[^a-z]+')).toSet();
  for (final MapEntry(:key, :value) in _categories.entries) {
    if (value.any(words.contains)) return key;
  }
  return 'General';
}

String _titleFrom(String text, List<(int, int)> spans) {
  final chars = text.split('');
  for (final (a, b) in spans) {
    for (var i = a; i < b && i < chars.length; i++) {
      chars[i] = ' ';
    }
  }
  var title = chars.join().replaceAll(RegExp(r'\s+'), ' ').trim();
  // Words left dangling once the day and time are gone: "Gym on", "Call mum at".
  final dangling = RegExp(r'(?:\s+(?:at|on|by|for|every|this|next|from|in|the)|[\s,;:\-–—]+)$', caseSensitive: false);
  final leading = RegExp(r'^(?:(?:at|on|by|every)\s+|[\s,;:\-–—]+)', caseSensitive: false);
  String previous;
  do {
    previous = title;
    title = title.replaceFirst(dangling, '').replaceFirst(leading, '').trim();
  } while (title != previous);
  return title.isEmpty ? text.trim() : title;
}
