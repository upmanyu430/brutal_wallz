import 'package:flutter_test/flutter_test.dart';
import 'package:brutal_wallz/models/wallpaper_model.dart';
import 'package:brutal_wallz/globals/app_state.dart';

void main() {
  group('WallpaperModel', () {
    test('fromJson correctly parses Wallhaven response with category', () {
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
      final validCategories = ['general', 'anime', 'people'];
      expect(validCategories.contains(model.cat), isTrue);
      expect(model.imageUrl, 'https://w.wallhaven.cc/full/ab/wallhaven-abc123.jpg');
      expect(model.thumbnailUrl, 'https://th.wallhaven.cc/lg/ab/abc123.jpg');
    });

    test('toJson generates correct map', () {
      const model = WallpaperModel(
        id: '123',
        title: 'Wallhaven - 123',
        cat: 'Space',
        imageUrl: 'https://example.com/image.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
      );

      final json = model.toJson();

      expect(json, {
        'id': '123',
        'title': 'Wallhaven - 123',
        'cat': 'Space',
        'imageUrl': 'https://example.com/image.jpg',
        'thumbnailUrl': 'https://example.com/thumb.jpg',
      });
    });
  });

  group('AppState', () {
    test('initial state has empty wallpapers and false loading', () {
      final appState = AppState();
      expect(appState.wallpapers, isEmpty);
      expect(appState.isLoading, isFalse);
      expect(appState.error, isNull);
    });
  });
}
