import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_digidex_frontend/models/user_model.dart';
import 'package:project_digidex_frontend/providers/auth_provider.dart';
import 'package:project_digidex_frontend/services/api_service.dart';
import 'package:project_digidex_frontend/models/pokemon_model.dart';
import 'package:project_digidex_frontend/screens/pokemon_detail_screen.dart';
import 'package:project_digidex_frontend/screens/login_screen.dart'; 

//StatefulWidget to manage the TabController
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

//SingleTickerProviderStateMixin for the TabController's animation
class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  //Instance of the Pokemon API service to fetch pokemon details
  final ApiService _pokemonApiService = ApiService();

  // This variable will track which tab is active (0 = Pokemon, 1 = Badges)
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    //Listener to update our index variable whenever the tab changes
    _tabController.addListener(() {
      // Check to prevent firing twice on one tap
      if (_tabController.indexIsChanging) return;
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- This function shows the "Add Badge" dialog box ---
  void _showAddBadgeDialog(BuildContext context) {
    // Get the provider, but listen: false because we're in a callback
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Create keys to validate and read the form fields
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final gymController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Badge'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Make the dialog only as big as needed
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Badge Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: gymController,
                decoration: const InputDecoration(labelText: 'Gym Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          // Cancel Button
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          // Add Button
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () async {
              // Validate the form
              if (formKey.currentState!.validate()) {
                final name = nameController.text;
                final gym = gymController.text;
                try {
                  // Call the provider function
                  await authProvider.addBadge(name, gym);
                  if (mounted) Navigator.of(ctx).pop(); // Close dialog on success

                  // Show success message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Badge added!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  // Show error message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text(e.toString().replaceFirst('Exception: ', '')),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // --- Reusable Confirmation Dialog ---
  Future<bool> _showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    return result ?? false; // Return false if dialog is dismissed
  }

  // --- Delete Pokemon Logic ---
  void _deletePokemon(BuildContext context, String pokemonName) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final confirmed = await _showConfirmationDialog(
      context,
      'Delete Pokémon?',
      'Are you sure you want to remove $pokemonName from your collection?',
    );

    if (confirmed) {
      try {
        await authProvider.deletePokemonFromCollection(pokemonName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$pokemonName removed!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // --- Delete Badge Logic ---
  void _deleteBadge(BuildContext context, UserBadge badge) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final confirmed = await _showConfirmationDialog(
      context,
      'Delete Badge?',
      'Are you sure you want to remove the ${badge.name}?',
    );

    if (confirmed) {
      try {
        await authProvider.deleteBadge(badge.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${badge.name} removed!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // --- Delete Account Logic ---
  void _deleteAccount(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final confirmed = await _showConfirmationDialog(
      context,
      'DELETE ACCOUNT?',
      'Are you absolutely sure? This action is permanent and cannot be undone.',
    );

    if (confirmed) {
      try {
        await authProvider.deleteUserAccount();
        // On success, pop all screens and go back to the login screen
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (ctx) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // We use Consumer so this widget tree rebuilds when auth.user changes
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        // Fallback check if the user object is somehow null
        if (auth.user == null) {
          return const Scaffold(
            body: Center(child: Text('Not logged in.')),
          );
        }

        final user = auth.user!; // We now know the user is not null

        return Scaffold(
          appBar: AppBar(
            title: Text('${user.username}\'s Profile'),
            actions: [
              // Logout Button
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  auth.logout();
                  // Go back to the home screen after logging out
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              )
            ],
            // The TabBar for our two sections
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'My Pokémon', icon: Icon(Icons.catching_pokemon)),
                Tab(text: 'My Badges', icon: Icon(Icons.shield)),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // --- Tab 1: "My Pokémon" ---
              _buildPokemonTab(context, user.folders),
              // --- Tab 2: "My Badges" ---
              _buildBadgesTab(context, user.badges),
            ],
          ),
          // --- Floating Action Button ---
          floatingActionButton: _currentTabIndex == 1 // Only show on "Badges" tab
              ? FloatingActionButton(
                  onPressed: () => _showAddBadgeDialog(context),
                  tooltip: 'Add New Badge',
                  child: const Icon(Icons.add),
                )
              : null, // Don't show on "My Pokémon" tab
        );
      },
    );
  }

  // --- Tab 1 Builder: "My Pokémon" ---
  Widget _buildPokemonTab(BuildContext context, List<UserFolder> folders) {
    if (folders.isEmpty) {
      return const Center(child: Text('You have no Pokémon collections.'));
    }

    // As per backend, show the user's *first* folder
    final folder = folders[0];

    if (folder.pokemons.isEmpty) {
      return const Center(
          child: Text('Your "My First Collection" is empty. Go catch some!'));
    }

    // Display the list of pokemon names
    return ListView.builder(
      itemCount: folder.pokemons.length,
      itemBuilder: (ctx, index) {
        final pokemonName = folder.pokemons[index];
        return ListTile(
          title: Text(pokemonName.toUpperCase()),
          leading: const Icon(Icons.catching_pokemon_outlined),
          // --- UPDATED: Trailing now has a delete button ---
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _deletePokemon(context, pokemonName),
          ),
          onTap: () async {
            // --- Tap to see details ---
            try {
              // Show a loading spinner while we fetch the data
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) =>
                    const Center(child: CircularProgressIndicator()),
              );

              // Call the *pokemon* api service
              final Pokemon pokemonData =
                  await _pokemonApiService.getPokemonByName(pokemonName);

              if (mounted) Navigator.of(context).pop(); // Close spinner

              // Navigate to the detail screen
              if (mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) =>
                        PokemonDetailScreen(pokemon: pokemonData),
                  ),
                );
              }
            } catch (e) {
              if (mounted) Navigator.of(context).pop(); // Close spinner on error
              // Show error
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  // --- Tab 2 Builder: "My Badges" ---
  Widget _buildBadgesTab(BuildContext context, List<UserBadge> badges) {
    if (badges.isEmpty) {
      // --- UPDATED: Wrap in Column to hold Delete Account button ---
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have not collected any badges.'),
            const SizedBox(height: 40),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              icon: const Icon(Icons.warning_amber),
              label: const Text('Delete Account'),
              onPressed: () => _deleteAccount(context),
            ),
          ],
        ),
      );
    }

    // --- UPDATED: Wrap ListView in a Column to add button at the bottom ---
    return Column(
      children: [
        // The list of badges
        Expanded(
          child: ListView.builder(
            itemCount: badges.length,
            itemBuilder: (ctx, index) {
              final badge = badges[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.shield_outlined,
                      color: Colors.blue, size: 40),
                  title: Text(badge.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(badge.gym),
                  // --- UPDATED: Trailing now has date AND delete button ---
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        // Format the date to be more readable
                        '${badge.collectedAt.day}/${badge.collectedAt.month}/${badge.collectedAt.year}',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent),
                        onPressed: () => _deleteBadge(context, badge),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // --- NEW: Delete Account Button ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            icon: const Icon(Icons.warning_amber),
            label: const Text('Delete Account'),
            onPressed: () => _deleteAccount(context),
          ),
        )
      ],
    );
  }
}