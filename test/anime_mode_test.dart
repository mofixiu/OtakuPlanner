import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:otakuplanner/models/anime_character.dart';
import 'package:otakuplanner/models/task.dart';
import 'package:otakuplanner/providers/theme_provider.dart';
import 'package:otakuplanner/services/animechan_service.dart';
import 'package:otakuplanner/services/assistant_service.dart';
import 'package:otakuplanner/shared/planner_stats.dart';
import 'package:otakuplanner/shared/quote_service.dart';
import 'package:otakuplanner/themes/character_inks.dart';
import 'package:shared_preferences/shared_preferences.dart';

double _contrast(Color a, Color b) =>
    Contrast.ratioOfTones(Hct.fromInt(a.toARGB32()).tone, Hct.fromInt(b.toARGB32()).tone);

const _levi = AnimeCharacter(
  id: 45627,
  name: 'Levi',
  series: 'Attack on Titan',
  imageUrl: 'https://s4.anilist.co/file/anilistcdn/character/large/b45627.png',
);

/// Hands back fixed lines instead of calling Animechan.
class _FakeQuotes extends AnimechanService {
  _FakeQuotes(this.result);
  final List<Quote> result;
  int calls = 0;

  @override
  Future<List<Quote>> linesFor(AnimeCharacter character) async {
    calls++;
    return result;
  }
}

const _gojoLines = [
  Quote(text: "It'll be fine. I'm the strongest there is, after all.", character: 'Satoru Gojo', series: 'Jujutsu Kaisen'),
  Quote(text: "I've always been a nice guy who cares for my students.", character: 'Satoru Gojo', series: 'Jujutsu Kaisen'),
];

Task _task(String title, {bool done = false}) =>
    Task(title: title, category: 'Work', time: '10:00', date: '', color: Colors.black, isChecked: done);

