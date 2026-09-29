// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:brutal_wallz/models/wallpaper_model.dart';

/// Integration test verifying network connectivity and live data deserialization
/// against the public Wallhaven search API.
void main() {
  test('fetch real api', () async {
    // Initialize Dio HTTP client
    final dio = Dio();
    try {
      // Query Wallhaven API for random wallpapers
      final response = await dio.get('https://wallhaven.cc/api/v1/search?sorting=random');
      final List<dynamic> data = response.data['data'];

      // Deserialize each item into WallpaperModel
      List<WallpaperModel> wallpapers =
          data.map((json) => WallpaperModel.fromJson(json as Map<String, dynamic>)).toList();
      print('wallpapers length: ${wallpapers.length}');

      // Verify that parsed collection is non-empty
      expect(wallpapers.isNotEmpty, isTrue);
    } catch (e, stack) {
      print('Error: $e');
      print('Stack: $stack');
      fail('API failed: $e');
    }
  });
}
