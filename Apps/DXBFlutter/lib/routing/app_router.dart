import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/auth_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/esim/screens/esim_list_screen.dart';
import '../features/esim/screens/esim_detail_screen.dart';
import '../features/esim/screens/plan_list_screen.dart';
import '../features/esim/models/esim_models.dart';
import '../features/rewards/screens/rewards_screen.dart';
import '../features/offers/screens/offers_screen.dart';
import '../features/subscription/screens/subscription_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import 'shell_screen.dart';

class _AuthChangeNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthChangeNotifier();

  ref.listen(authProvider, (_, __) {
    authNotifier.notify();
  });

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuth = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/auth';

      if (!isAuth && !isAuthRoute) return '/auth';
      if (isAuth && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'plans',
                    builder: (context, state) => const PlanListScreen(),
                  ),
                  GoRoute(
                    path: 'offers',
                    builder: (context, state) => const OffersScreen(),
                  ),
                  GoRoute(
                    path: 'subscription',
                    builder: (context, state) => const SubscriptionScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/esims',
                builder: (context, state) => const EsimListScreen(),
                routes: [
                  GoRoute(
                    path: ':orderNo',
                    builder: (context, state) {
                      final esim = state.extra as EsimOrder;
                      return EsimDetailScreen(esim: esim);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rewards',
                builder: (context, state) => const RewardsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
