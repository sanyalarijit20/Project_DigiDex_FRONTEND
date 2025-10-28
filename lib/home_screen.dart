import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:project_digidex_frontend/models/pokemon_model.dart';
import 'package:project_digidex_frontend/services/api_service.dart';
import 'pokemon_detail_screen.dart'; // We will navigate here on success

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  
  bool _isLoading = false;
  String _errorMessage = '';

  
  void _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = ''; 
    });

    try {
      
      final Pokemon pokemon = await _apiService.getPokemonByName(query);

      
      setState(() { _isLoading = false; });
      
      
      _searchController.clear();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PokemonDetailScreen(pokemon: pokemon),
        ),
      );

    } catch (e) {
      
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', ''); 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
            .shimmer(delay: 1000.ms, duration: 1500.ms, color: Colors.red)
            .then(delay: 500.ms)
            .shimmer(duration: 1500.ms, color: Colors.blue)
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

            // --- NEW Loading and Error Section ---
            if (_isLoading)
              const CircularProgressIndicator(),
            
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}