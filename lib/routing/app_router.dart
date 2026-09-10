import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/build_type.dart';
import '../data/supabase_client.dart';
import '../features/auth/auth_screen.dart';
import '../features/home/main_screen.dart';
import '../features/register/register_screen.dart';
import '../features/track_detail/track_detail_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  GoRouterRefreshStream(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouter = GoRouter(
  initialLocation: '/auth',
  refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
  redirect: (context, state) {
    final isLoggedIn = supabase.auth.currentSession != null;
    final isOnAuthScreen = state.matchedLocation == '/auth';

    if (!isLoggedIn && !isOnAuthScreen) return '/auth';
    if (isLoggedIn && isOnAuthScreen) return '/main';
    return null;
  },
  routes: [
    GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
    GoRoute(path: '/main', builder: (context, state) => const MainScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterScreen(
        initialBuildType: state.extra as BuildType? ?? BuildType.optimal,
      ),
    ),
    GoRoute(
      path: '/track/:id',
      builder: (context, state) => TrackDetailScreen(
        trackId: int.parse(state.pathParameters['id']!),
        initialBuildType: state.extra as BuildType? ?? BuildType.optimal,
      ),
    ),
  ],
);
