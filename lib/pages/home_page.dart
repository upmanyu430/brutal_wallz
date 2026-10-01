import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform, File;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:brutal_wallz/models/wallpaper_model.dart';
import 'package:brutal_wallz/globals/app_state.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:brutal_wallz/components/brutal_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gal/gal.dart';

/// Main screen of the Brutal Wallz application.
/// Houses the wallpaper gallery, interactive search, favorites collection,
/// settings dashboard, full-screen preview modal, and toast feedback alerts.
@NowaGenerated()
class HomePage extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

@NowaGenerated()
class _HomePageState extends State<HomePage> {
  // ─── Neo-brutalist Brand Color Palette ──────────────────────────────────────
  /// Off-white paper background tone
  final Color bg = const Color(0xFFF4F0E6);

  /// Vibrant yellow accent color
  final Color yellow = const Color(0xFFFDE047);

  /// Bright pink accent color (favorites & warnings)
  final Color pink = const Color(0xFFF9A8D4);

  /// Electric pastel blue accent color
  final Color blue = const Color(0xFF93C5FD);

  /// Neon green accent color (success & primary actions)
  final Color green = const Color(0xFF86EFAC);

  /// Warm orange accent color
  final Color orange = const Color(0xFFFDBA74);

  // ─── UI Overlay States ──────────────────────────────────────────────────────
  /// Controls the visibility of the slide-up full-screen wallpaper detail modal
  bool isModalOpen = false;

  /// Controls the slide-down animated toast banner visibility
  bool isToastVisible = false;

  /// Controls whether simulated lock screen preview mode is active in the wallpaper detail modal
  bool isPreviewMode = false;

  /// Current active bottom navigation tab index (0: Explore, 1: Favorites, 2: Settings)
  int _currentIndex = 0;

  /// Current search filter query entered by the user
  String _searchQuery = '';

  /// The wallpaper currently inspected inside the modal preview
  WallpaperModel? selectedWallpaper;

  /// In-memory collection of wallpapers marked as favorite by the user
  List<WallpaperModel> favorites = [];

  /// True while a wallpaper apply operation is in progress.
  bool _isApplyingWallpaper = false;

  /// True while a wallpaper download-to-gallery operation is in progress.
  bool _isDownloading = false;

  /// True while the wallpaper apply target selection bottom sheet is visible.
  bool _isBottomSheetOpen = false;

  /// Timer controlling the auto-dismissal of the animated toast notification banner.
  Timer? _toastTimer;

