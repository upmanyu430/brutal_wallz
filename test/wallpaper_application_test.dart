import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brutal_wallz/globals/app_state.dart';
import 'package:brutal_wallz/globals/router.dart';
import 'package:brutal_wallz/main.dart';
import 'package:brutal_wallz/pages/home_page.dart';
import 'package:brutal_wallz/pages/login_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestWidget(AppState appState) {
    return ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: const MaterialApp(
        home: HomePage(),
      ),
    );
  }

  Future<AppState> setupHomePageTest(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appState = AppState();
    await tester.runAsync(() async {
      await appState.fetchWallpapers();
    });

    await tester.pumpWidget(buildTestWidget(appState));
    await tester.pumpAndSettle();

    return appState;
  }

  group('Wallpaper Application & Navigation Resilience', () {
    testWidgets(
        'Tapping SET AS WALLPAPER opens bottom sheet, applies to HOME SCREEN, and pops back to previous gallery screen',
        (WidgetTester tester) async {
      await setupHomePageTest(tester);

      // Open first wallpaper modal
      await tester.tap(find.byType(Image).first);
      await tester.pumpAndSettle();

      // Tap SET AS WALLPAPER
      expect(find.text('SET AS WALLPAPER'), findsOneWidget);
      await tester.tap(find.text('SET AS WALLPAPER'));
      await tester.pumpAndSettle();

      // Verify bottom sheet options
      expect(find.text('APPLY TO:'), findsOneWidget);
      expect(find.text('HOME SCREEN'), findsOneWidget);
      expect(find.text('LOCK SCREEN'), findsOneWidget);
      expect(find.text('BOTH'), findsOneWidget);

      // Tap HOME SCREEN option
      await tester.tap(find.text('HOME SCREEN'));
      await tester.pumpAndSettle();

      // Verify applied toast is visible and bottom sheet is closed
      expect(find.text('APPLIED TO HOME SCREEN!'), findsOneWidget);
      expect(find.text('APPLY TO:'), findsNothing);

      // Verify the wallpaper modal has popped back to the previous screen (gallery)
      expect(find.text('SET AS WALLPAPER'), findsNothing);
      expect(find.text('SEARCH AESTHETICS'), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);

      // Settle toast dismiss timer
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Lock Screen option applies wallpaper and pops back to previous gallery screen',
        (WidgetTester tester) async {
      await setupHomePageTest(tester);

      await tester.tap(find.byType(Image).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('SET AS WALLPAPER'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('LOCK SCREEN'));
      await tester.pumpAndSettle();

      expect(find.text('APPLIED TO LOCK SCREEN!'), findsOneWidget);
      expect(find.text('APPLY TO:'), findsNothing);

      // Verify popped back to previous screen
      expect(find.text('SET AS WALLPAPER'), findsNothing);
      expect(find.text('SEARCH AESTHETICS'), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);

      // Settle toast dismiss timer
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Both option applies wallpaper and pops back to previous gallery screen',
        (WidgetTester tester) async {
      await setupHomePageTest(tester);

      await tester.tap(find.byType(Image).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('SET AS WALLPAPER'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('BOTH'));
      await tester.pumpAndSettle();

      expect(find.text('APPLIED TO BOTH!'), findsOneWidget);
      expect(find.text('APPLY TO:'), findsNothing);

      // Verify popped back to previous screen
      expect(find.text('SET AS WALLPAPER'), findsNothing);
      expect(find.text('SEARCH AESTHETICS'), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);

      // Settle toast dismiss timer
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets(
        'System back gesture while modal is open pops back to previous gallery screen instead of exiting app',
        (WidgetTester tester) async {
      await setupHomePageTest(tester);

      // Open first wallpaper modal
      await tester.tap(find.byType(Image).first);
      await tester.pumpAndSettle();
      expect(find.text('SET AS WALLPAPER'), findsOneWidget);

      // Simulate system hardware back button
      final didPop = await tester.binding.handlePopRoute();
      expect(didPop, isTrue);
      await tester.pumpAndSettle();

      // Assert modal cleanly popped back to previous screen
      expect(find.text('SET AS WALLPAPER'), findsNothing);
      expect(find.text('SEARCH AESTHETICS'), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets(
        'Setting wallpaper in GoRouter app stack returns to HomePage and does not exit or reset to login',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({'has_logged_in': true});
      sharedPrefs = await SharedPreferences.getInstance();

      final appState = AppState();
      await tester.runAsync(() async {
        await appState.fetchWallpapers();
      });

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify on HomePage gallery
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('SEARCH AESTHETICS'), findsOneWidget);

      // Open wallpaper
      await tester.tap(find.byType(Image).first);
      await tester.pumpAndSettle();
      expect(find.text('SET AS WALLPAPER'), findsOneWidget);

      // Apply wallpaper
      await tester.tap(find.text('SET AS WALLPAPER'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('HOME SCREEN'));
      await tester.pumpAndSettle();

      // Assert confirmation toast and return to gallery without reset or exit
      expect(find.text('APPLIED TO HOME SCREEN!'), findsOneWidget);
      expect(find.text('SET AS WALLPAPER'), findsNothing);
      expect(find.text('SEARCH AESTHETICS'), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);

      // Settle toast dismiss timer
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    test('Local asset byte loading extracts correctly to temporary storage', () async {
      final byteData = await rootBundle.load('assets/wallpapers/3662-1724947786586.jpg');
      expect(byteData.lengthInBytes, greaterThan(0));

      final tempDir = Directory.systemTemp.createTempSync('brutal_test');
      final tempFile = File('${tempDir.path}/test_extract.jpg');
      await tempFile.writeAsBytes(
        byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        flush: true,
      );

      expect(await tempFile.exists(), isTrue);
      expect(await tempFile.length(), equals(byteData.lengthInBytes));

      tempDir.deleteSync(recursive: true);
    });
  });
}
