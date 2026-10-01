import 'package:flutter_test/flutter_test.dart';
import 'package:brutal_wallz/globals/app_state.dart';

/// Unit tests for [AppState] verifying wallpaper bundle loading,
/// error management, and caching mechanisms.
void main() {
  // Ensure test widget environment is initialized before accessing rootBundle assets
  TestWidgetsFlutterBinding.ensureInitialized();

  test('test fetchWallpapers loads offline wallpapers successfully', () async {
    final state = AppState();

    // Trigger wallpaper fetch from bundled assets
    await state.fetchWallpapers();

    // Verify successful fetch state
    expect(state.error, isNull);
    expect(state.wallpapers.isNotEmpty, isTrue);
    expect(state.isLoading, isFalse);
    expect(state.wallpapers.length, greaterThanOrEqualTo(20));

    // Verify structure and paths of the first wallpaper item
    final first = state.wallpapers.first;
    expect(first.id, isNotEmpty);
    expect(first.title, isNotEmpty);
    expect(first.cat, isNotEmpty);
    expect(first.imageUrl, startsWith('assets/wallpapers/'));
    expect(first.thumbnailUrl, startsWith('assets/wallpapers/'));
  });

  test('fetchWallpapers does not reload if already populated', () async {
    final state = AppState();

    // First fetch loads the initial wallpaper list
    await state.fetchWallpapers();
    final count = state.wallpapers.length;

    // Subsequent fetch should short-circuit and avoid duplicate loading
    await state.fetchWallpapers();
    expect(state.wallpapers.length, count);
  });
}
