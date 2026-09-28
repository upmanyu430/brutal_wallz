import 'package:flutter_test/flutter_test.dart';
import 'package:brutal_wallz/globals/app_state.dart';

void main() {
  test('test fetchWallpapers', () async {
    final state = AppState();
    await state.fetchWallpapers();
    print('Error: \${state.error}');
    print('Wallpapers length: \${state.wallpapers.length}');
    expect(state.error, isNull);
    expect(state.wallpapers.isNotEmpty, true);
  });
}
