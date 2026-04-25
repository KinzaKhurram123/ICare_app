import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:icare/models/auth.dart';
import 'package:icare/providers/auth_provider.dart';
import 'package:icare/screens/login.dart';
import 'package:icare/screens/public_home.dart';
import 'package:icare/screens/signup.dart';
import 'package:icare/screens/splash.dart';
import 'package:icare/screens/tabs.dart';
import 'package:icare/screens/work_with_us_signup.dart';
import 'package:icare/utils/shared_pref.dart';
import 'package:icare/utils/app_keys.dart';

/// Loads auth from SharedPrefs once on app start and populates authProvider.
final authInitProvider = FutureProvider<void>((ref) async {
  try {
    final token = await SharedPref().getToken();
    if (token != null && token.isNotEmpty) {
      await ref.read(authProvider.notifier).setUserToken(token);
      final userRole = await SharedPref().getUserRole();
      if (userRole != null) {
        await ref.read(authProvider.notifier).setUserRole(userRole);
      }
      final userData = await SharedPref().getUserData();
      if (userData != null) {
        await ref.read(authProvider.notifier).setUser(userData);
      }
    }
  } catch (_) {}
});

/// Notifies go_router when auth or init state changes so redirect reruns.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen<AsyncValue<void>>(authInitProvider, (_, __) => notifyListeners());
    ref.listen<Auth>(authProvider, (_, __) => notifyListeners());
  }
}

final _routerNotifierProvider = Provider<_RouterNotifier>((ref) {
  return _RouterNotifier(ref);
});

/// Public paths that don't require authentication.
const _publicPaths = ['/home', '/login', '/signup', '/work-with-us', '/splash'];

final routerProvider = Provider<GoRouter>((ref) {
  // Trigger auth init as soon as router is created.
  ref.watch(authInitProvider);
  final notifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    navigatorKey: appNavigatorKey,
    initialLocation: '/home',
    observers: [FlutterSmartDialog.observer],
    refreshListenable: notifier,
    redirect: (context, state) {
      final authInit = ref.read(authInitProvider);

      // Still loading auth from SharedPrefs → show splash.
      if (authInit.isLoading) return '/splash';

      final isLoggedIn = ref.read(authProvider).isLoggedIn;
      final path = state.matchedLocation;
      final isPublic = _publicPaths.contains(path);

      // Not logged in trying to access protected route → home.
      if (!isLoggedIn && !isPublic) return '/home';

      // Logged in trying to visit public route → dashboard.
      if (isLoggedIn && isPublic && path != '/splash') return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/home', builder: (_, __) => const PublicHome()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/work-with-us', builder: (_, __) => const WorkWithUsSignup()),
      GoRoute(path: '/dashboard', builder: (_, __) => const TabsScreen()),
    ],
  );
});
