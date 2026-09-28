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
    final category = json['category']?.toString() ??
        json['cat']?.toString() ??
        categories[id.hashCode % categories.length];

    final image = json['imagePath']?.toString() ??
        json['path']?.toString() ??
        json['imageUrl']?.toString() ??
        '';

    final thumb = json['thumbnailPath']?.toString() ??
        (json['thumbs'] is Map<String, dynamic>
            ? (json['thumbs'] as Map<String, dynamic>)['large']?.toString()
            : null) ??
        json['thumbnailUrl']?.toString() ??
        image;

    return WallpaperModel(
      id: id,
      title: json['title']?.toString() ?? 'Wallhaven - $id',
      cat: category,
      imageUrl: image,
      thumbnailUrl: thumb,
    );
  }

  final String id;
  final String title;
  final String cat;
  final String imageUrl;
  final String thumbnailUrl;

  String get category => cat;
  String get imagePath => imageUrl;
  String get thumbnailPath => thumbnailUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': cat,
      'imagePath': imageUrl,
      'thumbnailPath': thumbnailUrl,
    };
  }
}
