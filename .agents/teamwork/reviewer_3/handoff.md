# Adversarial Reviewer Report — Reviewer 3

> [!WARNING] **Skepticism Disclaimer**
> High confidence: Identified and fixed premature toast dismissal timer race, bottom-sheet re-entrancy, invalid asset fallback in URL handler, and Android 12+ Monet Activity recreation. All 38 tests across the repository pass cleanly under `flutter test` with 0 static analysis issues. Physical dynamic color extraction on a physical Android 12+ device remains unverified in hardware due to the desktop headless runner.

## 1. What the prior attempt got wrong

1. **Premature Success Toast Dismissal via Timer Collision (Functional Confirmation Bug)**:
   - **Input**: Applying a wallpaper where the async application operation completes after ~1.5s (while the initial `'APPLYING…'` toast was shown at t = 0s).
   - **Expected**: The success toast (`'APPLIED TO HOME SCREEN!'`) remains visible for its full 2-second duration.
   - **Actual**: The success toast disappeared prematurely after only 500-600ms (receding off-screen to `top: -100.0`).
   - **Root Cause**: `showToast()` created unmanaged, unkeyed `Future<void>.delayed(const Duration(seconds: 2))` instances. When multiple toasts were queued sequentially, the earlier timer expired and unconditionally invoked `setState(() => isToastVisible = false)`, sliding the newer toast off-screen prematurely.

2. **Unchecked Picasso Fallback on Local Asset Resolution Failure (Fatal Native Crash Risk)**:
   - **Input**: Applying a bundled asset wallpaper (`assets/wallpapers/...`) when local storage caching fails (e.g., temporary directory failure, out-of-disk-space, or corrupted asset).
   - **Expected**: Safe failure reporting via `'FAILED — TRY AGAIN'` without dispatching invalid file schemes to native web image loaders.
   - **Actual**: `_applyWallpaper` fell through to `AsyncWallpaper.setWallpaper(url: wallpaperUrl)`, passing `assets/...` to native `Picasso.get().load(url)`, which causes `IllegalArgumentException` or native crash on Android.
   - **Root Cause**: The fallback to `AsyncWallpaper.setWallpaper` did not guard whether `wallpaperUrl` was an HTTP/HTTPS web URL.

3. **Bottom Sheet Dialog Re-entrancy & Dangerous Unmounted Navigator Pop (Route Stack Bug)**:
   - **Input**: Rapid taps on `'SET AS WALLPAPER'` button before bottom sheet mounts or while dismissing.
   - **Expected**: Single bottom sheet instance, guarded by state.
   - **Actual**: `setWallpaper()` could spawn multiple modal bottom sheets or attempt to call `Navigator.pop(sheetContext)` without verifying `sheetContext.mounted && Navigator.canPop(sheetContext)`.
   - **Root Cause**: `setWallpaper()` lacked a re-entrancy flag (`_isBottomSheetOpen`), and `selectOption` did not verify `sheetContext.mounted` or `canPop`.

4. **Android 12+ Monet Dynamic Color Activity Destruction (Activity Lifecycle Bug from Ledger)**:
   - **Input**: Setting a wallpaper on Android 12+ (API 31+) device with Material You wallpaper color extraction enabled.
   - **Expected**: App remains active on its current screen while dynamic colors re-index.
   - **Actual**: Android OS recreated `MainActivity` because `colorMode` was missing from `android:configChanges` in `AndroidManifest.xml`, destroying the Flutter engine and resetting navigation.
   - **Root Cause**: `android:configChanges` in `AndroidManifest.xml` omitted `colorMode`.

## 2. What I changed

