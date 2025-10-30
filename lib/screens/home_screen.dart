import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:project_digidex_frontend/providers/auth_provider.dart';
import 'package:project_digidex_frontend/screens/login_screen.dart';
import 'package:project_digidex_frontend/screens/profile_screen.dart';
import 'package:project_digidex_frontend/services/api_service.dart';
import 'package:project_digidex_frontend/screens/pokemon_detail_screen.dart';
import 'package:project_digidex_frontend/models/pokemon_model.dart';
import 'package:project_digidex_frontend/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final Pokemon pokemon = await _apiService.getPokemonByName(query);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PokemonDetailScreen(pokemon: pokemon),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context); // Get the theme

    return Scaffold(
      // Scaffold will use the theme's background color
      body: Stack(
        children: [
          // --- Main Content ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'DigiDex',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontFamily: 'pokemon-solid-font', // <-- 1. FONT ADDED
                      fontSize: 64.0, // You can adjust this size
                    ),
                  ),
                )
                    .animate() // 2. The animations are applied to the Padding
                    .fadeIn(duration: 900.ms)
                    .slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOut)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                        delay: 1000.ms,
                        duration: 1500.ms,
                        color: AppTheme.pokedexRed.withOpacity(0.6))
                    .then(delay: 500.ms)
                    .shimmer(
                        duration: 1500.ms,
                        color: AppTheme.pokedexBlue.withOpacity(0.6))
                    .then(delay: 1000.ms),

                const SizedBox(height: 30),

                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Pokémon...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    // The theme will handle the fillColor
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: _performSearch,
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),

          // --- Profile Icon Button ---
          Positioned(
            top: 40,
            right: 16,
            child: SafeArea(
              child: IconButton(
                icon: Icon(
                  authProvider.isAuthenticated
                      ? Icons.person
                      : Icons.person_outline,
                  size: 30,
                  // The theme will handle the icon color
                ),
                onPressed: () {
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
