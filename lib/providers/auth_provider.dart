import 'package:flutter/material.dart';
import 'package:project_digidex_frontend/models/user_model.dart';
import 'package:project_digidex_frontend/services/auth_api_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthApiService _apiService = AuthApiService();

  String? _token;
  User? _user;
  bool _isLoading = false;
  String? _error;
  String? get token => _token;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  // --- Internal State Helpers ---
  void _startLoading() {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Tell the UI to rebuild
  }

  void _setError(String errorMessage) {
    _isLoading = false;
    _error = errorMessage.replaceFirst('Exception: ', '');
    notifyListeners(); // Tell the UI to rebuild 
  }

  // --- 1. AUTH FUNCTIONS (Called by Login/Register screens) ---

  Future<bool> login(String username, String password) async {
    _startLoading();
    try {
      final token = await _apiService.login(username, password);
      _token = token;
      // After logging in, immediately fetch the user's data
      await fetchProfile();
      _isLoading = false;
      notifyListeners();
      return true; // Success
    } catch (e) {
      _setError(e.toString());
      return false; // Failed
    }
  }

  Future<bool> register(String username, String password) async {
    _startLoading();
    try {
      final token = await _apiService.register(username, password);
      _token = token;
      // After registering, immediately fetch the user's data
      await fetchProfile();
      _isLoading = false;
      notifyListeners();
      return true; // Success
    } catch (e) {
      _setError(e.toString());
      return false; // Failed
    }
  }

  // Called by the Logout button on the Profile screen
  void logout() {
    _token = null;
    _user = null;
    notifyListeners(); // Clear the state and notify the app
  }

  // --- 2. DATA FUNCTIONS ---

  // Helper function to get fresh user data from the server
  Future<void> fetchProfile() async {
    if (_token != null) {
      try {
        _user = await _apiService.getUserProfile(_token!);
        notifyListeners(); // Update the app with the new user data
      } catch (e) {
        _setError(e.toString());
      }
    }
  }

  // --- ADD POKEMON ---
  // This will be called by your PokemonDetailScreen
  Future<void> addPokemonToCollection(String pokemonName) async {
    if (_token == null || _user == null || _user!.folders.isEmpty) {
      // This should ideally not be thrown if UI is set up correctly
      throw Exception('Not logged in or no folders exist.');
    }
    
    // This logic automatically adds to the user's *first* folder
    // (the "My First Collection" created on register)
    final folderId = _user!.folders[0].id;
    
    try {
      // 1. Call the API
      await _apiService.addPokemon(_token!, folderId, pokemonName);
      // 2. Refresh the user data so the profile list updates *immediately*
      await fetchProfile();
    } catch (e) {
      rethrow; // Let the UI handle and show the error message
    }
  }

  // --- ADD BADGE ---
  // This will be called by ProfileScreen
  Future<void> addBadge(String name, String gym) async {
    if (_token == null) {
      throw Exception('Not logged in.');
    }
    
    try {
      // 1. Call the API
      await _apiService.addBadge(_token!, name, gym);
      // 2. Refresh the user data so the badge list updates *immediately*
      await fetchProfile();
    } catch (e) {
      rethrow; // Let the UI handle and show the error message
    }
  }

  // --- DELETE POKEMON ---
  // This will be called by your ProfileScreen
  Future<void> deletePokemonFromCollection(String pokemonName) async {
    if (_token == null || _user == null || _user!.folders.isEmpty) {
      throw Exception('Not logged in or no folders exist.');
    }

    final folderId = _user!.folders[0].id;

    try {
      // 1. Call the API
      await _apiService.deletePokemon(_token!, folderId, pokemonName);
      // 2. Refresh the user data so the profile list updates *immediately*
      await fetchProfile();
    } catch (e) {
      rethrow; // Let the UI handle and show the error message
    }
  }

  // --- DELETE BADGE ---
  // This will be called by your ProfileScreen
  Future<void> deleteBadge(String badgeId) async {
    if (_token == null) {
      throw Exception('Not logged in.');
    }
    
    try {
      // 1. Call the API
      await _apiService.deleteBadge(_token!, badgeId);
      // 2. Refresh the user data so the badge list updates *immediately*
      await fetchProfile();
    } catch (e) {
      rethrow; // Let the UI handle and show the error message
    }
  }

  // --- DELETE USER ACCOUNT ---
  // This will be called by your ProfileScreen
  Future<void> deleteUserAccount() async {
    if (_token == null) {
      throw Exception('Not logged in.');
    }
    
    _startLoading(); // Use your existing helper
    try {
      // 1. Call the API
      await _apiService.deleteUser(_token!);
      // 2. On success, log the user out completely
      logout();
      _isLoading = false; // We need to manually set this as logout() doesn't
      notifyListeners();
    } catch (e) {
      _setError(e.toString()); // Use your existing helper
    }
  }
}
