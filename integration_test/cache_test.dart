import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brutal_wallz/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-end test for Cache Calculation and Clearing', (tester) async {
    // Launch the app
    SharedPreferences.setMockInitialValues({'has_logged_in': true});
    app.main();
    await tester.pumpAndSettle();

    // Switch to Settings tab
    final settingsNavFinder = find.byIcon(Icons.settings);
    expect(settingsNavFinder, findsOneWidget);
    await tester.tap(settingsNavFinder);
    await tester.pumpAndSettle();

    // Tap Storage & Cache to open dialog
    final storageFinder = find.text('Storage & Cache');
    expect(storageFinder, findsOneWidget);
    await tester.tap(storageFinder);
    await tester.pumpAndSettle();

    // Tap CLEAR CACHE
    final clearCacheButton = find.text('CLEAR CACHE');
    expect(clearCacheButton, findsOneWidget);
    await tester.tap(clearCacheButton);
    await tester.pumpAndSettle();

    // Wait briefly for dialog animations and toast to appear
    await tester.pump(const Duration(seconds: 1));

    // Verify toast or updated dialog state
    expect(find.text('CACHE CLEARED!'), findsOneWidget);
  });
}
