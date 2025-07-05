import 'package:flutter/material.dart';
import '../models/route_result.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import 'route_display_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final ApiService _apiService = ApiService();
  late Future<List<FavoriteRoute>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoritesFuture = _favoritesService.getFavorites();
    });
  }

  void _deleteFavorite(FavoriteRoute route) async {
    // Optional: Show a confirmation dialog before deleting
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Favorite?'),
        content: Text('Are you sure you want to delete the route from ${route.startStationName} to ${route.endStationName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await _favoritesService.removeFavorite(route);
      _loadFavorites(); // Refresh the list
    }
  }

  void _searchFavoriteRoute(FavoriteRoute route) async {
    // Show a loading dialog while we fetch the route
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Use the fastest route preference by default for favorites
      final RouteResult result = await _apiService.findRoute(
        route.startStationId,
        route.endStationId,
        'fastest',
      );
      
      Navigator.pop(context); // Close the loading dialog
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RouteDisplayScreen(
              routeResult: result,
              startStationId: route.startStationId,
              endStationId: route.endStationId,
            ),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error finding route: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Routes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<FavoriteRoute>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'You have no saved routes yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final favorites = snapshot.data!;
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final route = favorites[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red, size: 30),
                  title: Text('${route.startStationName} to ${route.endStationName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Tap to view route, swipe to delete'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    tooltip: 'Delete Favorite',
                    onPressed: () => _deleteFavorite(route),
                  ),
                  onTap: () => _searchFavoriteRoute(route),
                ),
              );
            },
          );
        },
      ),
    );
  }
}