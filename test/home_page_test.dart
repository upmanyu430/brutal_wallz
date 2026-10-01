import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:brutal_wallz/globals/app_state.dart';
import 'package:brutal_wallz/pages/home_page.dart';

/// Widget tests for [HomePage] verifying wallpaper grid rendering,
/// image caching configuration, full-screen detail modal interactions,
/// and navigation between modal and main views.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => Directory.systemTemp.path,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('async_wallpaper'),
      (MethodCall methodCall) async => true,
    );
  });

  /// Helper function to wrap [HomePage] in required [ChangeNotifierProvider] and [MaterialApp].
  Widget buildTestWidget(AppState appState) {
    return ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: const MaterialApp(
        home: HomePage(),
      ),
    );
  }

  /// Helper function to configure the viewport, initialize state, and pump the initial widget.
  Future<AppState> setupHomePageTest(WidgetTester tester) async {
    // Set fixed virtual viewport dimensions to simulate a standard mobile screen
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Pre-populate AppState with wallpapers from asset bundle
    final appState = AppState();
    await tester.runAsync(() async {
      await appState.fetchWallpapers();
    });

    // Pump widget tree and settle pending frames/animations
    await tester.pumpWidget(buildTestWidget(appState));
    await tester.pumpAndSettle();

    return appState;
  }

  testWidgets('HomePage renders offline wallpaper assets in grid and modal',
      (WidgetTester tester) async {
    final appState = await setupHomePageTest(tester);

    // 1. Verify wallpapers grid items are rendered as Image.asset with cacheWidth
    final imageFinder = find.byType(Image);
    expect(imageFinder, findsWidgets);

    final imageWidget = tester.widget<Image>(imageFinder.first);
    expect(imageWidget.image, isA<ResizeImage>());
    final resizeImage = imageWidget.image as ResizeImage;
    expect(resizeImage.imageProvider, isA<AssetImage>());
    expect(resizeImage.width, 300);
    expect(imageWidget.fit, BoxFit.cover);

    // 2. Tap on the first wallpaper in the grid to open the modal
    final firstImageFinder = find.byType(Image).first;
    expect(firstImageFinder, findsOneWidget);
    await tester.tap(firstImageFinder);
    await tester.pumpAndSettle();

    // Verify modal content is displayed with SET AS WALLPAPER button and download button
    expect(find.text('SET AS WALLPAPER'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_downward));
    await tester.pumpAndSettle();
    expect(find.text('WALLPAPER SAVED TO GALLERY!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    // Verify modal does not display the wallpaper title label
    expect(
        find.text(appState.wallpapers.first.title.toUpperCase()), findsNothing);

    // 3. Verify Modal has InteractiveViewer with AssetImage
    final interactiveViewerFinder = find.byType(InteractiveViewer);
    expect(interactiveViewerFinder, findsOneWidget);
    final interactiveViewer =
        tester.widget<InteractiveViewer>(interactiveViewerFinder);
    expect(interactiveViewer.minScale, 1.0);
    expect(interactiveViewer.maxScale, 4.0);

    final modalImageFinder = find.descendant(
      of: interactiveViewerFinder,
      matching: find.byType(Image),
    );
    expect(modalImageFinder, findsOneWidget);
    final modalImageWidget = tester.widget<Image>(modalImageFinder);
    expect((modalImageWidget.image as AssetImage).assetName,
        startsWith('assets/wallpapers/'));
    expect(modalImageWidget.fit, BoxFit.cover);

    // 4. Close the modal by tapping back button
    final backButtonFinder = find.byIcon(Icons.arrow_back);
    expect(backButtonFinder, findsOneWidget);
    await tester.tap(backButtonFinder);
    await tester.pumpAndSettle();
  });

  testWidgets(
      'HomePage displays bottom sheet with target options when tapping SET AS WALLPAPER',
      (WidgetTester tester) async {
    await setupHomePageTest(tester);

    final firstImageFinder = find.byType(Image).first;
    await tester.tap(firstImageFinder);
    await tester.pumpAndSettle();

    final setWallpaperBtn = find.text('SET AS WALLPAPER');
    expect(setWallpaperBtn, findsOneWidget);
    await tester.tap(setWallpaperBtn);
    await tester.pumpAndSettle();

    final titleFinder = find.text('APPLY TO:');
    expect(titleFinder, findsOneWidget);
    final titleWidget = tester.widget<Text>(titleFinder);
    expect(titleWidget.textAlign, TextAlign.center);
    expect(titleWidget.style?.fontSize, 24);
    expect(titleWidget.style?.fontWeight, FontWeight.w900);

    final sheetContainerFinder = find.byWidgetPredicate((widget) {
      if (widget is Container && widget.decoration is BoxDecoration) {
        final dec = widget.decoration as BoxDecoration;
        return dec.color == const Color(0xFFF4F0E6) &&
            dec.border is Border &&
            (dec.border as Border).top.color == Colors.black &&
            (dec.border as Border).top.width == 4;
      }
      return false;
    });
    expect(sheetContainerFinder, findsOneWidget);

    expect(find.text('HOME SCREEN'), findsOneWidget);
    expect(find.text('LOCK SCREEN'), findsOneWidget);
    expect(find.text('BOTH'), findsOneWidget);

    await tester.tap(find.text('HOME SCREEN'));
    await tester.pumpAndSettle();

    expect(find.text('APPLIED TO HOME SCREEN!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('APPLY TO:'), findsNothing);
  });

  testWidgets(
      'Selecting LOCK SCREEN in target selection sheet shows applied toast',
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
    expect(find.text('APPLY TO:'), findsNothing);
  });

  testWidgets('Selecting BOTH in target selection sheet shows applied toast',
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
    expect(find.text('APPLY TO:'), findsNothing);
  });

  testWidgets(
      'Toggling preview mode shows lock screen overlay and exit button, then exiting restores UI',
      (WidgetTester tester) async {
    await setupHomePageTest(tester);

    // Open modal
    await tester.tap(find.byType(Image).first);
    await tester.pumpAndSettle();

    // Verify initial state: UI controls visible, overlay not visible
    expect(find.byIcon(Icons.remove_red_eye), findsOneWidget);
    expect(find.text('SET AS WALLPAPER'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.text('09:41'), findsNothing);
    expect(find.text('EXIT PREVIEW'), findsNothing);

    // Tap preview mode toggle
    await tester.tap(find.byIcon(Icons.remove_red_eye));
    await tester.pumpAndSettle();

    // Verify preview mode state:
    // UI controls hidden
    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expect(find.byIcon(Icons.remove_red_eye), findsNothing);
    expect(find.text('SET AS WALLPAPER'), findsNothing);

    // Lock screen overlay visible
    expect(find.byIcon(Icons.lock), findsOneWidget);
    expect(find.text('09:41'), findsOneWidget);
    expect(find.text('Wednesday, October 1'), findsOneWidget);
    expect(find.byIcon(Icons.cloud), findsOneWidget);
    expect(find.text('22°'), findsOneWidget);
    expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    expect(find.text('452 kcal'), findsOneWidget);

    // Exit preview button visible
    final exitBtnFinder = find.text('EXIT PREVIEW');
    expect(exitBtnFinder, findsOneWidget);

    // Tap EXIT PREVIEW
    await tester.tap(exitBtnFinder);
    await tester.pumpAndSettle();

    // Verify UI controls restored, overlay hidden
    expect(find.text('09:41'), findsNothing);
    expect(find.text('EXIT PREVIEW'), findsNothing);
    expect(find.text('SET AS WALLPAPER'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.remove_red_eye), findsOneWidget);
  });

  testWidgets(
      'Closing modal while in preview mode resets preview mode state for next open',
      (WidgetTester tester) async {
    await setupHomePageTest(tester);

    // 1. Open modal
    await tester.tap(find.byType(Image).first);
    await tester.pumpAndSettle();

    // 2. Enter preview mode
    await tester.tap(find.byIcon(Icons.remove_red_eye));
    await tester.pumpAndSettle();
    expect(find.text('EXIT PREVIEW'), findsOneWidget);

    // 3. Exit preview mode and close modal
    await tester.tap(find.text('EXIT PREVIEW'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // 4. Reopen modal and verify not in preview mode
    await tester.tap(find.byType(Image).first);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.remove_red_eye), findsOneWidget);
    expect(find.text('SET AS WALLPAPER'), findsOneWidget);
    expect(find.text('09:41'), findsNothing);
  });
}
