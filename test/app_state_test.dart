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

  test('loadMore and refreshWallpapers methods complete successfully', () async {
    final state = AppState();
    await expectLater(state.loadMore(), completes);
    await expectLater(state.refreshWallpapers(), completes);
  });

  test('loadMore increments currentPage and appends slice of wallpapers', () async {
    final state = AppState();
    await state.fetchWallpapers();
    final initialCount = state.wallpapers.length;
    expect(state.currentPage, 1);
    expect(state.isFetchingMore, isFalse);

    final future = state.loadMore();
    expect(state.isFetchingMore, isTrue);
    await future;

    expect(state.isFetchingMore, isFalse);
    expect(state.currentPage, 2);
    expect(state.wallpapers.length, initialCount + 6);
  });

  test('loadMore short-circuits when isLoading or isFetchingMore is true', () async {
    final state = AppState();
    state.isLoading = true;
    await state.loadMore();
    expect(state.currentPage, 1);
    expect(state.isFetchingMore, isFalse);
  });

  test('refreshWallpapers resets currentPage and reloads initial wallpapers', () async {
    final state = AppState();
    await state.fetchWallpapers();
    final initialCount = state.wallpapers.length;

    // Simulate paginated state
    await state.loadMore();
    expect(state.currentPage, 2);
    expect(state.wallpapers.length, initialCount + 6);

    // Refresh collection
    await state.refreshWallpapers();
    expect(state.currentPage, 1);
    expect(state.wallpapers.length, initialCount);
    expect(state.isLoading, isFalse);
    expect(state.isFetchingMore, isFalse);
  });
}

