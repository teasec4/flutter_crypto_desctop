import 'package:crypto_desctop/main.dart';
import 'package:crypto_desctop/presentation/pages/auth_cubit.dart';
import 'package:crypto_desctop/presentation/pages/coin_detail_page.dart';
import 'package:crypto_desctop/presentation/pages/content_page.dart';
import 'package:crypto_desctop/presentation/pages/login_page.dart';
import 'package:crypto_desctop/presentation/pages/portfolio_page.dart';
import 'package:crypto_desctop/presentation/pages/register_page.dart';
import 'package:crypto_desctop/presentation/pages/settings_view.dart';
import 'package:crypto_desctop/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    // Get auth cubit from context
    final authState = context.read<AuthCubit>().state;
    final isAuth = authState is AuthAuthenticated;
    final isInitializing = authState is AuthInitializing;

    final isAuthRoute =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/splash';

    // Show splash screen while initializing
    if (isInitializing && !state.matchedLocation.startsWith('/splash')) {
      return '/splash';
    }

    // Redirect to login if not authenticated and trying to access protected routes
    if (!isAuth && !isInitializing && !isAuthRoute) {
      return '/login';
    }

    // Redirect to home if authenticated and trying to access auth routes
    if (isAuth && isAuthRoute) {
      return '/';
    }

    // No redirect needed
    return null;
  },
  routes: [
    // Auth routes
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => const MaterialPage(child: LoginPage()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) =>
          const MaterialPage(child: RegisterPage()),
    ),
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) {
        final authState = context.read<AuthCubit>().state;
        final userName = (authState is AuthInitializing)
            ? authState.user.displayName
            : null;
        return MaterialPage(child: SplashPage(userName: userName));
      },
    ),

    // Main app routes with shell
    ShellRoute(
      builder: (context, state, child) => HomePage(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ContentPage()),
        ),
        GoRoute(
          path: '/portfolio',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: PortfolioPage()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsView()),
        ),
      ],
    ),

    // Detail routes
    GoRoute(
      path: '/coin/:coinId',
      pageBuilder: (context, state) {
        final coinId = state.pathParameters['coinId']!;
        return MaterialPage(child: CoinDetailPage(coinId: coinId));
      },
    ),
  ],
);

// Расширение для типобезопасной навигации
extension CoinRouting on BuildContext {
  void goToCoinDetail(String coinId) {
    push('/coin/$coinId');
  }
}
