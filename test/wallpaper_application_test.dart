import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:brutal_wallz/globals/app_state.dart';
import 'package:brutal_wallz/pages/home_page.dart';

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

  group('Wallpaper Application & State Resilience', () {
    testWidgets('Tapping SET AS WALLPAPER opens bottom sheet and options are clickable',
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

      // Settle toast timer
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verify button returns to SET AS WALLPAPER and is re-enabled
      expect(find.text('SET AS WALLPAPER'), findsOneWidget);
    });

    testWidgets('Lock Screen option applies and re-enables UI',
        (WidgetTester tester) async {
      await setupHomePageTest(tester);

      await tester.tap(find.byType(Image).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('SET AS WALLPAPER'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('LOCK SCREEN'));
      await tester.pumpAndSettle();

      expect(find.text('APPLIED TO LOCK SCREEN!'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('SET AS WALLPAPER'), findsOneWidget);
    });

    testWidgets('Both option applies and re-enables UI',
        (WidgetTester tester) async {
      await setupHomePageTest(tester);

      await tester.tap(find.byType(Image).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('SET AS WALLPAPER'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('BOTH'));
      await tester.pumpAndSettle();

      expect(find.text('APPLIED TO BOTH!'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('SET AS WALLPAPER'), findsOneWidget);
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
