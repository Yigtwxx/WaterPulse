import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waterpulse/core/widgets/scaffold_with_nav_bar.dart';
import 'package:waterpulse/features/auth/providers/auth_provider.dart';
import 'package:waterpulse/features/auth/screens/login_screen.dart';
import 'package:waterpulse/features/auth/screens/register_screen.dart';
import 'package:waterpulse/features/home/home_screen.dart';
import 'package:waterpulse/features/home/screens/achievements_screen.dart';
import 'package:waterpulse/features/datas/screens/datas_screen.dart';
import 'package:waterpulse/features/social/friends_screen.dart';

// Private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorFriendsKey = GlobalKey<NavigatorState>(debugLabel: 'shellFriends');
final _shellNavigatorAchievementsKey = GlobalKey<NavigatorState>(debugLabel: 'shellAchievements');
final _shellNavigatorDatasKey = GlobalKey<NavigatorState>(debugLabel: 'shellDatas');
final _shellNavigatorSportsKey = GlobalKey<NavigatorState>(debugLabel: 'shellSports');

final routerProvider = Provider<GoRouter>((ref) {
  // Do not watch authProvider here to avoid rebuilding GoRouter on auth changes
  // final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(ref.watch(authProvider.notifier).stream),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.uri.path == '/login';
      final isRegistering = state.uri.path == '/register';

      if (!isLoggedIn && !isLoggingIn && !isRegistering) {
        return '/login';
      }

      if (isLoggedIn && (isLoggingIn || isRegistering)) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // 1) Home Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),

          // 2) Friends Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorFriendsKey,
            routes: [
              GoRoute(
                path: '/friends',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: FriendsScreen(),
                ),
              ),
            ],
          ),

          // 3) Achievements Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorAchievementsKey,
            routes: [
              GoRoute(
                path: '/achievements',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AchievementsScreen(),
                ),
              ),
            ],
          ),

          // 4) Datas Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDatasKey,
            routes: [
              GoRoute(
                path: '/datas',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DatasScreen(),
                ),
              ),
            ],
          ),

          // 5) Sports Branch (Placeholder)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSportsKey,
            routes: [
              GoRoute(
                path: '/sports',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: Scaffold(
                    body: Center(
                      child: Text('Sports Integration Coming Soon'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
