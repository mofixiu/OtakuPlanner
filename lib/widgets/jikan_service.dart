import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class JikanService {
  Future<Map<String, dynamic>?> fetchRandomCharacter() async {
    final url = Uri.parse('https://api.jikan.moe/v4/characters');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> characters = data['data']; 

        if (characters.isNotEmpty) {
          final random = Random();
          return characters[random.nextInt(characters.length)]; 
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch data: $e');
    }
    return null;
  }
}
