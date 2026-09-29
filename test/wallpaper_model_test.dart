import 'package:flutter_test/flutter_test.dart';
import 'package:brutal_wallz/models/wallpaper_model.dart';
import 'package:brutal_wallz/globals/app_state.dart';

/// Unit tests for [WallpaperModel] serialization and [AppState] initialization.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WallpaperModel', () {
    test('fromJson correctly parses bundled wallpapers.json format', () {
      // Sample JSON fixture mimicking bundled offline assets
      final json = {
        'id': 'pokzv3',
        'title': 'Wallhaven - pokzv3',
        'category': 'general',
        'imagePath': 'assets/wallpapers/pokzv3.jpg',
        'thumbnailPath': 'assets/wallpapers/pokzv3.jpg',
      };

      final model = WallpaperModel.fromJson(json);

      // Verify deserialized field mappings and getters
      expect(model.id, 'pokzv3');
      expect(model.title, 'Wallhaven - pokzv3');
      expect(model.cat, 'general');
      expect(model.category, 'general');
      expect(model.imageUrl, 'assets/wallpapers/pokzv3.jpg');
      expect(model.imagePath, 'assets/wallpapers/pokzv3.jpg');
      expect(model.thumbnailUrl, 'assets/wallpapers/pokzv3.jpg');
      expect(model.thumbnailPath, 'assets/wallpapers/pokzv3.jpg');
    });

    test('fromJson correctly parses Wallhaven response with category', () {
      // Sample JSON fixture mimicking remote Wallhaven API payload
      final json = {
        'id': '9m9x9w',
        'category': 'anime',
        'path': 'https://w.wallhaven.cc/full/9m/wallhaven-9m9x9w.jpg',
        'thumbs': {
          'large': 'https://th.wallhaven.cc/lg/9m/9m9x9w.jpg',
          'original': 'https://th.wallhaven.cc/orig/9m/9m9x9w.jpg',
          'small': 'https://th.wallhaven.cc/small/9m/9m9x9w.jpg',
        },
      };

      final model = WallpaperModel.fromJson(json);

      expect(model.id, '9m9x9w');
      expect(model.title, 'Wallhaven - 9m9x9w');
      expect(model.cat, 'anime');
      expect(model.imageUrl, 'https://w.wallhaven.cc/full/9m/wallhaven-9m9x9w.jpg');
      expect(model.thumbnailUrl, 'https://th.wallhaven.cc/lg/9m/9m9x9w.jpg');
    });

    test('fromJson falls back to category list when category is null', () {
      // Fixture with omitted category field
      final json = {
        'id': 'abc123',
        'path': 'https://w.wallhaven.cc/full/ab/wallhaven-abc123.jpg',
        'thumbs': {
          'large': 'https://th.wallhaven.cc/lg/ab/abc123.jpg',
        },
      };

      final model = WallpaperModel.fromJson(json);

      expect(model.id, 'abc123');
      expect(model.title, 'Wallhaven - abc123');
      // Confirm that fallback assigns a valid category option
      final validCategories = ['general', 'anime', 'people'];
      expect(validCategories.contains(model.cat), isTrue);
      expect(model.imageUrl, 'https://w.wallhaven.cc/full/ab/wallhaven-abc123.jpg');
      expect(model.thumbnailUrl, 'https://th.wallhaven.cc/lg/ab/abc123.jpg');
    });

    test('toJson generates correct map', () {
      // Model instance
      const model = WallpaperModel(
        id: '123',
        title: 'Wallhaven - 123',
        cat: 'Space',
        imageUrl: 'assets/wallpapers/123.jpg',
        thumbnailUrl: 'assets/wallpapers/123.jpg',
      );

      final json = model.toJson();

      // Ensure JSON keys match expected output schema
      expect(json, {
        'id': '123',
        'title': 'Wallhaven - 123',
        'category': 'Space',
        'imagePath': 'assets/wallpapers/123.jpg',
        'thumbnailPath': 'assets/wallpapers/123.jpg',
      });
    });
  });

  group('AppState', () {
    test('initial state has empty wallpapers and false loading', () {
      final appState = AppState();
      // Verify initial default property values
      expect(appState.wallpapers, isEmpty);
      expect(appState.isLoading, isFalse);
      expect(appState.error, isNull);
    });
  });
}
