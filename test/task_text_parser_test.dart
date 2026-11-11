import 'package:flutter_test/flutter_test.dart';
import 'package:otakuplanner/services/task_text_parser.dart';

void main() {
  // A Thursday.
  final now = DateTime(2026, 11, 5, 10);
  ParsedTask parse(String text) => parseTaskText(text, now: now);

  test('the example from the app', () {
    final t = parse('Watch anime every Monday at 8pm');
    expect(t.title, 'Watch anime');
    expect(t.dayName, 'Monday');
    expect(t.time12, '8:00 PM');
    expect(t.recurrence, Recurrence.weekly);
    expect(t.category, 'Anime');
  });

  test('"everything" does not make a task repeat', () {
    final t = parse('Read everything about Jujutsu at 5pm');
    expect(t.title, 'Read everything about Jujutsu');
    expect(t.isRecurring, isFalse);
  });

  test('categories match whole words only', () {
    expect(parse('Do homework at 4pm').category, 'Study');
    expect(parse('Gym workout at 6am').category, 'Personal');
    expect(parse('Team meeting at 10am').category, 'Work');
    expect(parse('Buy a frame at 2pm').category, 'General');
  });

  test('impossible 12-hour times are not read', () {
    expect(parse('Meeting at 13pm').hasTime, isFalse);
    expect(parse('Meeting at 99 am').hasTime, isFalse);
    expect(parse('Meeting at 9:75pm').hasTime, isFalse);
  });

  test('12-hour, 24-hour and word times', () {
    expect(parse('Study at 9.30pm').time12, '9:30 PM');
    expect(parse('Study at 9:30 p.m.').time12, '9:30 PM');
    expect(parse('Call mum at 17:30').time12, '5:30 PM');
    expect(parse('Call mum at 08:05').time12, '8:05 AM');
    expect(parse('Lunch at noon').time12, '12:00 PM');
    expect(parse('Sleep at midnight').time12, '12:00 AM');
    expect(parse('Gym at 12am').hour, 0);
    expect(parse('Gym at 12pm').hour, 12);
  });

  test('today and tomorrow set the date and leave the title', () {
    final t = parse('Do homework tomorrow at 4pm');
    expect(t.title, 'Do homework');
    expect(t.date, DateTime(2026, 11, 6));
    expect(t.dayName, 'Friday');
    final tonight = parse('Watch anime tonight at 9pm');
    expect(tonight.date, DateTime(2026, 11, 5));
    expect(tonight.title, 'Watch anime');
  });

  test('short day names', () {
    expect(parse('Anime night Fri 7pm').dayName, 'Friday');
    expect(parse('Chapter drop on Sat at 3pm').dayName, 'Saturday');
    expect(parse('Watch the sun set at 6pm').weekday, isNull);
  });

  test('daily and weekly repeats', () {
    final daily = parse('Study every day at 7am');
    expect(daily.recurrence, Recurrence.daily);
    expect(daily.title, 'Study');
    expect(daily.toMap()['frequency'], 'daily');
    expect(parse('Revise daily at 6pm').recurrence, Recurrence.daily);
    final weekly = parse('Laundry weekly at 10am');
    expect(weekly.recurrence, Recurrence.weekly);
    expect(weekly.dayName, 'Thursday');
    expect(parse('Gaming on Saturdays at 8pm').recurrence, Recurrence.weekly);
  });

  test('a task with nothing to strip keeps its text', () {
    expect(parse('at 5pm').title, 'at 5pm');
    expect(parse('Clean room').title, 'Clean room');
  });

  test('odd input never throws', () {
    for (final text in ['', '   ', 'İİİ every Monday 5pm', '99:99', 'every', '::', '12', 'pm am']) {
      expect(() => parse(text), returnsNormally, reason: text);
    }
  });
}
