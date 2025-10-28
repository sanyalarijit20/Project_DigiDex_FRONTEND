import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_digidex_frontend/models/pokemon_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 

class ApiService {

 

  Future<Pokemon> getPokemonByName(String name) async {
    
   
    final String baseUrl = dotenv.env['BASE_URL']!;

   
    final Uri uri = Uri.parse('$baseUrl/${name.toLowerCase()}');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final rawJson = json.decode(response.body);
        return Pokemon.fromJson(rawJson);
      } else if (response.statusCode == 404) {
        throw Exception('Pokémon not found');
      } else {
        // Handle other server errors
        throw Exception('Failed to load Pokémon from server (Code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server. Check firewall/network.');
    }
  }
}
