import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:project_digidex_frontend/models/pokemon_model.dart';
import 'package:project_digidex_frontend/services/api_service.dart';
import 'package:project_digidex_frontend/screens/pokemon_detail_screen.dart'; // Make sure this is in /screens

// --- 1. ADD NEW IMPORTS ---
import 'package:provider/provider.dart';
import 'package:project_digidex_frontend/providers/auth_provider.dart';
import 'package:project_digidex_frontend/screens/login_screen.dart';
import 'package:project_digidex_frontend/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String _error = ''; // Renamed for consistency

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Added explicit type to fix potential 'unused import'
      final Pokemon pokemon = await _apiService.getPokemonByName(query);

      // Clear search and reset state *before* navigating
      setState(() { _isLoading = false; });
      _searchController.clear();
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PokemonDetailScreen(pokemon: pokemon),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- 2. GET AUTH STATE ---
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      // --- 3. WRAP BODY IN A STACK ---
      body: Stack(
        children: [
          // --- 4. THIS IS YOUR EXISTING UI ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'DigiDex',
                  style: TextStyle(
                    fontSize: 48.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 900.ms)
                    .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOut)
                    .animate(onPlay: (controller) => controller.repeat()) // Chain 2
                    .shimmer(delay: 1000.ms, duration: 1500.ms, color: Colors.red.withOpacity(0.6))
                    .then(delay: 500.ms)
                    .shimmer(duration: 1500.ms, color: Colors.blue.withOpacity(0.6))
                    .then(delay: 1000.ms),
                
                const SizedBox(height: 30),

                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Pokémon by name or number...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                  ),
                  onSubmitted: (value) {
                    _performSearch(value);
                  },
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 900.ms)
                    .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOut),
                
                const SizedBox(height: 20),
                
                if (_isLoading)
                  const CircularProgressIndicator(),
                
                if (_error.isNotEmpty)
                  Text(
                    _error,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center, // Added for better text wrapping
                  ),
              ],
            ),
          ),

          // --- 5. ADD THE PROFILE/LOGIN BUTTON ---
          Positioned(
            // Position in top-right corner, respecting status bar
            top: 40.0, 
            right: 16.0,
            child: IconButton(
              icon: Icon(
                authProvider.isAuthenticated ? Icons.person : Icons.person_outline,
                color: Colors.white, // Color to match your title
                size: 30.0, // Make it a bit bigger
              ),
              onPressed: () {
                // Navigate to Profile or Login
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => authProvider.isAuthenticated
                        ? const ProfileScreen()
                        : const LoginScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}