  /// Returns wallpaper models matching the current [_searchQuery] filter
  /// by checking both the wallpaper title and category.
  List<WallpaperModel> get filteredWallpapers {
    final appState = AppState.of(context);
    return appState.wallpapers.where((wall) {
      final matchesSearch = _searchQuery.isEmpty ||
          wall.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          wall.cat.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // Trigger wallpaper asset fetching after the initial widget frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppState.of(context, listen: false).fetchWallpapers();
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  /// User preference toggle for push notifications
  bool notificationsEnabled = true;

  /// Simulated cached asset storage size in megabytes
  double cacheSizeMb = 14.8;

  /// Text displayed inside the animated toast banner
  String toastMessage = 'WALLPAPER APPLIED!';

  /// Opens the full-screen preview modal displaying the given [wall].
  void openWallpaper(WallpaperModel wall) {
    setState(() {
      selectedWallpaper = wall;
      isModalOpen = true;
      isPreviewMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool canPop = !isModalOpen && selectedWallpaper == null && _currentIndex == 0 && !_isApplyingWallpaper;
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        if (isPreviewMode) {
          setState(() => isPreviewMode = false);
        } else if (isModalOpen) {
          closeWallpaper();
        } else if (selectedWallpaper != null) {
          // Modal closing animation is currently in flight; consume the back gesture
          // so it does not inadvertently exit the app or pop the root navigator.
          return;
        } else if (_isApplyingWallpaper) {
          showToast('APPLYING WALLPAPER, PLEASE WAIT…');
          return;
        } else if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Active tab page content (Gallery, Favorites, or Settings)
              _buildCurrentPage(),

              // Persistent bottom navigation bar
              Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomNav()),

              // Animated full-screen wallpaper inspection modal
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                top: isModalOpen ? 0 : size.height,
                bottom: isModalOpen ? 0 : -size.height,
                left: 0,
                right: 0,
                onEnd: () {
                  if (!isModalOpen && mounted) {
                    setState(() {
                      selectedWallpaper = null;
                    });
                  }
                },
                child: IgnorePointer(
                  ignoring: !isModalOpen,
                  child: _buildModal(),
                ),
              ),

            // Top notification banner / toast with spring ease animation
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              top: isToastVisible ? 20 : -100,
              left: 20,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: yellow,
                    border: Border.all(color: Colors.black, width: 4),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                    ],
                  ),
                  child: Text(
                    toastMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  /// Builds the top-level view corresponding to the currently selected bottom nav tab.
  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        // Tab 0: Wallpaper Gallery with Search Header
        return Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildWallpaperGrid(filteredWallpapers)),
          ],
        );
      case 1:
        // Tab 1: Saved Favorites Collection
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 4),
                ),
              ),
              child: const Text(
                'FAVORITES',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
              ),
            ),
            Expanded(
              child: favorites.isEmpty
                  ? const Center(
                      child: Text(
                        'NO FAVORITES YET',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : _buildWallpaperGrid(favorites),
            ),
          ],
        );
      case 2:
        // Tab 2: User Settings Dashboard
        return _buildSettingsPage();
      default:
        return const SizedBox();
    }
  }

  /// Builds the neo-brutalist header container featuring an interactive search input.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 4)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.black),
            Expanded(
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'SEARCH AESTHETICS',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // Show clear button when query is present
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: const Icon(Icons.close, color: Colors.black),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveImage(String path, {int? cacheWidth, BoxFit? fit}) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        memCacheWidth: cacheWidth,
        fit: fit,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50),
      );
    }
    return Image.asset(
      path,
      cacheWidth: cacheWidth,
      fit: fit,
      errorBuilder: (c, o, s) => const Icon(Icons.broken_image, size: 50),
    );
  }

  /// Builds the 2-column scrollable grid of wallpaper cards.
  /// Handles loading indicators, error feedback, and empty result placeholders.
  Widget _buildWallpaperGrid(List<WallpaperModel> list) {
    final appState = AppState.of(context);

    // Show spinner if wallpapers are still being fetched from asset bundle
    if (appState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    // Display error message if asset loading failed
    if (appState.error != null) {
      return Center(
        child: Text(
          appState.error!,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    }

    // Empty state when filter yields no matches
    if (list.isEmpty) {
      return const Center(
        child: Text(
          'NO WALLPAPERS FOUND',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    }

    // Responsive 2-column grid with 9:16 portrait aspect ratio
    return GridView.builder(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 9 / 16,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) => BrutalButton(
        color: Colors.white,
        shadowOffset: 6,
        onTap: () => openWallpaper(list[index]),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Downsampled thumbnail image rendering to conserve memory in grid view
            _buildResponsiveImage(list[index].thumbnailUrl,
                cacheWidth: 300, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }

  /// Builds the full-screen slide-over modal inspect window for the selected wallpaper.
  Widget _buildModal() {
    if (selectedWallpaper == null) {
      return const SizedBox();
    }
    final wall = selectedWallpaper!;
    final isFav = favorites.any((f) => f.id == wall.id);

    return Material(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Interactive Image Viewer
          InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: _buildResponsiveImage(
              wall.imageUrl,
              fit: BoxFit.cover,
            ),
          ),

          // 2. Simulated Lock Screen Overlay (Visible only in Preview Mode)
          if (isPreviewMode) _buildLockScreenOverlay(),

          // 3. UI Controls (Hidden during full Preview Mode, except for a way to exit)
          if (!isPreviewMode) ...[
            // Top action bar with Back and Favorite toggle buttons
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: BrutalButton(
                        color: Colors.white,
                        shadowOffset: 4,
                        onTap: closeWallpaper,
                        child: const Icon(Icons.arrow_back),
                      ),
                    ),
                    Row(
                      spacing: 16,
                      children: [
                        // New Preview Mode Toggle Button
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: BrutalButton(
                            color: Colors.white,
                            shadowOffset: 4,
                            onTap: () => setState(() => isPreviewMode = true),
                            child: const Icon(Icons.remove_red_eye),
                          ),
                        ),
                        // Existing Favorite button
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: BrutalButton(
                            color: isFav ? pink : Colors.white,
                            shadowOffset: 4,
                            onTap: () => toggleFavorite(wall),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom sheet card with category chip, and apply action
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border:
                      Border(top: BorderSide(color: Colors.black, width: 8)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: yellow,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Text(
                        wall.cat,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 60,
                            child: BrutalButton(
                              color: green,
                              shadowOffset: 6,
                              onTap: _isApplyingWallpaper ? () {} : setWallpaper,
                              child: Center(
                                child: Text(
                                  _isApplyingWallpaper
                                      ? 'APPLYING…'
                                      : 'SET AS WALLPAPER',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: BrutalButton(
                            color: Colors.black,
                            shadowOffset: 6,
                            onTap: _isDownloading ? () {} : downloadWallpaper,
                            child: const Center(
                              child: Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          // 4. Exit Preview Mode Button
          if (isPreviewMode)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  height: 50,
                  width: 200,
                  child: BrutalButton(
                    color: Colors.white,
                    shadowOffset: 4,
                    onTap: () => setState(() => isPreviewMode = false),
                    child: const Center(
                      child: Text(
                        'EXIT PREVIEW',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the simulated lock screen overlay containing time, date, and mock status widgets.
  Widget _buildLockScreenOverlay() {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.lock, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            const Text(
              '09:41',
              style: TextStyle(
                color: Colors.white,
                fontSize: 72,
                fontWeight: FontWeight.w200,
                shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
              ),
            ),
            const Text(
              'Wednesday, October 1',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
              ),
            ),
            const SizedBox(height: 32),
            // Mock Widgets Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16,
              children: [
                _mockWidgetContainer(Icons.cloud, '22\u00B0'),
                _mockWidgetContainer(Icons.fitness_center, '452 kcal'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a small rounded rectangular container simulating lock screen widgets.
  Widget _mockWidgetContainer(IconData icon, String text) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Closes the currently opened wallpaper modal and slides it off-screen.
  void closeWallpaper() {
    setState(() {
      isModalOpen = false;
      isPreviewMode = false;
    });
  }

  /// Adds or removes [wall] from the [favorites] list.
  void toggleFavorite(WallpaperModel wall) {
    HapticFeedback.heavyImpact();
    final isAlreadyFav = favorites.any((f) => f.id == wall.id);
    setState(() {
      if (isAlreadyFav) {
        favorites.removeWhere((f) => f.id == wall.id);
      } else {
        favorites.add(wall);
      }
    });
  }

  /// Displays the temporary toast notification banner with a specified [message].
  void showToast(String message) {
    _toastTimer?.cancel();
    setState(() {
      toastMessage = message;
      isToastVisible = true;
    });
    // Auto-dismiss the toast banner after 2 seconds
    _toastTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => isToastVisible = false);
      }
    });
  }

  /// Displays a bottom sheet to select where to apply the wallpaper.
  void setWallpaper() {
    if (_isBottomSheetOpen || _isApplyingWallpaper) return;
    _isBottomSheetOpen = true;
    HapticFeedback.heavyImpact();
    bool optionSelected = false;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        void selectOption(int location) {
          if (optionSelected) return;
          optionSelected = true;
          if (sheetContext.mounted && Navigator.canPop(sheetContext)) {
            Navigator.pop(sheetContext);
          }
          _applyWallpaper(location);
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bg,
            border: const Border(
              top: BorderSide(color: Colors.black, width: 4),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'APPLY TO:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 60,
                child: BrutalButton(
                  color: yellow,
                  shadowOffset: 4,
                  onTap: () => selectOption(AsyncWallpaper.HOME_SCREEN),
                  child: const Center(
                    child: Text(
                      'HOME SCREEN',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 60,
                child: BrutalButton(
                  color: blue,
                  shadowOffset: 4,
                  onTap: () => selectOption(AsyncWallpaper.LOCK_SCREEN),
                  child: const Center(
                    child: Text(
                      'LOCK SCREEN',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 60,
                child: BrutalButton(
                  color: green,
                  shadowOffset: 4,
                  onTap: () => selectOption(AsyncWallpaper.BOTH_SCREENS),
                  child: const Center(
                    child: Text(
                      'BOTH',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    ).whenComplete(() {
      _isBottomSheetOpen = false;
    });
  }

  /// Resolves [imagePath] into a local filesystem path accessible by native platform services.
  /// Downloads remote URLs to local cache, copies Flutter assets to a temporary cache file,
  /// and returns verified local disk file paths.
  Future<String?> _resolveWallpaperFile(String imagePath) async {
    try {
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        final file = await DefaultCacheManager().getSingleFile(imagePath);
        return file.path;
      }

      if (imagePath.startsWith('assets/')) {
        final byteData = await rootBundle.load(imagePath);
        final tempDir = await getTemporaryDirectory();
        final fileName = imagePath.split('/').last;
        final tempFile = File('${tempDir.path}/$fileName');
        tempFile.writeAsBytesSync(
          byteData.buffer.asUint8List(
            byteData.offsetInBytes,
            byteData.lengthInBytes,
          ),
          flush: true,
        );
        return tempFile.path;
      }

      // Check if it's already a local file path
      final cleanPath = imagePath.startsWith('file://')
          ? imagePath.replaceFirst('file://', '')
          : imagePath;
      final file = File(cleanPath);
      if (await file.exists()) {
        return file.path;
      }

      // Fallback: If path does not start with assets/ but is an asset reference
      try {
        final byteData = await rootBundle.load(imagePath);
        final tempDir = await getTemporaryDirectory();
        final fileName = imagePath.split('/').last;
        final tempFile = File('${tempDir.path}/$fileName');
        tempFile.writeAsBytesSync(
          byteData.buffer.asUint8List(
            byteData.offsetInBytes,
            byteData.lengthInBytes,
          ),
          flush: true,
        );
        return tempFile.path;
      } catch (_) {
        // Not an asset
      }

      return null;
    } catch (e) {
      debugPrint('Error resolving wallpaper file: $e');
      return null;
    }
  }

  /// Applies [selectedWallpaper] to the given [wallpaperLocation] screen(s)
  /// using [async_wallpaper]. Shows a loading toast immediately, then a
  /// success or failure toast once the platform call resolves.
  ///
  /// [wallpaperLocation] must be one of:
  /// - [AsyncWallpaper.HOME_SCREEN]
  /// - [AsyncWallpaper.LOCK_SCREEN]
  /// - [AsyncWallpaper.BOTH_SCREENS]
  Future<void> _applyWallpaper(int wallpaperLocation) async {
    final currentWallpaper = selectedWallpaper;
    if (currentWallpaper == null || _isApplyingWallpaper) return;
    final wallpaperUrl = currentWallpaper.imageUrl;

    final label = wallpaperLocation == AsyncWallpaper.HOME_SCREEN
        ? 'HOME SCREEN'
        : wallpaperLocation == AsyncWallpaper.LOCK_SCREEN
            ? 'LOCK SCREEN'
            : 'BOTH';

    final isSupported =
        Platform.isAndroid || Platform.environment.containsKey('FLUTTER_TEST');
    if (!isSupported) {
      showToast('NOT SUPPORTED ON THIS PLATFORM');
      return;
    }

    setState(() => _isApplyingWallpaper = true);
    showToast('APPLYING…');

    bool result = false;
    try {
      final localFilePath = await _resolveWallpaperFile(wallpaperUrl);
      if (localFilePath != null) {
        result = await AsyncWallpaper.setWallpaperFromFile(
          filePath: localFilePath,
          wallpaperLocation: wallpaperLocation,
          goToHome: false,
        ).timeout(const Duration(seconds: 15), onTimeout: () => false);
      } else if (wallpaperUrl.startsWith('http://') ||
          wallpaperUrl.startsWith('https://')) {
        // Direct URL fallback if remote image file caching fails
        result = await AsyncWallpaper.setWallpaper(
          url: wallpaperUrl,
          wallpaperLocation: wallpaperLocation,
          goToHome: false,
        ).timeout(const Duration(seconds: 15), onTimeout: () => false);
      } else {
        result = false;
      }
    } catch (e) {
      debugPrint('Error applying wallpaper: $e');
      result = false;
    } finally {
      if (mounted) setState(() => _isApplyingWallpaper = false);
    }

    if (!mounted) return;

    if (result) {
      // Only dismiss the modal if the user hasn't already switched to a different wallpaper
      if (selectedWallpaper?.id == currentWallpaper.id) {
        closeWallpaper();
      }
    }
    showToast(result ? 'APPLIED TO $label!' : 'FAILED — TRY AGAIN');
  }

  /// Downloads [selectedWallpaper]'s image (asset or remote URL) and saves
  /// it to the device's local photo gallery via [Gal].
  ///
  /// Delegates path resolution to [_resolveWallpaperFile], which handles both
  /// local asset paths and HTTP URLs — the same helper used by [_applyWallpaper].
  Future<void> downloadWallpaper() async {
    final wall = selectedWallpaper;
    if (wall == null || _isDownloading) return;

    setState(() => _isDownloading = true);
    showToast('DOWNLOADING…');

    try {
      // _resolveWallpaperFile handles both asset:// paths and http(s):// URLs,
      // writing remote images to the local cache and assets to a temp file.
      final localPath = await _resolveWallpaperFile(wall.imageUrl);
      if (localPath == null) throw Exception('Could not resolve wallpaper file');

      await Gal.putImage(localPath);

      if (mounted) showToast('SAVED TO GALLERY!');
    } on GalException catch (e) {
      debugPrint('downloadWallpaper GalException: ${e.type}');
      if (mounted) showToast('SAVE FAILED — ${e.type.message.toUpperCase()}');
    } catch (e) {
      debugPrint('downloadWallpaper error: $e');
      if (mounted) showToast('SAVE FAILED — TRY AGAIN');
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  /// Opens the About dialog presenting version details and aesthetic info.
  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(6, 6)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ABOUT',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: yellow,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Text(
                'Brutal Wallz delivers high-voltage, neo-brutalist wallpaper aesthetics for bold setups.',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: blue.withValues(alpha: 0.3),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Text(
                  'Curated geometric patterns, halftone gradients, and retro-futuristic visuals.',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: BrutalButton(
                  color: green,
                  shadowOffset: 4,
                  onTap: () => Navigator.of(ctx).pop(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        'GOT IT',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the Settings page containing notifications, cache management,
  /// favorites reset, and about dialog triggers.
  Widget _buildSettingsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          const Text(
            'SETTINGS',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          ),
          // Notifications preference toggle row
          BrutalButton(
            color: Colors.white,
            shadowOffset: 4,
            onTap: () {
              setState(() {
                notificationsEnabled = !notificationsEnabled;
              });
              showToast(
                notificationsEnabled
                    ? 'NOTIFICATIONS ENABLED'
                    : 'NOTIFICATIONS MUTED',
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: const Text(
                  'Notifications',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  notificationsEnabled ? 'Enabled • Daily drops' : 'Disabled',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: notificationsEnabled ? green : Colors.grey[300],
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Text(
                    notificationsEnabled ? 'ON' : 'OFF',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Storage and cache details action row
          BrutalButton(
            color: Colors.white,
            shadowOffset: 4,
            onTap: _showStorageDialog,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: const Text(
                  'Storage & Cache',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Cache: ${cacheSizeMb.toStringAsFixed(1)} MB',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.storage, color: Colors.black),
              ),
            ),
          ),
          // Clear favorites action row
          BrutalButton(
            color: Colors.white,
            shadowOffset: 4,
            onTap: () {
              if (favorites.isEmpty) {
                showToast('NO FAVORITES TO CLEAR');
                return;
              }
              _showClearFavoritesDialog();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  'Clear Favorites',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Remove all saved wallpapers',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                ),
                trailing: Icon(Icons.delete_outline, color: Colors.black),
              ),
            ),
          ),
          // About application action row
          BrutalButton(
            color: orange,
            shadowOffset: 4,
            onTap: _showAboutDialog,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  'About Brutal Wallz',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Version, credits and info',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                ),
                trailing: Icon(Icons.info_outline, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Displays confirmation dialog to empty all wallpapers from the user's favorites list.
  void _showClearFavoritesDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(6, 6)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              const Text(
                'CLEAR ALL FAVORITES?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Are you sure you want to delete all saved wallpapers from your favorites? This action cannot be undone.',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: BrutalButton(
                        color: Colors.white,
                        shadowOffset: 4,
                        onTap: () => Navigator.of(ctx).pop(),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'CANCEL',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: BrutalButton(
                        color: pink,
                        shadowOffset: 4,
                        onTap: () {
                          Navigator.of(ctx).pop();
                          setState(() {
                            favorites.clear();
                          });
                          showToast('FAVORITES CLEARED!');
                        },
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'CLEAR',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Displays storage management dialog with option to clear cached data.
  void _showStorageDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(6, 6)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              const Text(
                'STORAGE DETAILS',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              Text(
                'Current cached wallpapers and assets: ${cacheSizeMb.toStringAsFixed(1)} MB',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: BrutalButton(
                        color: Colors.white,
                        shadowOffset: 4,
                        onTap: () => Navigator.of(ctx).pop(),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'CLOSE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: BrutalButton(
                        color: yellow,
                        shadowOffset: 4,
                        onTap: () {
                          Navigator.of(ctx).pop();
                          setState(() {
                            cacheSizeMb = 0;
                          });
                          showToast('CACHE CLEARED!');
                        },
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'CLEAR CACHE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the persistent neo-brutalist bottom navigation bar container.
  Widget _buildBottomNav() {
    return Container(
      color: Colors.black,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 4),
          child: Row(
            children: [
              _buildNavTab(Icons.home, yellow, 0),
              _buildNavTab(Icons.favorite, pink, 1),
              _buildNavTab(Icons.settings, green, 2),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds an individual tab button in the bottom navigation bar.
  Widget _buildNavTab(IconData icon, Color color, int index) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: BrutalButton(
        color: color,
        shadowOffset: 4,
        borderWidth: 2.0,
        // Active visual state is pressed into shadow when unselected, popping out when selected
        isActive: !isSelected,
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Icon(icon, size: 32, color: Colors.black),
        ),
      ),
    );
  }
}