void main() {
  group('colours for a character', () {
    // Every hue around the wheel, from pale to vivid, light to dark.
    final seeds = [
      for (var hue = 0; hue < 360; hue += 15)
        for (final chroma in [14.0, 40.0, 90.0])
          for (final tone in [25.0, 55.0, 85.0]) Color(Hct.from(hue.toDouble(), chroma, tone).toInt()),
    ];

    test('the stamp reads as text on the paper, light and dark', () {
      for (final seed in seeds) {
        for (final brightness in Brightness.values) {
          final c = CharacterInks.colorsFor(seed, brightness);
          expect(_contrast(c.stamp, c.paper), greaterThanOrEqualTo(4.5), reason: '$seed $brightness');
        }
      }
    });

    test('the ink is as readable as the navy it replaces', () {
      for (final seed in seeds) {
        for (final brightness in Brightness.values) {
          final c = CharacterInks.colorsFor(seed, brightness);
          expect(_contrast(c.ink, c.paper), greaterThanOrEqualTo(10), reason: '$seed $brightness');
        }
      }
    });

    test('yellows print as ochre on cream, not olive', () {
      final yellow = Color(Hct.from(105, 80, 85).toInt());
      final stamp = Hct.fromInt(CharacterInks.colorsFor(yellow, Brightness.light).stamp.toARGB32());
      expect(stamp.hue, lessThan(85));
    });
  });

  group('colours from art', () {
    test('skin tones go to the back and greys are dropped', () async {
      final skin = Hct.from(55, 22, 80).toInt();
      final red = Hct.from(25, 70, 45).toInt();
      final grey = Hct.from(250, 3, 50).toInt();
      final pixels = [
        ...List.filled(600, skin),
        ...List.filled(250, red),
        ...List.filled(150, grey),
      ];
      final picks = await CharacterInks.candidatesFromPixels(pixels);
      expect(picks, isNotEmpty);
      expect(Hct.fromInt(picks.first.toARGB32()).hue, closeTo(25, 8));
      expect(picks.any((c) => Hct.fromInt(c.toARGB32()).chroma < 12), isFalse);
    });

    test('no pixels, no colours', () async {
      expect(await CharacterInks.candidatesFromPixels(const []), isEmpty);
    });
  });

  test('a saved character survives a round trip and rejects junk', () {
    expect(AnimeCharacter.fromJson(_levi.toJson()), _levi);
    expect(AnimeCharacter.fromJson(_levi.toJson())!.series, 'Attack on Titan');
    expect(AnimeCharacter.fromJson({'id': 'x'}), isNull);
    expect(AnimeCharacter.fromJson('nope'), isNull);
  });

  group('mode', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('Anime mode needs a character first', () async {
      final provider = ThemeProvider(quotes: _FakeQuotes(const []));
      await provider.setMode(PlannerMode.anime);
      expect(provider.isAnime, isFalse);
    });

    test('picking a character prints the page in it and is remembered', () async {
      final provider = ThemeProvider(quotes: _FakeQuotes(const []));
      await provider.useCharacter(_levi, const Color(0xFF363752));
      expect(provider.isAnime, isTrue);
      expect(provider.lightTheme.colorScheme.primary, isNot(const Color(0xFF1C384E)));

      await provider.setMode(PlannerMode.normal);
      expect(provider.isAnime, isFalse);
      expect(provider.character, _levi);

      final reopened = ThemeProvider(quotes: _FakeQuotes(const []));
      await Future<void>.delayed(Duration.zero);
      expect(reopened.character, _levi);
      expect(reopened.mode, PlannerMode.normal);
    });
  });

  group('lines from the character', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('AniList and Animechan spellings meet', () {
      expect(AnimechanService.nameVariants('Satoru Gojou'), containsAll(['Satoru Gojou', 'Satoru Gojo', 'Satoru']));
      expect(AnimechanService.nameVariants('Luffy Monkey'), contains('Monkey'));
      expect(AnimechanService.sameCharacter('Satoru Gojo', 'Satoru Gojou'), isTrue);
      expect(AnimechanService.sameCharacter('Monkey D. Luffy', 'Luffy Monkey'), isTrue);
      expect(AnimechanService.sameCharacter('Monkey D. Dragon', 'Luffy Monkey'), isFalse);
    });

    test('stage directions are left out of a line', () {
      expect(
        AnimechanService.spoken("*To Captain Kuro* So, you don't like to get hit, huh?"),
        "So, you don't like to get hit, huh?",
      );
      expect(AnimechanService.spoken('[sighs] Fine.  Let us go.'), 'Fine. Let us go.');
    });

    test('grim lines are kept off the planner', () {
      final kept = ThemeProvider.gentle(const [
        Quote(text: "You want to keep everyone from dying? That's naive. It's war.", character: 'A', series: 'B'),
        Quote(text: 'Being alone is more painful than getting hurt.', character: 'Luffy', series: 'One Piece'),
      ]);
      expect(kept.map((q) => q.character), ['Luffy']);
    });

    test('the dashboard shows their line in Anime mode and the usual one in Normal', () async {
      final quotes = _FakeQuotes(_gojoLines);
      final provider = ThemeProvider(quotes: quotes);
      final day = DateTime(2026, 11, 13);
      await provider.useCharacter(_levi, const Color(0xFF07AFE7));
      await provider.linesLoaded;
      expect(_gojoLines, contains(provider.lineOfTheDay(day)));
      expect(provider.lineOfTheDay(day), provider.lineOfTheDay(day.add(const Duration(hours: 5))));
      expect(provider.randomLine(), isNotNull);

      await provider.setMode(PlannerMode.normal);
      expect(provider.lineOfTheDay(day), QuoteService.getQuote(now: day));
      expect(provider.randomLine(), isNull);
    });

    test('lines are asked for once and kept on the phone', () async {
      final first = _FakeQuotes(_gojoLines);
      final provider = ThemeProvider(quotes: first);
      await provider.useCharacter(_levi, const Color(0xFF07AFE7));
      await provider.linesLoaded;
      expect(first.calls, 1);

      final again = _FakeQuotes(const []);
      final reopened = ThemeProvider(quotes: again);
      await Future<void>.delayed(Duration.zero);
      await reopened.linesLoaded;
      expect(again.calls, 0);
      expect(reopened.lines, hasLength(2));
    });

    test('with no lines of their own, the planner\'s lines stand in', () async {
      final provider = ThemeProvider(quotes: _FakeQuotes(const []));
      await provider.useCharacter(_levi, const Color(0xFF07AFE7));
      await provider.linesLoaded;
      final day = DateTime(2026, 11, 13);
      expect(provider.lineOfTheDay(day), QuoteService.getQuote(now: day));
      expect(provider.randomLine(), isNull);
    });
  });

  group('celebrations', () {
    Milestones count(List<Task> today, {Map<DateTime, List<Task>> earlier = const {}}) {
      final now = DateTime(2026, 11, 13, 15);
      return Milestones.of(PlannerStats({DateTime(2026, 11, 13): today, ...earlier}, now: now));
    }

    test('clearing the day is noticed', () {
      final before = count([_task('a', done: true), _task('b')]);
      final after = count([_task('a', done: true), _task('b', done: true)]);
      final m = before.reachedBy(after);
      expect(m?.kicker, anyOf('Today', 'Badge unlocked'));
    });

    test('the first task of the day starts or grows the streak', () {
      final yesterday = {DateTime(2026, 11, 12): [_task('y', done: true)]};
      final before = count([_task('a'), _task('b'), _task('c')], earlier: yesterday);
      final after = count([_task('a', done: true), _task('b'), _task('c')], earlier: yesterday);
      final m = before.reachedBy(after)!;
      expect(m.kicker, anyOf('Streak', 'Badge unlocked'));
      if (m.kicker == 'Streak') expect(m.headline, '2-day streak.');
    });

    test('nothing new, nothing said', () {
      final state = count([_task('a', done: true), _task('b')]);
      expect(state.reachedBy(state), isNull);
    });
  });

  test('the assistant is told who to sound like only in Anime mode', () {
    final now = DateTime(2026, 11, 13, 9, 5);
    final turns = [const AssistantTurn(fromUser: true, text: 'Plan my day')];
    expect(AssistantService.buildRequest(turns, now).containsKey('persona'), isFalse);
    final body = AssistantService.buildRequest(turns, now, persona: _levi);
    expect(body['persona'], {'name': 'Levi', 'series': 'Attack on Titan'});
  });
}
