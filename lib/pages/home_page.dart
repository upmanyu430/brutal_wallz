import 'package:flutter/material.dart';
import 'package:brutal_wallz/models/wallpaper_model.dart';
import 'package:brutal_wallz/globals/app_state.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:brutal_wallz/components/brutal_button.dart';
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
  final Color bg = const Color(0xFFF4F0E6);

  final Color yellow = const Color(0xFFFDE047);

  final Color pink = const Color(0xFFF9A8D4);

  final Color blue = const Color(0xFF93C5FD);

  final Color green = const Color(0xFF86EFAC);

  final Color orange = const Color(0xFFFDBA74);

  bool isModalOpen = false;

  bool isToastVisible = false;

  int _currentIndex = 0;

  String _searchQuery = '';

  String _selectedCategory = 'All';

  WallpaperModel? selectedWallpaper;

  List<WallpaperModel> favorites = [];

  List<WallpaperModel> get filteredWallpapers {
    final appState = AppState.of(context);
    return appState.wallpapers.where((wall) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          wall.cat.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch =
          _searchQuery.isEmpty ||
          wall.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          wall.cat.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppState.of(context, listen: false).fetchWallpapers();
    });
  }

  bool notificationsEnabled = true;

  double cacheSizeMb = 14.8;

  String toastMessage = 'WALLPAPER APPLIED!';

  void openWallpaper(WallpaperModel wall) {
    setState(() {
      selectedWallpaper = wall;
      isModalOpen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCurrentPage(),
            Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomNav()),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              top: isModalOpen ? 0 : size.height,
              bottom: isModalOpen ? 0 : -size.height,
              left: 0,
              right: 0,
              child: _buildModal(),
            ),
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
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return Column(
          children: [
            _buildHeader(),
            _buildCategories(),
            Expanded(child: _buildWallpaperGrid(filteredWallpapers)),
          ],
        );
      case 1:
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
        return _buildSettingsPage();
      default:
        return const SizedBox();
    }
  }

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
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: const Icon(Icons.close, color: Colors.black),
              )
            else
              const Icon(Icons.tune, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: blue,
        border: const Border(bottom: BorderSide(color: Colors.black, width: 4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCategoryBtn('All', yellow, Icons.local_fire_department),
          _buildCategoryBtn('General', Colors.white, Icons.wallpaper),
          _buildCategoryBtn('Anime', Colors.white, Icons.animation),
          _buildCategoryBtn('People', pink, Icons.people),
        ],
      ),
    );
  }

  Widget _buildCategoryBtn(String category, Color color, IconData icon) {
    final isSelected =
        _selectedCategory.toLowerCase() == category.toLowerCase();
    return SizedBox(
      width: 60,
      height: 60,
      child: BrutalButton(
        color: isSelected ? yellow : color,
        shadowOffset: 4,
        isActive: isSelected,
        onTap: () {
          setState(() {
            if (_selectedCategory.toLowerCase() == category.toLowerCase() &&
                category != 'All') {
              _selectedCategory = 'All';
            } else {
              _selectedCategory = category;
            }
          });
        },
        child: Icon(icon, size: 28),
      ),
    );
  }

  Widget _buildWallpaperGrid(List<WallpaperModel> list) {
    final appState = AppState.of(context);
    if (appState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }
    if (appState.error != null) {
      return Center(
        child: Text(
          appState.error!,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    }
    if (list.isEmpty) {
      return const Center(
        child: Text(
          'NO WALLPAPERS FOUND',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 100),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
            Image.asset(
              list[index].thumbnailUrl,
              cacheWidth: 300,
              fit: BoxFit.cover,
              errorBuilder: (c, o, s) => const Icon(Icons.broken_image, size: 50),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModal() {
    if (selectedWallpaper == null) {
      return const SizedBox();
    }
    final wall = selectedWallpaper!;
    final isFav = favorites.any((f) => f.id == wall.id);
    return Material(
      color: Colors.black,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: AssetImage(wall.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
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
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.black, width: 8)),
              ),
              child: Column(
                spacing: 16,
                children: [
                  Text(
                    wall.title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
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
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: BrutalButton(
                      color: green,
                      shadowOffset: 6,
                      onTap: setWallpaper,
                      child: const Center(
                        child: Text(
                          'SET AS WALLPAPER',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void closeWallpaper() {
    setState(() {
      isModalOpen = false;
    });
  }

  void toggleFavorite(WallpaperModel wall) {
    final isAlreadyFav = favorites.any((f) => f.id == wall.id);
    setState(() {
      if (isAlreadyFav) {
        favorites.removeWhere((f) => f.id == wall.id);
      } else {
        favorites.add(wall);
      }
    });
  }

  void showToast(String message) {
    setState(() {
      toastMessage = message;
      isToastVisible = true;
    });
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => isToastVisible = false);
      }
    });
  }

  void setWallpaper() {
    showToast('WALLPAPER APPLIED!');
  }

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

  Widget _buildNavTab(IconData icon, Color color, int index) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: BrutalButton(
        color: color,
        shadowOffset: 4,
        borderWidth: 2.0,
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
