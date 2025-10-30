import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:project_digidex_frontend/models/pokemon_model.dart';
import 'package:project_digidex_frontend/providers/auth_provider.dart'; 
import 'package:project_digidex_frontend/theme/app_theme.dart';

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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Added ${pokemon.name.toUpperCase()} to your collection!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show an error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      isAlreadyInCollection =
          authProvider.user!.folders[0].pokemons.contains(pokemon.name);
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            pokemon.name.toUpperCase(),
            // --- 2. USE THEME FOR TITLE ---
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
          centerTitle: true,
          actions: [
            if (authProvider.isAuthenticated)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: isAlreadyInCollection
                    ? const IconButton(
                        icon: Icon(Icons.check_circle, color: Colors.green),
                        tooltip: 'Already in collection',
                        onPressed: null, // Disabled
                      )
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
            // --- 3. PASS CONTEXT TO ALL BUILDERS ---
            _buildSummaryTab(context),
            _buildStatsTab(context),
            _buildMovesTab(context),
            _buildMatchupsTab(context),
          ],
        ),
      ),
    );
  }

  // --- TAB 1 WIDGET (Summary) ---
  Widget _buildSummaryTab(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(30), 
                border: Border.all(
                  // Use a theme color for the border
                  color: theme.colorScheme.surface, 
                  width: 4,
                ),
              ),
              child: Image.network(
                pokemon.imageUrl,
                height: 200,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  return progress == null
                      ? child
                      : Center(child: CircularProgressIndicator(
                          // Use theme color for spinner
                          color: theme.primaryColor,
                        ));
                },
                errorBuilder: (c, e, s) =>
                    // Use theme color for error
                    Icon(Icons.error, size: 100, color: theme.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            pokemon.info.description,
            // --- 5. USE THEME FOR TEXT ---
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Height', '${pokemon.info.height / 10} m', context),
          _buildInfoRow('Weight', '${pokemon.info.weight / 10} kg', context),
          _buildInfoRow('Types', pokemon.info.types.join(', '), context),
        ],
      ),
    );
  }

  // --- 6. APPLY THEME TO ALL HELPER WIDGETS ---
  Widget _buildInfoRow(String label, String value, BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // --- TAB 2 WIDGET (Stats) ---
  Widget _buildStatsTab(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: pokemon.stats.length,
      itemBuilder: (context, index) {
        final stat = pokemon.stats[index];
        return _buildStatBar(stat, context);
      },
    );
  }

  Widget _buildStatBar(PokemonStat stat, BuildContext context) {
    double normalizedValue = stat.value / 255.0;
    final theme = Theme.of(context);

    // Pick a color for the bar
    final Color barColor;
    if (normalizedValue > 0.6) {
      barColor = Colors.green;
    } else if (normalizedValue > 0.35) {
      barColor = Colors.orange;
    } else {
      barColor = theme.primaryColor; // Pokedex Red
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${stat.name.toUpperCase()} (${stat.value})',
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: normalizedValue,
              minHeight: 12,
              backgroundColor: theme.colorScheme.surface, // darkGrey
              color: barColor,
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3 WIDGET (Moves) ---
  Widget _buildMovesTab(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: pokemon.moves.map((move) {
          return Chip(
            label: Text(move),
            backgroundColor: theme.colorScheme.surface,
            labelStyle: theme.textTheme.bodySmall,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          );
        }).toList(),
      ),
    );
  }

  // --- TAB 4 WIDGET (Matchups) ---
  Widget _buildMatchupsTab(BuildContext context) {
    final theme = Theme.of(context);
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
              // Card will automatically use theme.colorScheme.surface
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Matchups for ${typeName.toUpperCase()}',
                      style: theme.textTheme.titleMedium,
                    ),
                    const Divider(height: 20),
                    _buildRelationSection('Weak To (2x Damage From)',
                        relations.doubleDamageFrom, Colors.red[300], context),
                    _buildRelationSection('Resists (0.5x Damage From)',
                        relations.halfDamageFrom, Colors.green[300], context),
                    _buildRelationSection('Immune To (0x Damage From)',
                        relations.noDamageFrom, Colors.blue[300], context),
                    const Divider(height: 20),
                    _buildRelationSection(
                        'Effective Against (2x Damage To)',
                        relations.doubleDamageTo,
                        Colors.lightGreen[300],
                        context),
                    _buildRelationSection(
                        'Not Effective Against (0.5x Damage To)',
                        relations.halfDamageTo,
                        Colors.orange[300],
                        context),
                    _buildRelationSection(
                        'No Effect Against (0x Damage To)',
                        relations.noDamageTo,
                        Colors.grey[400],
                        context),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRelationSection(
    String title,
    List<TypeRelation> relations, [
    Color? chipColor,
    BuildContext? context,
  ]) {
    if (relations.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = context != null ? Theme.of(context) : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: theme?.textTheme.bodyMedium?.copyWith(
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
                backgroundColor:
                    chipColor ?? theme?.colorScheme.surface ?? Colors.grey[700],
                labelStyle: TextStyle(
                  // Use dark text on light-colored chips
                  color: chipColor != null ? Colors.black87 : null,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
