import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nowa_runtime/nowa_runtime.dart';

/// Neo-brutalist light theme configuration.
/// Uses an off-white/cream paper background (`0xFFF4F0E6`) and monospace typography
/// ([GoogleFonts.ubuntuSansMono]) for raw, retro-industrial computer aesthetic.
@NowaGenerated()
final ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: const Color(0xFFF4F0E6),
  colorScheme: const ColorScheme.light(
    surface: Color(0xFFF4F0E6),
  ),
  textTheme: GoogleFonts.ubuntuSansMonoTextTheme(),
);

/// Neo-brutalist dark theme configuration.
/// Pairs dark background tones with high-contrast monospace typography.
@NowaGenerated()
final ThemeData darkTheme = ThemeData(
  colorScheme: const ColorScheme.dark(),
  textTheme: GoogleFonts.ubuntuSansMonoTextTheme(ThemeData.dark().textTheme),
);
