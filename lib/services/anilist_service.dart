import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:otakuplanner/models/anime_character.dart';

/// Character search through AniList's public API. It's free for
/// non-commercial apps, needs no key and allows 30 requests a minute, so
/// searches are debounced by the caller.
/// Terms: https://docs.anilist.co/guide/terms-of-use
class AniListService {
  AniListService({Dio? dio})
    : _dio =
          dio ??
          Dio(BaseOptions(connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 15)));

  final Dio _dio;

  static const _endpoint = 'https://graphql.anilist.co';

  // Most-favourited first, so "Levi" finds Attack on Titan's Levi before a
  // side character, and an empty search shows the characters people love.
  static const _query = r'''
    query ($search: String, $page: Int) {
      Page(page: $page, perPage: 24) {
        characters(search: $search, sort: FAVOURITES_DESC) {
          id
          name { full }
          image { large }
          media(perPage: 1, sort: POPULARITY_DESC) {
            nodes { title { english romaji } }
          }
        }
      }
    }
  ''';

  /// Characters matching [search], or the most loved ones when it's empty.
  Future<List<AnimeCharacter>> characters({String search = '', int page = 1}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _endpoint,
      data: {
        'query': _query,
        'variables': {if (search.trim().isNotEmpty) 'search': search.trim(), 'page': page},
      },
      options: Options(headers: {'Accept': 'application/json'}),
    );
    final list = response.data?['data']?['Page']?['characters'];
    if (list is! List) return const [];
    final out = <AnimeCharacter>[];
    for (final item in list) {
      if (item is! Map) continue;
      final id = item['id'];
      final name = item['name']?['full'];
      final image = item['image']?['large'];
      if (id is! int || name is! String || image is! String) continue;
      // AniList's placeholder for characters without art.
      if (image.contains('/default.')) continue;
      final nodes = item['media']?['nodes'];
      final title = nodes is List && nodes.isNotEmpty ? nodes.first['title'] : null;
      final series = (title?['english'] ?? title?['romaji']) as String? ?? '';
      out.add(AnimeCharacter(id: id, name: name, series: series, imageUrl: image));
    }
    return out;
  }

  /// The portrait's bytes, for reading its colours.
  Future<Uint8List> portraitBytes(AnimeCharacter character) async {
    final response = await _dio.get<List<int>>(character.imageUrl, options: Options(responseType: ResponseType.bytes));
    return Uint8List.fromList(response.data ?? const []);
  }
}
