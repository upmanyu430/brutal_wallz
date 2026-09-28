import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wallpapers.json and bundled wallpaper images exist and are valid', () {
    final jsonFile = File('assets/wallpapers.json');
    expect(jsonFile.existsSync(), isTrue, reason: 'assets/wallpapers.json should exist');

    final jsonContent = jsonFile.readAsStringSync();
    final dynamic decoded = jsonDecode(jsonContent);
    expect(decoded, isA<List<dynamic>>(), reason: 'JSON content should be a list');

    final list = decoded as List<dynamic>;
    expect(list.length, greaterThanOrEqualTo(20), reason: 'Should have at least 20 wallpapers');

    for (final item in list) {
      expect(item, isA<Map<String, dynamic>>());
      final map = item as Map<String, dynamic>;

      expect(map['id'], isNotEmpty);
      expect(map['title'], isNotEmpty);
      expect(map['category'], isNotEmpty);
      expect(map['imagePath'], isNotEmpty);
      expect(map['thumbnailPath'], isNotEmpty);

      final imageFile = File(map['imagePath'] as String);
      expect(imageFile.existsSync(), isTrue, reason: '${map['imagePath']} should exist on disk');
      expect(imageFile.lengthSync(), greaterThan(0), reason: '${map['imagePath']} should not be empty');

      final thumbFile = File(map['thumbnailPath'] as String);
      expect(thumbFile.existsSync(), isTrue, reason: '${map['thumbnailPath']} should exist on disk');
      expect(thumbFile.lengthSync(), greaterThan(0), reason: '${map['thumbnailPath']} should not be empty');
    }
  });
}
