import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:project_digidex_frontend/models/pokemon_model.dart';
import 'package:project_digidex_frontend/providers/auth_provider.dart'; // Import AuthProvider

class PokemonDetailScreen extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonDetailScreen({super.key, required this.pokemon});

  // --- FUNCTION to handle adding the pokemon ---
  void _addPokemonToCollection(BuildContext context) async {
    // Use listen: false because we are in a callback
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Call the provider function
      await authProvider.addPokemonToCollection(pokemon.name);
      
      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${pokemon.name.toUpperCase()} to your collection!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Watch the AuthProvider to see if user is logged in ---
    final authProvider = Provider.of<AuthProvider>(context);
    
    // --- Check if this pokemon is already in the collection ---
    bool isAlreadyInCollection = false;
    if (authProvider.isAuthenticated && authProvider.user!.folders.isNotEmpty) {
      // Check the first folder's pokemon list
      isAlreadyInCollection = authProvider.user!.folders[0].pokemons.contains(pokemon.name);
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            pokemon.name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          // --- NEW: "Add to Collection" Button Logic ---
          actions: [
            // Only show the button if the user is logged in
            if (authProvider.isAuthenticated)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: isAlreadyInCollection
                    // If they have it, show a disabled checkmark
                    ? const IconButton(
                        icon: Icon(Icons.check_circle, color: Colors.green),
                        tooltip: 'Already in collection',
                        onPressed: null, // Disabled
                      )
                    // If they don't have it, show the "Add" button
                    : IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: 'Add to collection',
                        onPressed: () => _addPokemonToCollection(context),
                      ),
              ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Summary'),
              Tab(text: 'Stats'),
              Tab(text: 'Move-Set'),
              Tab(text: 'Matchups'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSummaryTab(),
            _buildStatsTab(),
            _buildMovesTab(),
            _buildMatchupsTab(),
          ],
        ),
      ),
    );
  }

  // --- TAB 1 WIDGET (Summary) ---
  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.network(
              pokemon.imageUrl,
              height: 200,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                return progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (c, e, s) => const Icon(Icons.error, size: 100),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            pokemon.info.description,
            style: const TextStyle(
                fontSize: 16, fontStyle: FontStyle.italic, height: 1.5),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Height', '${pokemon.info.height / 10} m'),
          _buildInfoRow('Weight', '${pokemon.info.weight / 10} kg'),
          _buildInfoRow('Types', pokemon.info.types.join(', ')),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // --- TAB 2 WIDGET (Stats) ---
  Widget _buildStatsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: pokemon.stats.length,
      itemBuilder: (context, index) {
        final stat = pokemon.stats[index];
        return _buildStatBar(stat);
      },
    );
  }

  Widget _buildStatBar(PokemonStat stat) {
    double normalizedValue = stat.value / 255.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${stat.name.toUpperCase()} (${stat.value})',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: normalizedValue,
              minHeight: 12,
              backgroundColor: Colors.grey[800],
              color: normalizedValue > 0.5
                  ? Colors.green
                  : (normalizedValue > 0.25 ? Colors.orange : Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3 WIDGET (Moves) ---
  Widget _buildMovesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: pokemon.moves.map((move) {
          return Chip(
            label: Text(move),
            backgroundColor: Colors.grey[800],
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          );
        }).toList(),
      ),
    );
  }

  // --- TAB 4 WIDGET (Matchups) ---
  Widget _buildMatchupsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...pokemon.typeData.asMap().entries.map((entry) {
            int index = entry.key;
            DamageRelations relations = entry.value;
            String typeName = pokemon.info.types[index];

            return Card(
              color: Colors.grey[850],
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Matchups for ${typeName.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 20),
                    _buildRelationSection('Weak To (2x Damage From)',
                        relations.doubleDamageFrom, Colors.red[300]),
                    _buildRelationSection('Resists (0.5x Damage From)',
                        relations.halfDamageFrom, Colors.green[300]),
                    _buildRelationSection('Immune To (0x Damage From)',
                        relations.noDamageFrom, Colors.blue[300]),
                    const Divider(height: 20),
                    _buildRelationSection('Effective Against (2x Damage To)',
                        relations.doubleDamageTo, Colors.lightGreen[300]),
                    _buildRelationSection(
                        'Not Effective Against (0.5x Damage To)',
                        relations.halfDamageTo,
                        Colors.orange[300]),
                    _buildRelationSection('No Effect Against (0x Damage To)',
                        relations.noDamageTo, Colors.grey[400]),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRelationSection(String title, List<TypeRelation> relations, [Color? chipColor]) {
    if (relations.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: relations.map((relation) {
              return Chip(
                label: Text(relation.name),
                backgroundColor: chipColor ?? Colors.grey[700],
                labelStyle: const TextStyle(color: Colors.black87),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
