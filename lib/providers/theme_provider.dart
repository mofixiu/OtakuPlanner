import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:otakuplanner/models/anime_character.dart';
import 'package:otakuplanner/services/animechan_service.dart';
import 'package:otakuplanner/shared/quote_service.dart';
import 'package:otakuplanner/themes/character_inks.dart';
import 'package:otakuplanner/themes/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The two modes: the planner's own navy and vermilion, or Anime mode,
/// where the page is printed in a chosen character's colours and they speak:
/// the line of the day, reminders, celebrations and the assistant.
enum PlannerMode { normal, anime }

/// Light or dark pages and the mode, remembered between launches.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider({AnimechanService? quotes, Random? random})
    : _quotes = quotes ?? AnimechanService(),
      _random = random ?? Random() {
    _load();
  }

  static const _darkKey = 'dark_mode';
  static const _modeKey = 'planner_mode';
  static const _characterKey = 'anime_character';
  static const _seedKey = 'anime_seed';
  // v2: lines are saved without stage directions.
  static String _linesKey(int id) => 'anime_lines_v2_$id';

  final AnimechanService _quotes;
  final Random _random;

  ThemeMode _themeMode = ThemeMode.light;
  PlannerMode _mode = PlannerMode.normal;
  AnimeCharacter? _character;
  Color? _seed;
  ThemeData? _light;
  ThemeData? _dark;
  List<Quote> _lines = const [];
  Future<void>? _fetching;

  ThemeMode get themeMode => _themeMode;
  PlannerMode get mode => _mode;

  /// The last character picked. Kept when switching back to Normal, so
  /// Anime mode comes back the way it was left.
  AnimeCharacter? get character => _character;

  /// The colour from the character's art the page is printed in.
  Color? get seed => _seed;

  bool get isAnime => _mode == PlannerMode.anime && _character != null && _seed != null;

  ThemeData get lightTheme =>
      isAnime
          ? _light ??= OtakuPlannerTheme.build(CharacterInks.colorsFor(_seed!, Brightness.light), Brightness.light)
          : OtakuPlannerTheme.lightTheme;

  ThemeData get darkTheme =>
      isAnime
          ? _dark ??= OtakuPlannerTheme.build(CharacterInks.colorsFor(_seed!, Brightness.dark), Brightness.dark)
          : OtakuPlannerTheme.darkTheme;

  /// Real lines from the character, or from their show when Animechan
  /// doesn't have them. Empty in Normal mode or while they load.
  List<Quote> get lines => isAnime ? _lines : const [];

  /// The dashboard's line: the character's in Anime mode, the planner's own
  /// list otherwise or when they have none. The same all day.
  Quote lineOfTheDay(DateTime now) {
    final own = lines;
    if (own.isEmpty) return QuoteService.getQuote(now: now);
    final day = DateTime.utc(now.year, now.month, now.day).millisecondsSinceEpoch ~/ 86400000;
    return own[day % own.length];
  }

  /// A line for a reminder or a celebration, or null outside Anime mode or
  /// when the character has none.
  Quote? randomLine() {
    final own = lines;
    return own.isEmpty ? null : own[_random.nextInt(own.length)];
  }

  /// Lines fit for a planner: a streak or a reminder shouldn't come with
  /// "It's war. People die." Anime is full of those, so they're left out.
  static List<Quote> gentle(List<Quote> lines) => [
    for (final q in lines)
      if (!_grim.hasMatch(q.text)) q,
  ];

  static final _grim = RegExp(
    r"\b(die|dies|died|dying|dead|death|deaths|kill|kills|killed|killing|murder\w*|blood\w*|corpse\w*|suicide|war|wars|hate|hatred)\b",
    caseSensitive: false,
  );

  /// Loads the character's lines from the phone, asking Animechan when they
  /// aren't saved yet. A failed request is retried next launch; a character
  /// Animechan doesn't know is asked about again after a week.
  Future<void> _loadLines(AnimeCharacter character) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_linesKey(character.id));
    if (saved != null) {
      try {
        final json = jsonDecode(saved) as Map<String, dynamic>;
        final lines = [
          for (final item in json['lines'] as List)
            if (Quote.fromJson(item) case final quote?) quote,
        ];
        final fetched = DateTime.tryParse(json['fetched'] as String? ?? '');
        final stale = lines.isEmpty && (fetched == null || DateTime.now().difference(fetched).inDays >= 7);
        if (_character == character) {
          _lines = gentle(lines);
          notifyListeners();
        }
        if (!stale) return;
      } catch (_) {
        // A damaged save: ask again below.
      }
    }
    try {
      final lines = await _quotes.linesFor(character);
      await prefs.setString(
        _linesKey(character.id),
        jsonEncode({
          'fetched': DateTime.now().toIso8601String(),
          'lines': [for (final q in lines) q.toJson()],
        }),
      );
      if (_character == character) {
        _lines = gentle(lines);
        notifyListeners();
      }
    } catch (_) {
      // Offline or over the daily limit: the planner's own lines stand in.
    }
  }

  void _fetchLines() {
    final character = _character;
    if (character == null) return;
    _fetching = _loadLines(character);
  }

  /// Completes when the current character's lines have been looked up.
  @visibleForTesting
  Future<void> get linesLoaded => _fetching ?? Future.value();

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_darkKey) == true) _themeMode = ThemeMode.dark;
    final saved = prefs.getString(_characterKey);
    if (saved != null) {
      try {
        _character = AnimeCharacter.fromJson(jsonDecode(saved));
      } on FormatException {
        _character = null;
      }
    }
    final seed = prefs.getInt(_seedKey);
    if (seed != null) _seed = Color(seed);
    if (prefs.getString(_modeKey) == PlannerMode.anime.name) _mode = PlannerMode.anime;
    notifyListeners();
    _fetchLines();
  }

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) => prefs.setBool(_darkKey, isDarkMode));
  }

  /// Prints the page in [seed], taken from [character]'s art.
  Future<void> useCharacter(AnimeCharacter character, Color seed) async {
    if (_character != character) _lines = const [];
    _character = character;
    _seed = seed;
    _mode = PlannerMode.anime;
    _light = null;
    _dark = null;
    notifyListeners();
    _fetchLines();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_characterKey, jsonEncode(character.toJson()));
    await prefs.setInt(_seedKey, seed.toARGB32());
    await prefs.setString(_modeKey, PlannerMode.anime.name);
  }

  /// Switches mode. Anime mode needs a character; without one this does
  /// nothing and the caller should open the picker.
  Future<void> setMode(PlannerMode mode) async {
    if (mode == PlannerMode.anime && (_character == null || _seed == null)) return;
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode.name);
  }
}
