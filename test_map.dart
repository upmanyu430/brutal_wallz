import 'package:brutal_wallz/models/wallpaper_model.dart';
void main() {
  List<dynamic> data = [{'id': 123, 'path': 'http', 'thumbs': {'large': 'http'}}];
  var wallpapers = data.map((json) => WallpaperModel.fromJson(json)).toList();
  print(wallpapers);
}