1. **`lib/pages/home_page.dart`**:
   - Added `import 'dart:async';`.
   - Added `Timer? _toastTimer;` to manage toast banner auto-dismissal. Each `showToast()` call cancels the previous timer, guaranteeing each toast displays for the full 2 seconds.
   - Added `_HomePageState.dispose()` to cancel `_toastTimer` when unmounted.
   - Added `bool _isBottomSheetOpen = false;` to guard `setWallpaper()` against re-entrant calls and duplicate bottom sheets.
   - Hardened `selectOption` in `setWallpaper()` with `if (sheetContext.mounted && Navigator.canPop(sheetContext))`.
   - Guarded direct URL fallback in `_applyWallpaper` so `AsyncWallpaper.setWallpaper` is ONLY invoked if `wallpaperUrl.startsWith('http://') || wallpaperUrl.startsWith('https://')`. If local file resolution fails for assets or non-HTTP paths, it immediately and safely sets `result = false`.

2. **`android/app/src/main/AndroidManifest.xml`**:
   - Added `colorMode` to `android:configChanges` on `MainActivity` to prevent Android 12+ Monet dynamic color extraction from recreating the activity and resetting navigation.

3. **`test/wallpaper_application_test.dart`**:
   - Added test: `Success toast remains visible for full duration and is not prematurely dismissed by earlier applying toast timer` (verifies toast timer isolation and exact coordinate position `top: 20` at t = 2.1s).
   - Added test: `Rapid double tap on SET AS WALLPAPER button does not spawn duplicate bottom sheets`.
   - Added test: `Setting wallpaper from Favorites tab returns to Favorites tab with confirmation, and back returns to Gallery` (verifies tab navigation integrity across non-primary tabs).
   - Added test: `Tapping bottom sheet option while sheet is dismissing via back gesture does not pop HomePage`.
   - Added test: `When local file resolution fails for non-URL wallpaper, reports failure without invoking Picasso web URL setter`.

## 3. Verification Record

- **Deep Verification (ran actual tests):**
  - Ran `flutter test test/wallpaper_application_test.dart`: 21/21 tests passed.
  - Ran `flutter test`: 38/38 tests passed across the entire repository (`api_test.dart`, `app_state_test.dart`, `data_preparation_test.dart`, `home_page_test.dart`, `wallpaper_application_test.dart`, `widget_test.dart`).
  - Ran `flutter analyze lib test`: 0 issues found (clean analysis).
- **Shallow Verification (manual only):**
  - Traced `_toastTimer` cancellation on rapid toast switches.
  - Traced `_isBottomSheetOpen` across modal bottom sheet completion lifecycle (`whenComplete`).
  - Verified `colorMode` attribute compatibility against Android API 26+ requirements.
- **Unverified aspects:**
  - Real Android 12+ hardware validation with live Monet theme re-extraction (cannot be run in headless desktop CI/test harness).

## 4. Known Issues

- `Shallow Verification`: Android 12+ dynamic color (Monet) theme extraction on real hardware without Activity restart relies on `android:configChanges="...|colorMode"`, which is verified via Android manifest configuration but not executed on a physical Android device.
- `Minor Robustness Risk`: If host device storage is completely full or read-only, `tempFile.writeAsBytesSync` throws and is caught by `_resolveWallpaperFile`, cleanly presenting `'FAILED — TRY AGAIN'`.

## 5. Remaining risk & next step

- Task is complete. All requirements R1 (navigation fallback, preventing app exit, and proper toast display) and R2 (comprehensive automated tests exercising real wallpaper resolution and asserting `goToHome: false`) are fully satisfied. Commit `259a8a8` fixes all issues and all 38 tests pass cleanly.

---

## Commit Diff (Commit `259a8a8`)

