import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:brutal_wallz/globals/app_state.dart';
import 'package:brutal_wallz/pages/home_page.dart';

/// Widget tests for [HomePage] verifying wallpaper grid rendering,
/// image caching configuration, full-screen detail modal interactions,
/// and navigation between modal and main views.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Helper function to wrap [HomePage] in required [ChangeNotifierProvider] and [MaterialApp].
  Widget buildTestWidget(AppState appState) {
    return ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: const MaterialApp(
        home: HomePage(),
      ),
    );
  }

  testWidgets('HomePage renders offline wallpaper assets in grid and modal', (WidgetTester tester) async {
    // Set fixed virtual viewport dimensions to simulate a standard mobile screen
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Pre-populate AppState with wallpapers from asset bundle
    final appState = AppState();
    await appState.fetchWallpapers();

    // Pump widget tree and settle pending frames/animations
    await tester.pumpWidget(buildTestWidget(appState));
    await tester.pumpAndSettle();

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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Verify modal content is displayed with SET AS WALLPAPER button and download button
    expect(find.text('SET AS WALLPAPER'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_downward));
    await tester.pump();
    expect(find.text('WALLPAPER SAVED TO GALLERY!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 350));
    // Verify modal does not display the wallpaper title label
    expect(find.text(appState.wallpapers.first.title.toUpperCase()), findsNothing);

    // 3. Verify Modal Container has DecorationImage with AssetImage
    final modalImageFinder = find.byWidgetPredicate((widget) {
      if (widget is Container && widget.decoration is BoxDecoration) {
        final boxDecoration = widget.decoration as BoxDecoration;
        if (boxDecoration.image?.image is AssetImage) {
          final assetImage = boxDecoration.image!.image as AssetImage;
          return assetImage.assetName.startsWith('assets/wallpapers/');
        }
      }
      return false;
    });
    expect(modalImageFinder, findsOneWidget);

    // 4. Close the modal by tapping back button
    final backButtonFinder = find.byIcon(Icons.arrow_back);
    expect(backButtonFinder, findsOneWidget);
    await tester.tap(backButtonFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  });
}
