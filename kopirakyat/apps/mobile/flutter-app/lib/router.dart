import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/providers.dart';
import 'features/cart/cart_screen.dart';
import 'features/checkout/checkout_screen.dart';
import 'features/home/home_screen.dart';
import 'features/locator/locator_screen.dart';
import 'features/loyalty/loyalty_screen.dart';
import 'features/menu/menu_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/product/product_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/qr/qr_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/tracking/tracking_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Rebuilding the router on auth transitions (no session -> guest ->
  // signed-in) mirrors the prototype resetting to `home` after verify/guest.
  final user = ref.watch(currentUserProvider);
  final signedIn = ref.watch(isSignedInProvider);

  return GoRouter(
    initialLocation: user == null ? '/onboarding' : '/home',
    redirect: (context, state) {
      final onOnboarding = state.matchedLocation == '/onboarding';
      // No session at all (not even guest) -> force onboarding.
      if (user == null && !onOnboarding) return '/onboarding';
      // Fully signed in (not just guest) visiting onboarding -> already done.
      if (signedIn && onOnboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/menu', builder: (context, state) => const MenuScreen()),
          GoRoute(path: '/merch', builder: (context, state) => const LoyaltyScreen()),
          GoRoute(path: '/locator', builder: (context, state) => const LocatorScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/product/:slug',
        builder: (context, state) => ProductScreen(slug: state.pathParameters['slug']!),
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (context, state) => const CheckoutScreen()),
      GoRoute(
        path: '/tracking/:orderId',
        builder: (context, state) => TrackingScreen(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(path: '/qr', builder: (context, state) => const QrScreen()),
    ],
  );
});
