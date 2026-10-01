import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brutal_wallz/globals/app_state.dart';
import 'package:brutal_wallz/globals/router.dart';

/// Global instance of [SharedPreferences] used for persistent key-value storage.
late final SharedPreferences sharedPrefs;

/// Application entry point.
/// Initializes bindings, asynchronously prepares persistent storage preferences,
/// and launches the root [MyApp] widget.
main() async {
  // Ensure Flutter engine bindings are initialized before accessing async platform channels.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences instance for app-wide persistence.
  sharedPrefs = await SharedPreferences.getInstance();

  // Run the application.
  runApp(const MyApp());
}

/// Root widget of the Brutal Wallz application.
/// Configures dependency injection via [MultiProvider], sets up app-wide themes,
/// and connects the declarative [GoRouter] navigation system.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide the global reactive application state (themes, wallpapers, UI flags)
        ChangeNotifierProvider<AppState>(create: (context) => AppState()),
      ],
      builder: (context, child) => MaterialApp.router(
        title: 'BRUTAL WALLZ',
        debugShowCheckedModeBanner: false,
        // Dynamically apply current theme from AppState
        theme: AppState.of(context).theme,
        // App routing configuration using GoRouter
        routerConfig: appRouter,
      ),
    );
  }
}
