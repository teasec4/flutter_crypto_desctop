import 'dart:io';
import 'package:crypto_desctop/core/constants/app_constants.dart';
import 'package:crypto_desctop/core/theme/app_theme.dart';
import 'package:crypto_desctop/core/theme/theme_cubit.dart';
import 'package:crypto_desctop/data/models/isar_coin_model.dart';
import 'package:crypto_desctop/data/models/isar_user_model.dart';
import 'package:crypto_desctop/data/models/portfolio_item_model.dart';
import 'package:crypto_desctop/di/service_locator.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';
import 'package:crypto_desctop/presentation/pages/auth_cubit.dart';
import 'package:crypto_desctop/presentation/pages/coin_cubit.dart';
import 'package:crypto_desctop/presentation/pages/portfolio_cubit.dart';
import 'package:crypto_desctop/router/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ThemeCubit themeCubit = ThemeCubit();

  try {
    // init Supabase
    await Supabase.initialize(
      url: 'https://bucuwdkctsufqxgspoqw.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ1Y3V3ZGtjdHN1ZnF4Z3Nwb3F3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMyNzc3MjUsImV4cCI6MjA3ODg1MzcyNX0.ynPRHsCLH9bvUIwkFRjRZX5ad6ntQwAdvbkJNMyhHaA',
    );

    // init Isar
    final dir = await getApplicationDocumentsDirectory();
    final isarDir = Directory('${dir.path}/isar_db');
    if (!isarDir.existsSync()) {
      isarDir.createSync();
    }

    final isar = await Isar.open([
      IsarCoinSchema,
      IsarUserSchema,
      PortfolioItemModelSchema,
    ], directory: isarDir.path);

    setupServiceLocator(isar);

    // Load saved theme preference
    await themeCubit.initialize();
  } catch (e) {
    debugPrint('Error initializing app: $e');
  }

  runApp(MyApp(themeCubit: themeCubit));
}

class MyApp extends StatelessWidget {
  final ThemeCubit themeCubit;

  const MyApp({required this.themeCubit, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: themeCubit),
        BlocProvider(
          create: (context) {
            // Don't load coins yet - wait for auth check
            // Security: Only load coins after user is verified as authorized
            return CoinCubit(getIt<CoinRepo>());
          },
        ),
        BlocProvider(
          create: (context) =>
              PortfolioCubit(portfolioRepository: getIt(), coinRepo: getIt()),
        ),
        BlocProvider(
          create: (context) {
            final portfolioCubit = context.read<PortfolioCubit>();
            final coinCubit = context.read<CoinCubit>();
            final authCubit = AuthCubit(getIt());

            // Set portfolio and coin cubit references BEFORE calling any methods
            authCubit.setPortfolioCubit(portfolioCubit);
            authCubit.setCoinCubit(coinCubit);

            // Check auth status after cubits are properly set
            // Use addPostFrameCallback to ensure all widgets are built
            WidgetsBinding.instance.addPostFrameCallback((_) {
              authCubit.checkAuthStatus();
            });

            return authCubit;
          },
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
            title: 'Crypto Desctop App',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeState is ThemeDark
                ? ThemeMode.dark
                : ThemeMode.light,
            // home: const HomePage(),
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Widget child;

  const HomePage({required this.child, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _getSelectedIndex(BuildContext context) {
    final uri = GoRouter.of(context).routeInformationProvider.value.uri;
    final location = uri.toString();
    if (location == AppConstants.portfolioRoute) return 1;
    if (location == AppConstants.settingsRoute) return 2;
    return 0;
  }

  void _onSelectIndex(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppConstants.homeRoute);
        break;
      case 1:
        context.go(AppConstants.portfolioRoute);
        break;
      case 2:
        context.go(AppConstants.settingsRoute);
        break;
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isWide = width >= AppConstants.wideLayoutBreakpoint;
    final bool isMedium =
        width >= AppConstants.mediumLayoutBreakpoint && !isWide;
    final bool isNarrow = width < AppConstants.mediumLayoutBreakpoint;
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: isNarrow ? _buildDrawer(context, selectedIndex) : null,
      appBar: isNarrow
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            )
          : null,
      body: Row(
        children: [
          // Wide layout
          if (isWide)
            NavigationRail(
              selectedIndex: selectedIndex,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (i) => _onSelectIndex(i, context),
              destinations: _destinations,
            ),

          // Medium layout
          if (!isWide && isMedium)
            NavigationRail(
              selectedIndex: selectedIndex,
              labelType: NavigationRailLabelType.none,
              onDestinationSelected: (i) => _onSelectIndex(i, context),
              minWidth: 60,
              groupAlignment: -1.0,
              destinations: _destinations,
            ),

          // Main content
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, int selectedIndex) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text("Home"),
                    selected: selectedIndex == 0,
                    onTap: () {
                      context.go(AppConstants.homeRoute);
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: const Text("Portfolio"),
                    selected: selectedIndex == 1,
                    onTap: () {
                      context.go(AppConstants.portfolioRoute);
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: const Text("Settings"),
                    selected: selectedIndex == 2,
                    onTap: () {
                      context.go(AppConstants.settingsRoute);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            // User info and sync status
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                final userEmail = (authState is AuthAuthenticated)
                    ? authState.user.email
                    : 'Guest';
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        userEmail,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.cloud_done,
                            size: 14,
                            color: Colors.green.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Synchronized',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'v1.0.0',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Made with Flutter',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<NavigationRailDestination> get _destinations => const [
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: Text('Home'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.pie_chart_outline),
      selectedIcon: Icon(Icons.pie_chart),
      label: Text('Portfolio'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: Text('Settings'),
    ),
  ];
}
