import 'package:crypto_desctop/presentation/pages/coin_detail_page.dart';
import 'package:crypto_desctop/presentation/pages/content_page.dart';
import 'package:crypto_desctop/main.dart';
import 'package:crypto_desctop/presentation/pages/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => HomePage(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ContentPage(),
          ),
        ),
        GoRoute(
          path: '/portfolio',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: Center(child: Text("Portfolio Page")),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsView(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/coin/:coinId',
      pageBuilder: (context, state) {
        final coinId = state.pathParameters['coinId']!;
        return MaterialPage(
          child: CoinDetailPage(coinId: coinId),
        );
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