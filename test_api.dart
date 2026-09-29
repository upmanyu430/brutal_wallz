// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'package:dio/dio.dart';
import 'package:brutal_wallz/models/wallpaper_model.dart';

/// Standalone CLI test script to query Wallhaven API and verify
/// [WallpaperModel.fromJson] deserialization for each item returned.
void main() async {
  final dio = Dio();
  try {
    // Request random wallpapers from Wallhaven API
    final response = await dio.get('https://wallhaven.cc/api/v1/search?sorting=random');
    final List<dynamic> data = response.data['data'];
    print('Length: ' + data.length.toString());

    // Iterate through items and ensure each parses without runtime exception
    for (var json in data) {
      final model = WallpaperModel.fromJson(json as Map<String, dynamic>);
      print('Model mapped: ' + model.id);
    }
    print('All mapped successfully');
  } catch (e) {
    print('Error: ' + e.toString());
  }
}