```diff
diff --git a/android/app/src/main/AndroidManifest.xml b/android/app/src/main/AndroidManifest.xml
index 72eb402..ebca58c 100644
--- a/android/app/src/main/AndroidManifest.xml
+++ b/android/app/src/main/AndroidManifest.xml
@@ -13,7 +13,7 @@
             android:launchMode="singleTop"
             android:taskAffinity=""
             android:theme="@style/LaunchTheme"
-            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
+            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode|colorMode"
             android:hardwareAccelerated="true"
             android:windowSoftInputMode="adjustResize">
             <!-- Specifies an Android theme to apply to this Activity as soon as
diff --git a/lib/pages/home_page.dart b/lib/pages/home_page.dart
index 55da3ad..457fba3 100644
--- a/lib/pages/home_page.dart
+++ b/lib/pages/home_page.dart
@@ -1,3 +1,4 @@
+import 'dart:async';
 import 'package:flutter/material.dart';
 import 'package:flutter/services.dart';
 import 'dart:io' show Platform, File;
@@ -71,6 +72,12 @@ class _HomePageState extends State<HomePage> {
   /// True while a wallpaper apply operation is in progress.
   bool _isApplyingWallpaper = false;
 
+  /// True while the wallpaper apply target selection bottom sheet is visible.
+  bool _isBottomSheetOpen = false;
+
+  /// Timer controlling the auto-dismissal of the animated toast notification banner.
+  Timer? _toastTimer;
+
   /// Returns wallpaper models matching the current [_searchQuery] filter
   /// by checking both the wallpaper title and category.
   List<WallpaperModel> get filteredWallpapers {
@@ -91,6 +98,12 @@ class _HomePageState extends State<HomePage> {
     });
   }
 
+  @override
+  void dispose() {
+    _toastTimer?.cancel();
+    super.dispose();
+  }
+
   /// User preference toggle for push notifications
   bool notificationsEnabled = true;
 
@@ -671,17 +684,20 @@ class _HomePageState extends State<HomePage> {
   /// Displays the temporary toast notification banner with a specified [message].
   void showToast(String message) {
+    _toastTimer?.cancel();
     setState(() {
       toastMessage = message;
       isToastVisible = true;
     });
     // Auto-dismiss the toast banner after 2 seconds
-    Future<void>.delayed(const Duration(seconds: 2), () {
+    _toastTimer = Timer(const Duration(seconds: 2), () {
       if (mounted) {
         setState(() => isToastVisible = false);
       }
     });
   }
 
   /// Displays a bottom sheet to select where to apply the wallpaper.
   void setWallpaper() {
+    if (_isBottomSheetOpen || _isApplyingWallpaper) return;
+    _isBottomSheetOpen = true;
     HapticFeedback.heavyImpact();
     bool optionSelected = false;
     showModalBottomSheet<void>(
       context: context,
       backgroundColor: Colors.transparent,
       builder: (BuildContext sheetContext) {
         void selectOption(int location) {
           if (optionSelected) return;
           optionSelected = true;
-          Navigator.pop(sheetContext);
+          if (sheetContext.mounted && Navigator.canPop(sheetContext)) {
+            Navigator.pop(sheetContext);
+          }
           _applyWallpaper(location);
         }
 
@@ -780,7 +796,9 @@ class _HomePageState extends State<HomePage> {
           ),
         );
       },
-    );
+    ).whenComplete(() {
+      _isBottomSheetOpen = false;
+    });
   }
 
   /// Resolves [imagePath] into a local filesystem path accessible by native platform services.
@@ -871,8 +889,9 @@ class _HomePageState extends State<HomePage> {
           wallpaperLocation: wallpaperLocation,
           goToHome: false,
         ).timeout(const Duration(seconds: 15), onTimeout: () => false);
-      } else {
-        // Direct URL fallback if file resolution fails
+      } else if (wallpaperUrl.startsWith('http://') ||
+          wallpaperUrl.startsWith('https://')) {
+        // Direct URL fallback if remote image file caching fails
         result = await AsyncWallpaper.setWallpaper(
           url: wallpaperUrl,
           wallpaperLocation: wallpaperLocation,
@@ -879,4 +898,6 @@ class _HomePageState extends State<HomePage> {
         ).timeout(const Duration(seconds: 15), onTimeout: () => false);
+      } else {
+        result = false;
       }
     } catch (e) {
       debugPrint('Error applying wallpaper: $e');
```
