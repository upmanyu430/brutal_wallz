import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:brutal_wallz/models/wallpaper_model.dart';

void main() {
  test('fetch real api', () async {
    final dio = Dio();
    try {
      final response = await dio.get('https://wallhaven.cc/api/v1/search?sorting=random');
      final List<dynamic> data = response.data['data'];
      List<WallpaperModel> wallpapers = data.map((json) => WallpaperModel.fromJson(json)).toList();
      print('wallpapers length: \${wallpapers.length}');
    } catch (e, stack) {
      print('Error: \$e');
      print('Stack: \$stack');
      fail('API failed: \$e');
    }
  });
}
