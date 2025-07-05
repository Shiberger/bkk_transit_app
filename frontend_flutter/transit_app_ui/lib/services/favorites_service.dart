import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// A model to represent a single saved favorite route
class FavoriteRoute {
  final String startStationId;
  final String startStationName;
  final String endStationId;
  final String endStationName;

  FavoriteRoute({
    required this.startStationId,
    required this.startStationName,
    required this.endStationId,
    required this.endStationName,
  });

  // Convert a FavoriteRoute into a Map so it can be JSON encoded
  Map<String, dynamic> toJson() => {
        'startStationId': startStationId,
        'startStationName': startStationName,
        'endStationId': endStationId,
        'endStationName': endStationName,
      };

  // Create a FavoriteRoute from a Map (after JSON decoding)
  factory FavoriteRoute.fromJson(Map<String, dynamic> json) => FavoriteRoute(
        startStationId: json['startStationId'],
        startStationName: json['startStationName'],
        endStationId: json['endStationId'],
        endStationName: json['endStationName'],
      );
}

// This service class handles all the logic for saving/loading from the device
class FavoritesService {
  static const _key = 'favoriteRoutes';

  Future<List<FavoriteRoute>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritesJson = prefs.getStringList(_key) ?? [];
    return favoritesJson
        .map((fav) => FavoriteRoute.fromJson(jsonDecode(fav)))
        .toList();
  }

  Future<void> addFavorite(FavoriteRoute route) async {
    final prefs = await SharedPreferences.getInstance();
    final List<FavoriteRoute> favorites = await getFavorites();
    // Avoids adding a duplicate route
    if (!favorites.any((fav) =>
        fav.startStationId == route.startStationId &&
        fav.endStationId == route.endStationId)) {
      favorites.add(route);
      await _save(prefs, favorites);
    }
  }

  Future<void> removeFavorite(FavoriteRoute route) async {
    final prefs = await SharedPreferences.getInstance();
    List<FavoriteRoute> favorites = await getFavorites();
    favorites.removeWhere((fav) =>
        fav.startStationId == route.startStationId &&
        fav.endStationId == route.endStationId);
    await _save(prefs, favorites);
  }

  // Private helper to save the list back to shared_preferences
  Future<void> _save(SharedPreferences prefs, List<FavoriteRoute> favorites) async {
    final List<String> favoritesJson =
        favorites.map((fav) => jsonEncode(fav.toJson())).toList();
    await prefs.setStringList(_key, favoritesJson);
  }
}