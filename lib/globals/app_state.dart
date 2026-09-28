import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brutal_wallz/globals/themes.dart';
import 'package:brutal_wallz/models/wallpaper_model.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:provider/provider.dart';

@NowaGenerated()
class AppState extends ChangeNotifier {
  AppState();

  factory AppState.of(BuildContext context, {bool listen = true}) {
    return Provider.of<AppState>(context, listen: listen);
  }

  ThemeData _theme = lightTheme;

  ThemeData get theme {
    return _theme;
  }

  void changeTheme(ThemeData theme) {
    _theme = theme;
    notifyListeners();
  }

  List<WallpaperModel> wallpapers = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchWallpapers() async {
    if (wallpapers.isNotEmpty || isLoading) return; // Already fetched

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final jsonString = await rootBundle.loadString('assets/wallpapers.json');
      final List<dynamic> data = jsonDecode(jsonString) as List<dynamic>;
      wallpapers = data
          .map((json) => WallpaperModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching wallpapers: $e');
      error = "FAILED TO FETCH WALLS!";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
