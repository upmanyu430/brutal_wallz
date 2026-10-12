import 'dart:async';
import 'package:flutter/services.dart';

/// Lightweight native wallpaper management service using Android's WallpaperManager.
class WallpaperService {
  static const MethodChannel _channel = MethodChannel('async_wallpaper');

  /// Target Home Screen wallpaper
  static const int HOME_SCREEN = 1;

  /// Target Lock Screen wallpaper
  static const int LOCK_SCREEN = 2;

  /// Target both Home and Lock Screen wallpapers
  static const int BOTH_SCREENS = 3;

  /// Sets device wallpaper from a local file path.
  static Future<bool> setWallpaperFromFile({
    required String filePath,
    int wallpaperLocation = BOTH_SCREENS,
    bool goToHome = false,
  }) async {
    final options = {
      'url': filePath,
      'goToHome': goToHome,
    };

    final String method;
    switch (wallpaperLocation) {
      case HOME_SCREEN:
        method = 'set_home_wallpaper_file';
        break;
      case LOCK_SCREEN:
        method = 'set_lock_wallpaper_file';
        break;
      case BOTH_SCREENS:
      default:
        method = 'set_both_wallpaper_file';
        break;
    }

    final result = await _channel.invokeMethod<bool>(method, options);
    return result ?? false;
  }

  /// Sets device wallpaper from a remote image URL.
  static Future<bool> setWallpaper({
    required String url,
    int wallpaperLocation = BOTH_SCREENS,
    bool goToHome = false,
  }) async {
    final options = {
      'url': url,
      'goToHome': goToHome,
    };

    final String method;
    switch (wallpaperLocation) {
      case HOME_SCREEN:
        method = 'set_home_wallpaper';
        break;
      case LOCK_SCREEN:
        method = 'set_lock_wallpaper';
        break;
      case BOTH_SCREENS:
      default:
        method = 'set_both_wallpaper';
        break;
    }

    final result = await _channel.invokeMethod<bool>(method, options);
    return result ?? false;
  }
}

/// Backward compatibility alias
typedef AsyncWallpaper = WallpaperService;
