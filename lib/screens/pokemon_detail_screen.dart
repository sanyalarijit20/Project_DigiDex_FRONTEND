import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; 
import 'package:provider/provider.dart';
import 'package:project_digidex_frontend/models/pokemon_model.dart';
import 'package:project_digidex_frontend/providers/auth_provider.dart';
import 'package:project_digidex_frontend/theme/app_theme.dart';

class PokemonDetailScreen extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonDetailScreen({super.key, required this.pokemon});

  // --- FUNCTION to handle adding the pokemon ---
  void _addPokemonToCollection(BuildContext context) async {
    // ... (rest of your function is perfect) ...
// ... (existing code) ...
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.addPokemonToCollection(pokemon.name);
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
    final authProvider = Provider.of<AuthProvider>(context);

    bool isAlreadyInCollection = false;
    if (authProvider.isAuthenticated && authProvider.user!.folders.isNotEmpty) {
      isAlreadyInCollection =
          authProvider.user!.folders[0].pokemons.contains(pokemon.name);
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            pokemon.name.toUpperCase(),
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
                        onPressed: null,
                      )
                    : IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: 'Add to collection',
                        onPressed: () => _addPokemonToCollection(context),
                      ),
              ),
          ],
          bottom: const TabBar(
            isScrollable: false,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: 'Info'), 
              Tab(text: 'Stats'),
              Tab(text: 'Moves'), 
              Tab(text: 'H2H'), 
            ],
          ),
        ),
        body: TabBarView(
          children: [
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
    final String imageUrl = pokemon.imageUrl ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- IMAGE CONTAINER ---
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.surface,
                width: 4,
              ),
            ),
            child: imageUrl.isEmpty
                ? Icon(
                    Icons.image_not_supported,
                    size: 100,
                    color: theme.primaryColor,
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      return progress == null
                          ? child
                          : Center(
                              child: CircularProgressIndicator(
                              color: theme.primaryColor,
                            ));
                    },
                    errorBuilder: (c, e, s) => Icon(Icons.error_outline,
                        size: 100, color: theme.primaryColor),
                  ),
          ),
          const SizedBox(height: 20),

          // --- DESCRIPTION CARD ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                pokemon.info.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              )
                  // --- 2. ADD RED/BLUE SHIMMER ---
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                      delay: 2000.ms,
                      duration: 1800.ms,
                      color: AppTheme.pokedexRed.withOpacity(0.6))
                  .then(delay: 1000.ms)
                  .shimmer(
                      duration: 1800.ms,
                      color: AppTheme.pokedexBlue.withOpacity(0.6)),
            ),
          ),
          const SizedBox(height: 20),

          // --- INFO ROW (Height, Weight, etc.) ---
          Row(
            children: [
              InfoCard(
                  label: 'Height', value: '${pokemon.info.height / 10} m'),
              const SizedBox(width: 12),
              InfoCard(
                  label: 'Weight', value: '${pokemon.info.weight / 10} kg'),
            ],
          ),
          const SizedBox(height: 12),
          // --- Types Card (Spans full width) ---
          InfoCard(
            label: 'Types',
            value: pokemon.info.types.join(', ').toUpperCase(),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  // --- TAB 2 WIDGET (Stats) ---
  Widget _buildStatsTab(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: pokemon.stats.length,
      itemBuilder: (context, index) {
        final stat = pokemon.stats[index];
        double normalizedValue = stat.value / 255.0; // Max stat is 255
        if (normalizedValue < 0) normalizedValue = 0;
        if (normalizedValue > 1) normalizedValue = 1;

        // Pick a color for the bar
        final Color barColor;
        if (normalizedValue > 0.6) {
          barColor = Colors.green;
        } else if (normalizedValue > 0.35) {
          barColor = Colors.orange;
        } else {
          barColor = theme.primaryColor; // Pokedex Red
        }

        // Return the Card with the new layout
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Stat Name
                    Text(
                      stat.name.toUpperCase().replaceAll('-', ' '),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    )
                        // --- 3. ADD GOLD SHIMMER (Staggered) ---
                        .animate(
                            onPlay: (controller) => controller.repeat(),
                            delay: (200 * index)
                                .ms) // Stagger delay based on index
                        .shimmer(
                            delay: 2000.ms,
                            duration: 2000.ms,
                            color: Colors.amber),
                    // Stat Value (colored)
                    Text(
                      stat.value.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: barColor, // Use the same color as the bar
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: normalizedValue,
                    minHeight: 12,
                    backgroundColor: theme.colorScheme.surface,
                    color: barColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- TAB 3 WIDGET (Moves) ---
  Widget _buildMovesTab(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: pokemon.moves.length,
      itemBuilder: (context, index) {
        final move = pokemon.moves[index];
        // Return a Card, similar to the Stats tab but simpler
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              move.toUpperCase().replaceAll('-', ' '),
              style: theme.textTheme.bodyMedium,
            )
                // --- 4. ADD RED/BLUE SHIMMER (Staggered) ---
                .animate(
                    onPlay: (controller) => controller.repeat(),
                    delay: (100 * index).ms) // Stagger delay
                .shimmer(
                    delay: 2000.ms,
                    duration: 1800.ms,
                    color: AppTheme.pokedexRed.withOpacity(0.6))
                .then(delay: 1000.ms)
                .shimmer(
                    duration: 1800.ms,
                    color: AppTheme.pokedexBlue.withOpacity(0.6)),
          ),
        );
      },
    );
  }

  // --- TAB 4 WIDGET (Matchups) ---
  Widget _buildMatchupsTab(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          ...pokemon.typeData.asMap().entries.map((entry) {
            int index = entry.key;
            DamageRelations relations = entry.value;
            String typeName = pokemon.info.types[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                    _buildRelationSection('Effective Against (2x Damage To)',
                        relations.doubleDamageTo, Colors.lightGreen[300], context),
                    _buildRelationSection(
                        'Not Effective Against (0.5x Damage To)',
                        relations.halfDamageTo,
                        Colors.orange[300],
                        context),
                    _buildRelationSection('No Effect Against (0x Damage To)',
                        relations.noDamageTo, Colors.grey[400], context),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- Helper for Matchups Tab (unchanged) ---
  Widget _buildRelationSection(
      String title, List<TypeRelation> relations, Color? chipColor, BuildContext context) {
    if (relations.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          )
              // --- 5. ADD GOLD/SILVER SHIMMER ---
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                  delay: 2000.ms,
                  duration: 1800.ms,
                  color: Colors.amber) // Gold
              .then(delay: 1000.ms)
              .shimmer(
                  duration: 1800.ms,
                  color: Colors.grey[400]), // Silver
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: relations.map((relation) {
              return Chip(
                label: Text(relation.name),
                backgroundColor:
                    chipColor ?? theme.colorScheme.surface,
                labelStyle: TextStyle(
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

// --- A custom widget for the Summary Tab (Height, Weight, etc.) ---
class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isFullWidth;

  const InfoCard({
    super.key,
    required this.label,
    required this.value,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleMedium,
            )
                // --- 2. ADD RED/BLUE SHIMMER ---
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                    delay: 2000.ms,
                    duration: 1800.ms,
                    color: AppTheme.pokedexRed.withOpacity(0.6))
                .then(delay: 1000.ms)
                .shimmer(
                    duration: 1800.ms,
                    color: AppTheme.pokedexBlue.withOpacity(0.6)),
          ],
        ),
      ),
    );

    return isFullWidth ? content : Expanded(child: content);
  }
}