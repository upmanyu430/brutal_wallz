import 'package:flutter/material.dart';
import 'package:brutal_wallz/globals/themes.dart';
import 'package:brutal_wallz/models/wallpaper_model.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

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
    if (wallpapers.isNotEmpty) return; // Already fetched

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final dio = Dio();
      final response = await dio.get('https://wallhaven.cc/api/v1/search?sorting=random');
      
      final List<dynamic> data = response.data['data'];
      wallpapers = data.map((json) => WallpaperModel.fromJson(json)).toList();
    } catch (e) {
      error = "FAILED TO FETCH WALLS!";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
