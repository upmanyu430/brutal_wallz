import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Neo-brutalist light theme configuration.
/// Uses an off-white/cream paper background (`0xFFF4F0E6`) and monospace typography
/// ([GoogleFonts.ubuntuSansMono]) for raw, retro-industrial computer aesthetic.
final ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: const Color(0xFFF4F0E6),
  colorScheme: const ColorScheme.light(
    surface: Color(0xFFF4F0E6),
  ),
  textTheme: _makeBold(GoogleFonts.ubuntuSansMonoTextTheme()),
);

/// Neo-brutalist dark theme configuration.
/// Pairs dark background tones with high-contrast monospace typography.
final ThemeData darkTheme = ThemeData(
  colorScheme: const ColorScheme.dark(),
  textTheme: _makeBold(
      GoogleFonts.ubuntuSansMonoTextTheme(ThemeData.dark().textTheme)),
);

TextTheme _makeBold(TextTheme textTheme) {
  return textTheme.copyWith(
    displayLarge: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
    displayMedium:
        textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
    displaySmall: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
    headlineLarge:
        textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
    headlineMedium:
        textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
    headlineSmall:
        textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    titleSmall: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
    bodyLarge: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
    bodyMedium: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
    bodySmall: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
    labelLarge: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
    labelMedium: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
    labelSmall: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
  );
}
