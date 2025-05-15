import 'dart:convert';
import 'package:http/http.dart' as http;

class AniListService {
  final String _url = 'https://graphql.anilist.co';

  Future<List<Map<String, dynamic>>> searchCharacters(String query) async {
    const queryText = r'''
      query ($search: String) {
        Page(perPage: 10) {
          characters(search: $search) {
            id
            name {
              full
            }
            image {
              large
            }
          }
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'query': queryText,
        'variables': {'search': query},
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final characters = jsonData['data']['Page']['characters'] as List<dynamic>;

      return characters.map((char) => {
        'id': char['id'],
        'name': char['name']['full'],
        'image_url': char['image']['large'],
      }).toList();
    } else {
      throw Exception('Failed to fetch characters');
    }
  }
}
