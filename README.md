# ⚡ BRUTAL WALLZ

```
 █▀▀▄ █▀▀█ █──█ ▀▀█▀▀ █▀▀█ █──   █───█ █▀▀█ █── █── ▀▀▀█
 █▀▀▄ █▄▄▀ █──█ ──█── █▄▄█ █──   █▄█▄█ █▄▄█ █── █── ──█─
 ▀▀▀─ ▀─▀▀ ─▀▀▀ ──▀── ▀──▀ ▀▀▀   ─▀─▀─ ▀──▀ ▀▀▀ ▀▀▀ ▀▀▀─
```

> **A bold, high-contrast, neo-brutalist wallpaper application engineered with Flutter & native Kotlin.**

[![Flutter](https://img.shields.io/badge/Flutter-3.27.4-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.2+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://android.com)
[![Design](https://img.shields.io/badge/Aesthetic-Neo--Brutalist-FDE047?style=for-the-badge&color=FDE047&labelColor=000000)](https://github.com)
[![Tests](https://img.shields.io/badge/Tests-49%2F49%20Passing-86EFAC?style=for-the-badge&labelColor=000000)](https://github.com)
[![License](https://img.shields.io/badge/License-MIT-F9A8D4?style=for-the-badge&labelColor=000000)](LICENSE)

---

## 🖤 Overview

**Brutal Wallz** reimagines mobile wallpaper discovery through the lens of **Neo-Brutalism**. Stripping away delicate gradients and subtle glassmorphism, it embraces unapologetic raw design: heavy 2–3px solid black borders, hard offset drop shadows (`4px 4px 0px #000000`), a high-contrast pastel pop palette, and industrial monospace typography powered by **Ubuntu Sans Mono**.

Beyond aesthetics, Brutal Wallz is built for speed and reliability. It combines an **offline-first curated asset bundle** with a **zero-dependency native Kotlin `WallpaperManager`** engine, allowing you to preview, test, save, and apply wallpapers to your device in milliseconds.

---

## ✨ Features

- 🎨 **Authentic Neo-Brutalist Design**: Hand-crafted UI widgets with tactile button press physics, thick borders, flat hard shadows, and bold contrasting colors.
- 📱 **Native Android Wallpaper Engine**: Direct platform channel integration (`MethodChannel('async_wallpaper')`) with Android's native `WallpaperManager`. Set wallpapers to **Home Screen**, **Lock Screen**, or **Both** instantly without heavy third-party plugins.
- 👁️ **Interactive Lock Screen Simulator**: Tap the preview icon to project simulated lock-screen elements (clock, date, notification bar) over any wallpaper to verify composition before applying.
- 💾 **Direct-to-Gallery Downloads**: Save full-resolution wallpapers to the device photo library with one tap using native storage APIs (`gal`).
- ⚡ **Offline-Ready & Bundled Collections**: Pre-packaged with over 60 high-resolution wallpapers and structured JSON metadata (`assets/wallpapers.json`) for zero-latency instant offline exploration.
- 🔍 **Instant Search & Category Filters**: Real-time filtering across wallpaper titles and categories (`General`, `Anime`, `People`).
- ❤️ **Persistent Favorites Collection**: Bookmark favorite wallpapers with instant offline persistence via `SharedPreferences`.
- 🔄 **Custom Tactile Pull-to-Refresh**: Neo-brutalist animated pull-to-refresh (`BrutalRefreshIndicator`) with custom micro-interactions.
- 🌗 **Adaptive Dual Themes**: Light Neo-Brutalist (cream paper background `#F4F0E6`) and high-contrast Dark Mono mode.
- 🧭 **Declarative Deep Routing**: Robust screen management using `go_router` with persistent auth state redirects (`/login-page` ➔ `/loading-page` ➔ `/home-page`).
- 🛠️ **Automated Wallhaven Scraper CLI**: Built-in asset pipeline script (`scripts/download_wallpapers.dart`) with rate-limiting, exponential backoff, and automatic metadata manifest generation.
- 🧪 **Comprehensive Test Suite**: 49 automated unit, widget, and platform-channel mock tests running on GitHub Actions CI.

---

## 🎨 Design System & Palette

Brutal Wallz adheres strictly to a signature neo-brutalist color system:

| Swatch | Color Name | Hex Code | Purpose |
|:---:|:---|:---:|:---|
| ![#F4F0E6](https://via.placeholder.com/15/F4F0E6/000000?text=+) | **Paper Cream** | `#F4F0E6` | Primary background canvas |
| ![#FDE047](https://via.placeholder.com/15/FDE047/000000?text=+) | **Cyber Yellow** | `#FDE047` | Primary buttons, active tabs, hero highlights |
| ![#F9A8D4](https://via.placeholder.com/15/F9A8D4/000000?text=+) | **Bubblegum Pink** | `#F9A8D4` | Favorite badges, love actions, alert accents |
| ![#93C5FD](https://via.placeholder.com/15/93C5FD/000000?text=+) | **Pastel Blue** | `#93C5FD` | Secondary buttons, category chips, informational modals |
| ![#86EFAC](https://via.placeholder.com/15/86EFAC/000000?text=+) | **Neon Mint** | `#86EFAC` | Success toasts, apply confirmations, active states |
| ![#FDBA74](https://via.placeholder.com/15/FDBA74/000000?text=+) | **Warm Orange** | `#FDBA74` | Warning cues, tertiary actions |
| ![#000000](https://via.placeholder.com/15/000000/FFFFFF?text=+) | **Ink Black** | `#000000` | High-contrast 2–3px structural borders & 4px hard drop shadows |

**Typography**: Monospaced weights (Regular, Medium, SemiBold, Bold) provided by [`Ubuntu Sans Mono`](https://fonts.google.com/specimen/Ubuntu+Sans+Mono).

---

## 📱 Application Flow

```
┌────────────────────────┐
│      LoginPage         │  ➜ Welcome banner, Google Sign-in & Guest Access
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│     LoadingPage        │  ➜ Neo-brutalist animated progress bar & color cycles
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│       HomePage         │  ➜ Bottom navigation with 3 core workspaces:
├────────────────────────┤
│  [1] Explore Gallery   │  ➜ Infinite grid, live search, pull-to-refresh
│  [2] Favorites         │  ➜ Persisted saved wallpapers
│  [3] Settings          │  ➜ Theme toggle, cache clearing, system info
└───────────┬────────────┘
            │ (Tap wallpaper card)
            ▼
┌────────────────────────┐
│   Wallpaper Modal      │
├────────────────────────┤
│  • Fullscreen View     │  ➜ High-res cached network / local asset render
│  • Lock Screen Sim     │  ➜ Overlay real-time clock & notification preview
│  • Save to Gallery     │  ➜ Direct file export via Gal
│  • Set Wallpaper       │  ➜ Bottom sheet: [Home] / [Lock] / [Both Screens]
└────────────────────────┘
```

---

## 🏗️ Architecture & Project Structure

```
brutal_wallz/
├── .github/workflows/       # GitHub Actions CI pipeline (linting & tests)
├── android/                 # Native Android container & WallpaperManager implementation
│   └── app/src/main/kotlin/.../MainActivity.kt  # MethodChannel native wallpaper handler
├── assets/
│   ├── fonts/               # Ubuntu Sans Mono font family
│   ├── wallpapers/          # Curated offline high-res wallpaper assets
│   └── wallpapers.json      # Structured wallpaper metadata database
├── bin/
│   └── test_api.dart        # Standalone API probe script
├── lib/
│   ├── components/
│   │   ├── brutal_button.dart             # Reusable neo-brutalist button with hard shadow
│   │   └── brutal_refresh_indicator.dart  # Tactile custom pull-to-refresh
│   ├── globals/
│   │   ├── app_constants.dart             # Storage keys and static constants
│   │   ├── app_state.dart                 # Global ChangeNotifier state (wallpapers, pagination)
│   │   ├── router.dart                    # GoRouter configuration & navigation guards
│   │   └── themes.dart                    # Light & Dark neo-brutalist ThemeData
│   ├── models/
│   │   └── wallpaper_model.dart           # Immutable wallpaper data model (JSON deserialization)
│   ├── pages/
│   │   ├── home_page.dart                 # Core dashboard (gallery, favorites, settings, modal)
│   │   ├── loading_page.dart              # Animated splash transition
│   │   └── login_page.dart                # Welcome & authentication screen
│   ├── services/
│   │   └── wallpaper_service.dart         # MethodChannel bridge to native WallpaperManager
│   └── main.dart                          # App initialization, SharedPreferences, MultiProvider
├── scripts/
│   └── download_wallpapers.dart           # Wallhaven API scraper & asset bundler
└── test/                                  # 49 automated unit, widget, and mock tests
```

---

## ⚙️ Tech Stack & Key Libraries

| Package | Version | Purpose |
|:---|:---|:---|
| [`flutter`](https://flutter.dev) | `3.27.4` | Cross-platform UI toolkit |
| [`provider`](https://pub.dev/packages/provider) | `^6.1.5` | Reactive app state management (`AppState`) |
| [`go_router`](https://pub.dev/packages/go_router) | `^16.1.0` | Declarative routing and deep navigation |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | `^6.3.0` | Monospaced typography (`Ubuntu Sans Mono`) |
| [`cached_network_image`](https://pub.dev/packages/cached_network_image) | `^3.4.1` | Efficient multi-tier image caching & memory management |
| [`flutter_cache_manager`](https://pub.dev/packages/flutter_cache_manager) | `^3.4.1` | Cache eviction, disk storage, and offline retrieval |
| [`gal`](https://pub.dev/packages/gal) | `^2.3.3` | Cross-platform gallery storage and photo saving |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | `^2.5.3` | Persistent storage for bookmarks and user settings |
| [`custom_refresh_indicator`](https://pub.dev/packages/custom_refresh_indicator) | `^4.0.2` | Custom neo-brutalist pull-to-refresh physics |
| [`dio`](https://pub.dev/packages/dio) | `^5.11.1` | HTTP client for remote network requests |

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.27.0`)
- [Android SDK](https://developer.android.com/studio) (API level 21+)
- [Git](https://git-scm.com/)

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/brutal_wallz.git
cd brutal_wallz
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

Connect an Android device or launch an emulator:

```bash
flutter run
```

---

## 🛠️ Offline Asset Scraper CLI

Brutal Wallz includes a built-in Dart script to download fresh batches of wallpapers directly from Wallhaven and package them for offline bundling:

```bash
dart run scripts/download_wallpapers.dart
```

### What this script does:
1. Queries the Wallhaven API (`https://wallhaven.cc/api/v1/search?sorting=random`).
2. Applies a custom User-Agent to prevent 403 CDN blocks.
3. Downloads the top wallpapers into `assets/wallpapers/`.
4. Handles API rate limits (`429 Too Many Requests`) with automatic exponential backoff.
5. Updates `assets/wallpapers.json` with IDs, dimensions, categories, and relative asset paths.

---

## 🧪 Testing & Quality Assurance

Brutal Wallz is covered by a robust test suite covering model parsing, reactive state transitions, custom widget rendering, wallpaper application, and system back gestures.

### Run All Tests

```bash
flutter test
```

### Run Static Analysis

```bash
flutter analyze
```

### Run Specific Test Suites

```bash
flutter test test/app_state_test.dart
flutter test test/home_page_test.dart
flutter test test/wallpaper_application_test.dart
flutter test test/brutal_button_test.dart
```

---

## 🔌 Native Android Platform Channel

Brutal Wallz communicates with Android's native `android.app.WallpaperManager` via a lightweight `MethodChannel` (`async_wallpaper`) defined in `android/app/src/main/kotlin/.../MainActivity.kt`.

### Supported Method Calls

| Method Call | Arguments | Description |
|:---|:---|:---|
| `set_home_wallpaper_file` | `{'url': String, 'goToHome': bool}` | Sets Home Screen wallpaper from local file |
| `set_lock_wallpaper_file` | `{'url': String, 'goToHome': bool}` | Sets Lock Screen wallpaper from local file |
| `set_both_wallpaper_file` | `{'url': String, 'goToHome': bool}` | Sets both Home and Lock Screen wallpapers |
| `set_home_wallpaper` | `{'url': String, 'goToHome': bool}` | Downloads & sets Home Screen wallpaper |
| `set_lock_wallpaper` | `{'url': String, 'goToHome': bool}` | Downloads & sets Lock Screen wallpaper |
| `set_both_wallpaper` | `{'url': String, 'goToHome': bool}` | Downloads & sets both wallpapers |

*All wallpaper bitmap decoding runs off the UI thread via Kotlin worker threads to prevent frame drops.*

---

## 🤝 Contributing

Contributions are welcome! To maintain consistency:

1. Fork the repository and create your feature branch:
   ```bash
   git checkout -b feat/your-feature-name
   ```
2. Ensure all formatting and linter checks pass:
   ```bash
   dart format .
   flutter analyze
   ```
3. Verify test coverage:
   ```bash
   flutter test
   ```
4. Follow [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `refactor:`, `test:`).
5. Open a Pull Request.

---

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.
