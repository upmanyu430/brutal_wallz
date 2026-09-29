# Plan to Add Ubuntu Sans Mono Bold Font

## Global Constraints
- Target Framework: Flutter
- Font: Ubuntu Sans Mono
- Weight: Bold
- Ensure it affects both `lightTheme` and `darkTheme` in `lib/globals/themes.dart`.

## Tasks

### Task 1: Make typography bold in `themes.dart`
Modify `lib/globals/themes.dart` so that `lightTheme` and `darkTheme` both use `Ubuntu Sans Mono Bold` for all text across the whole UI. Currently they use `GoogleFonts.ubuntuSansMonoTextTheme()` which defaults to regular weight. You must ensure the text theme returned applies `FontWeight.bold` to all text styles (for example, by mapping the existing text styles and applying `.copyWith(fontWeight: FontWeight.bold)` or using `.apply()` if that works for weight).
