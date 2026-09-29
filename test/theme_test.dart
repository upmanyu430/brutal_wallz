import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brutal_wallz/globals/themes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('lightTheme and darkTheme text themes have bold font weight', () {
    for (final theme in [lightTheme, darkTheme]) {
      final textTheme = theme.textTheme;
      final styles = [
        textTheme.displayLarge,
        textTheme.displayMedium,
        textTheme.displaySmall,
        textTheme.headlineLarge,
        textTheme.headlineMedium,
        textTheme.headlineSmall,
        textTheme.titleLarge,
        textTheme.titleMedium,
        textTheme.titleSmall,
        textTheme.bodyLarge,
        textTheme.bodyMedium,
        textTheme.bodySmall,
        textTheme.labelLarge,
        textTheme.labelMedium,
        textTheme.labelSmall,
      ];

      for (final style in styles) {
        expect(style, isNotNull);
        expect(style!.fontWeight, equals(FontWeight.bold));
        expect(style.fontFamily, contains('UbuntuSansMono'));
      }
    }
  });
}
