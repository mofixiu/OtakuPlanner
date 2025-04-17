import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';


// class JikanService {
  
//   Future<Map<String, dynamic>?> fetchRandomCharacter() async {
//     final url = Uri.parse('https://api.jikan.moe/v4/characters');

//     try {
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         List<dynamic> characters = data['data']; 

//         if (characters.isNotEmpty) {
//           final random = Random();
//           return characters[random.nextInt(characters.length)]; 
//         }
//       } else {
//         print('Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Failed to fetch data: $e');
//     }
//     return null;
//   }
// }
class JikanService {
  Future<Map<String, dynamic>?> fetchRandomCharacter() async {
    // Already works
  }

  // 🔥 Add this method to fetch characters
  Future<List<Map<String, dynamic>>> fetchCharacters() async {
    final url = Uri.parse('https://api.jikan.moe/v4/characters');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Fetch characters failed: $e');
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> searchCharacters(String query) async {
    final url = Uri.parse('https://api.jikan.moe/v4/characters?q=$query&limit=20');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      }
    } catch (e) {
      print('Search error: $e');
    }
    return [];
  }
}
