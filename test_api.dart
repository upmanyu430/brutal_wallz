import 'package:dio/dio.dart';
import 'package:brutal_wallz/models/wallpaper_model.dart';

void main() async {
  final dio = Dio();
  try {
    final response = await dio.get('https://wallhaven.cc/api/v1/search?sorting=random');
    final List<dynamic> data = response.data['data'];
    print('Length: ' + data.length.toString());
    for (var json in data) {
      final model = WallpaperModel.fromJson(json);
      print('Model mapped: ' + model.id);
    }
    print('All mapped successfully');
  } catch (e) {
    print('Error: ' + e.toString());
  }
}
