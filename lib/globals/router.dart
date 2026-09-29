import 'package:go_router/go_router.dart';
import 'package:brutal_wallz/pages/home_page.dart';
import 'package:brutal_wallz/pages/login_page.dart';
import 'package:brutal_wallz/pages/loading_page.dart';
import 'package:nowa_runtime/nowa_runtime.dart';

/// Declarative router configuration powered by [GoRouter].
/// Defines route paths and connects them to corresponding top-level page widgets.
@NowaGenerated()
final GoRouter appRouter = GoRouter(
  // The initial entry route when the app launches (Login / Welcome page)
  initialLocation: '/login-page',
  routes: [
    // Welcome, social sign-in, and account creation screen
    GoRoute(
      path: '/login-page',
      builder: (context, state) => const LoginPage(),
    ),
    // Animated neo-brutalist transition/loading splash screen
    GoRoute(
      path: '/loading-page',
      builder: (context, state) => const LoadingPage(),
    ),
    // Main dashboard displaying wallpaper gallery, favorites, and settings
    GoRoute(
      path: '/home-page',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
