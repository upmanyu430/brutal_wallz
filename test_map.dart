// ignore_for_file: avoid_print

import 'package:brutal_wallz/models/wallpaper_model.dart';

/// Standalone test script to verify mapping a sample JSON dictionary to [WallpaperModel].
void main() {
  // Sample mocked data list representing an API response
  List<dynamic> data = [
    {
      'id': 123,
      'path': 'http',
      'thumbs': {'large': 'http'}
    }
  ];

  // Map each item using WallpaperModel.fromJson factory
  var wallpapers = data.map((json) => WallpaperModel.fromJson(json as Map<String, dynamic>)).toList();

  // Print mapped model instances
  print(wallpapers);
}
