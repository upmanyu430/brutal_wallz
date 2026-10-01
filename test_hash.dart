// ignore_for_file: avoid_print

/// Standalone test script to verify String hashCode behaviour and modulo arithmetic
/// used for category assignment fallbacks in [WallpaperModel.fromJson].
void main() {
  // Test raw hash code generation for a string
  print('hello'.hashCode);

  // Test non-negative modulo distribution for category index mapping
  print('hello'.hashCode % 3);

  // Demonstrate Dart's truncated modulo behavior for negative numbers
  print((-5) % 3);
}
