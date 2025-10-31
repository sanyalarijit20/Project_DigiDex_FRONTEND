import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_digidex_frontend/models/user_model.dart'; 

class AuthApiService {
  final String _baseUrl = dotenv.env['BASE_URL']!;

  // --- LOGIN ---
  Future<String> login(String username, String password) async {
    final Uri uri = Uri.parse('$_baseUrl/api/auth/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    final body = json.decode(response.body);
    if (response.statusCode == 200) return body['token'];
    throw Exception(body['message'] ?? 'Login failed');
  }

  // --- REGISTER ---
  Future<String> register(String username, String password) async {
    final Uri uri = Uri.parse('$_baseUrl/api/auth/register');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    final body = json.decode(response.body);
    if (response.statusCode == 200) return body['token'];
    throw Exception(body['message'] ?? 'Registration failed');
  }

  // --- GET PROFILE ---
  Future<User> getUserProfile(String token) async {
    final Uri uri = Uri.parse('$_baseUrl/api/profile');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final body = json.decode(response.body);
    if (response.statusCode == 200) return User.fromJson(body);
    throw Exception(body['message'] ?? 'Failed to fetch profile');
  }

  // --- ADD POKEMON (NEW) ---
  Future<void> addPokemon(String token, String folderId, String pokemonName) async {
    final Uri uri = Uri.parse('$_baseUrl/api/profile/pokemons');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'folderId': folderId, 'pokemonName': pokemonName}),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Failed to add Pokémon');
    }
  }

  // --- ADD BADGE (NEW) ---
  Future<void> addBadge(String token, String name, String gym) async {
    final Uri uri = Uri.parse('$_baseUrl/api/profile/badges');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'name': name, 'gym': gym}),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Failed to add badge');
    }
  }
  // 1. DELETE POKEMON
  Future<void> deletePokemon(
      String token, String folderId, String pokemonName) async {
    // Builds the URL: /api/profile/folders/FOLDER_ID/pokemons/POKEMON_NAME
    final Uri uri = Uri.parse(
        '$_baseUrl/api/profile/folders/$folderId/pokemons/$pokemonName');

    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          json.decode(response.body)['message'] ?? 'Failed to delete Pokémon');
    }
  }

  // 2. DELETE BADGE
  Future<void> deleteBadge(String token, String badgeId) async {
    // Builds the URL: /api/profile/badges/BADGE_ID
    final Uri uri = Uri.parse('$_baseUrl/api/profile/badges/$badgeId');

    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          json.decode(response.body)['message'] ?? 'Failed to delete badge');
    }
  }

  // 3. DELETE USER
  Future<void> deleteUser(String token) async {
    // Builds the URL: /api/profile
    final Uri uri = Uri.parse('$_baseUrl/api/profile');

    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          json.decode(response.body)['message'] ?? 'Failed to delete account');
    }
  }
}
