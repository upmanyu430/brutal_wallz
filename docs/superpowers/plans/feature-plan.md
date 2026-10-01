# Frontend: Theming & UI Plan

## Global Constraints
- Target Language: Dart (Flutter)
- Ensure changes are formatted properly.
- Ensure state updates trigger UI updates correctly.

## Tasks

### Task 1: Dynamic Theme Inheritance
- **Target File**: `lib/pages/home_page.dart`
- **Requirement**: The main `Scaffold` has a hardcoded background color (`backgroundColor: bg`). Remove this and replace it with `Theme.of(context).scaffoldBackgroundColor` so it respects the global theme.

### Task 2: Theme Toggle Switch
- **Target File**: `lib/pages/home_page.dart`
- **Requirement**: Add a "Dark Mode" toggle in the `_buildSettingsPage()` method of `home_page.dart` that triggers `AppState.of(context, listen: false).changeTheme()`.
