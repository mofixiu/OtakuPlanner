import 'package:dio/dio.dart';
import 'package:otakuplanner/models/anime_character.dart';
import 'package:otakuplanner/shared/quote_service.dart';

/// Real lines from anime, through Animechan's free API: no key, 100 requests
/// a day per phone. Anime mode asks for a character's lines once, when they
/// are picked, and keeps them on the phone (see ThemeProvider).
/// Docs: https://animechan.io/docs
class AnimechanService {
  AnimechanService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://api.animechan.io/v1',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
            ),
          );

  final Dio _dio;

  /// Pages of five; four is plenty for a line a day and spares the limit.
  static const _maxPages = 4;

  /// The character's own lines, or when Animechan doesn't know them, lines
  /// from their show. Empty when it knows neither.
  Future<List<Quote>> linesFor(AnimeCharacter character) async {
    bool said(Quote q) => _sameSeries(q.series, character.series) && sameCharacter(q.character, character.name);
    for (final name in nameVariants(character.name)) {
      final first = await _page({'character': name}, 1);
      final theirs = first.where(said).toList();
      if (theirs.isEmpty) continue;
      final lines = [...theirs];
      if (first.length == 5) {
        for (var page = 2; page <= _maxPages; page++) {
          final more = await _page({'character': name}, page);
          lines.addAll(more.where(said));
          if (more.length < 5) break;
        }
      }
      return _usable(lines);
    }
    if (character.series.isEmpty) return const [];
    final fromShow = <Quote>[];
    for (var page = 1; page <= 2; page++) {
      final lines = await _page({'anime': character.series}, page);
      fromShow.addAll(lines);
      if (lines.length < 5) break;
    }
    return _usable(fromShow);
  }

  Future<List<Quote>> _page(Map<String, String> filter, int page) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/quotes', queryParameters: {...filter, 'page': page});
      final data = response.data?['data'];
      if (data is! List) return const [];
      return [
        for (final item in data)
          if (item is Map &&
              item['content'] is String &&
              item['character']?['name'] is String &&
              item['anime']?['name'] is String)
            Quote(
              text: (item['content'] as String).trim(),
              character: item['character']['name'] as String,
              series: item['anime']['name'] as String,
            ),
      ];
    } on DioException catch (e) {
      // 404 means "no quotes for that name": try the next spelling.
      if (e.response?.statusCode == 404) return const [];
      rethrow;
    }
  }

  /// AniList and Animechan spell names differently ("Satoru Gojou" and
  /// "Satoru Gojo", "Luffy Monkey" and "Monkey D. Luffy"), so try the full
  /// name, then without long vowels, then each part, longest first. Results
  /// are checked with [sameCharacter], so a part only finds the right person.
  static List<String> nameVariants(String name) {
    // "Gojou" is romanised with a long vowel; Animechan writes "Gojo".
    String short(String p) => p.length > 3 && p.endsWith('ou') ? p.substring(0, p.length - 1) : p;
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final variants = <String>[name.trim(), parts.map(short).join(' ')];
    final byLength = [...parts]..sort((a, b) => b.length.compareTo(a.length));
    if (parts.length > 1) {
      for (final p in byLength) {
        if (p.length >= 3) variants.add(short(p));
      }
    }
    return variants.toSet().toList();
  }

  /// Whether Animechan's [speaker] is AniList's [name]: every part of the
  /// name appears in theirs, so "Monkey" finds Luffy's lines but not Garp's.
  static bool sameCharacter(String speaker, String name) {
    String norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final heard = norm(speaker);
    final parts = name.split(RegExp(r'\s+')).map(norm).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return false;
    return parts.every((p) => heard.contains(p) || (p.endsWith('ou') && heard.contains(p.substring(0, p.length - 1))));
  }

  /// Loose title match: "DARLING in the FRANXX" is "Darling in the Franxx",
  /// and "JUJUTSU KAISEN" is "Jujutsu Kaisen". With no show to compare,
  /// anything goes.
  static bool _sameSeries(String a, String b) {
    if (b.isEmpty) return true;
    String norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final x = norm(a);
    final y = norm(b);
    if (x.isEmpty || y.isEmpty) return false;
    return x.contains(y) || y.contains(x);
  }

  /// Lines that read well on one dashboard panel, without the script's stage
  /// directions ("*To Captain Kuro* So, you don't like…").
  static List<Quote> _usable(List<Quote> lines) {
    final seen = <String>{};
    return [
      for (final q in lines)
        if (spoken(q.text) case final text when text.length >= 20 && text.length <= 180 && seen.add(text))
          Quote(text: text, character: q.character, series: q.series),
    ];
  }

  /// Just what was said: stage directions in asterisks or brackets removed.
  static String spoken(String text) => text
      .replaceAll(RegExp(r'\*[^*]*\*'), ' ')
      .replaceAll(RegExp(r'\[[^\]]*\]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
