import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Asset integrity tests ensuring the bundled `assets/wallpapers.json` exists,
/// is valid JSON, contains at least 20 wallpaper items, and that every referenced
/// image and thumbnail actually exists on disk and is non-empty.
void main() {
  test('wallpapers.json and bundled wallpaper images exist and are valid', () {
    // 1. Verify existence of metadata JSON bundle
    final jsonFile = File('assets/wallpapers.json');
    expect(jsonFile.existsSync(), isTrue, reason: 'assets/wallpapers.json should exist');

    // 2. Parse and decode JSON content
    final jsonContent = jsonFile.readAsStringSync();
    final dynamic decoded = jsonDecode(jsonContent);
    expect(decoded, isA<List<dynamic>>(), reason: 'JSON content should be a list');

    final list = decoded as List<dynamic>;
    // Ensure dataset contains at least 20 curated wallpapers
    expect(list.length, greaterThanOrEqualTo(20), reason: 'Should have at least 20 wallpapers');

    // 3. Inspect each entry's required attributes and linked asset files
    for (final item in list) {
      expect(item, isA<Map<String, dynamic>>());
      final map = item as Map<String, dynamic>;

      // Validate required schema properties
      expect(map['id'], isNotEmpty);
      expect(map['title'], isNotEmpty);
      expect(map['category'], isNotEmpty);
      expect(map['imagePath'], isNotEmpty);
      expect(map['thumbnailPath'], isNotEmpty);

      // Verify that full-resolution image exists on disk and has non-zero size
      final imageFile = File(map['imagePath'] as String);
      expect(imageFile.existsSync(), isTrue, reason: '${map['imagePath']} should exist on disk');
      expect(imageFile.lengthSync(), greaterThan(0), reason: '${map['imagePath']} should not be empty');

      // Verify that thumbnail image exists on disk and has non-zero size
      final thumbFile = File(map['thumbnailPath'] as String);
      expect(thumbFile.existsSync(), isTrue, reason: '${map['thumbnailPath']} should exist on disk');
      expect(thumbFile.lengthSync(), greaterThan(0), reason: '${map['thumbnailPath']} should not be empty');
    }
  });
}
