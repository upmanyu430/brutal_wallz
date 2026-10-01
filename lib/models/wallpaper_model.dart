/// Data model representing a wallpaper item.
/// Supports ingestion from both local asset datasets (`assets/wallpapers.json`)
/// and remote Wallhaven API response structures.
class WallpaperModel {
  /// Constructs an immutable [WallpaperModel] instance.
  const WallpaperModel({
    required this.id,
    required this.title,
    required this.cat,
    required this.imageUrl,
    required this.thumbnailUrl,
  });

  /// Factory constructor to deserialize a [WallpaperModel] from a JSON map.
  /// Handles field aliases and fallbacks between offline assets and Wallhaven API schema.
  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final categories = ['general', 'anime', 'people'];

    // Resolve category with fallback to deterministic hash-based selection if unassigned
    final category = json['category']?.toString() ??
        json['cat']?.toString() ??
        categories[id.hashCode % categories.length];

    // Resolve primary high-resolution image path / URL across different payload formats
    final image = json['imagePath']?.toString() ??
        json['path']?.toString() ??
        json['imageUrl']?.toString() ??
        '';

    // Resolve thumbnail image path / URL (falling back to thumbs.large or primary image)
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

  /// Unique identifier of the wallpaper (e.g. Wallhaven ID).
  final String id;

  /// Display title or descriptive label for the wallpaper.
  final String title;

  /// Primary aesthetic or subject category (e.g. 'general', 'anime', 'people').
  final String cat;

  /// Asset path or network URL for the full-resolution wallpaper image.
  final String imageUrl;

  /// Asset path or network URL for the preview thumbnail image.
  final String thumbnailUrl;

  /// Semantic alias for [cat].
  String get category => cat;

  /// Semantic alias for [imageUrl].
  String get imagePath => imageUrl;

  /// Semantic alias for [thumbnailUrl].
  String get thumbnailPath => thumbnailUrl;

  /// Serializes the wallpaper model into a JSON-compatible map.
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
