import 'package:go_router/go_router.dart';
import 'package:brutal_wallz/pages/home_page.dart';
import 'package:brutal_wallz/pages/login_page.dart';
import 'package:brutal_wallz/pages/loading_page.dart';
import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
final GoRouter appRouter = GoRouter(
  initialLocation: '/login-page',
  routes: [
    GoRoute(path: '/login-page',  builder: (context, state) => const LoginPage()),
    GoRoute(path: '/loading-page', builder: (context, state) => const LoadingPage()),
    GoRoute(path: '/home-page',   builder: (context, state) => const HomePage()),
  ],
);
