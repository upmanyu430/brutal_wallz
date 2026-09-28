import 'package:flutter_test/flutter_test.dart';
import 'package:brutal_wallz/globals/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('test fetchWallpapers loads offline wallpapers successfully', () async {
    final state = AppState();
    await state.fetchWallpapers();
    expect(state.error, isNull);
    expect(state.wallpapers.isNotEmpty, isTrue);
    expect(state.isLoading, isFalse);
    expect(state.wallpapers.length, greaterThanOrEqualTo(20));
    final first = state.wallpapers.first;
    expect(first.id, isNotEmpty);
    expect(first.title, isNotEmpty);
    expect(first.cat, isNotEmpty);
    expect(first.imageUrl, startsWith('assets/wallpapers/'));
    expect(first.thumbnailUrl, startsWith('assets/wallpapers/'));
  });

  test('fetchWallpapers does not reload if already populated', () async {
    final state = AppState();
    await state.fetchWallpapers();
    final count = state.wallpapers.length;
    await state.fetchWallpapers();
    expect(state.wallpapers.length, count);
  });
}
