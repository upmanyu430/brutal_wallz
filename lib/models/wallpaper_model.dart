import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class WallpaperModel {
  const WallpaperModel({
    required this.id,
    required this.title,
    required this.cat,
    required this.imageUrl,
    required this.thumbnailUrl,
  });

  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final categories = ['Abstract', 'Minimal', 'Geometry', 'Space', 'Nature'];
    
    return WallpaperModel(
      id: id,
      title: json['author'] as String,
      cat: categories[int.parse(id) % categories.length],
      imageUrl: json['download_url'] as String,
      thumbnailUrl: 'https://picsum.photos/id/$id/400/600',
    );
  }

  final String id;
  final String title;
  final String cat;
  final String imageUrl;
  final String thumbnailUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cat': cat,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}
