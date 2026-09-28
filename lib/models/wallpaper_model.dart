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
    final categories = ['general', 'anime', 'people'];
    
    return WallpaperModel(
      id: id,
      title: 'Wallhaven - $id',
      cat: json['category']?.toString() ?? categories[id.hashCode % categories.length],
      imageUrl: json['path'] as String,
      thumbnailUrl: (json['thumbs'] as Map<String, dynamic>?)?['large'] as String? ?? '',
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
