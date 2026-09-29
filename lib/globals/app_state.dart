import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brutal_wallz/globals/themes.dart';
import 'package:brutal_wallz/models/wallpaper_model.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:provider/provider.dart';

/// Global application state manager responsible for theme management,
/// wallpaper asset loading, and notifying listeners of state updates.
@NowaGenerated()
class AppState extends ChangeNotifier {
  /// Default constructor for [AppState].
  AppState();

  /// Convenience accessor to retrieve the [AppState] instance from the widget tree.
  /// Set [listen] to `false` when reading state outside of a widget's build method
  /// (e.g. inside event handlers or lifecycle callbacks).
  factory AppState.of(BuildContext context, {bool listen = true}) {
    return Provider.of<AppState>(context, listen: listen);
  }

  /// Internal theme state variable, defaulting to neo-brutalist light theme.
  ThemeData _theme = lightTheme;

  /// Current active [ThemeData] applied across the app.
  ThemeData get theme {
    return _theme;
  }

  /// Updates the active theme and notifies all dependent UI listeners to rebuild.
  void changeTheme(ThemeData theme) {
    _theme = theme;
    notifyListeners();
  }

  /// In-memory cache of loaded wallpaper models.
  List<WallpaperModel> wallpapers = [];

  /// Indicates whether wallpapers are actively being fetched or decoded.
  bool isLoading = false;

  /// Holds an error description if the wallpaper fetching operation fails; otherwise null.
  String? error;

  /// Loads bundled wallpaper metadata from local assets (`assets/wallpapers.json`).
  /// Prevents redundant fetches if data is already loaded or in progress.
  Future<void> fetchWallpapers() async {
    // Short-circuit if data has already been retrieved or an operation is in flight
    if (wallpapers.isNotEmpty || isLoading) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Read the bundled wallpapers JSON file from application asset bundle
      final jsonString = await rootBundle.loadString('assets/wallpapers.json');

      // Decode the raw JSON string into a list of dynamic map objects
      final List<dynamic> data = jsonDecode(jsonString) as List<dynamic>;

      // Map each JSON entry to a strongly typed WallpaperModel instance
      wallpapers = data
          .map((json) => WallpaperModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Log errors in debug mode and record a user-friendly error message
      debugPrint('Error fetching wallpapers: $e');
      error = "FAILED TO FETCH WALLS!";
    } finally {
      // Ensure loading state is reset and UI listeners are notified of completion
      isLoading = false;
      notifyListeners();
    }
  }
}
