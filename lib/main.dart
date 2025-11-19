import 'dart:io';
import 'package:crypto_desctop/core/cubits/connectivity_cubit.dart';
import 'package:crypto_desctop/core/constants/app_constants.dart';
import 'package:crypto_desctop/core/theme/app_theme.dart';
import 'package:crypto_desctop/core/theme/theme_cubit.dart';
import 'package:crypto_desctop/data/models/isar_coin_model.dart';
import 'package:crypto_desctop/data/models/portfolio_item_model.dart';
import 'package:crypto_desctop/di/service_locator.dart';
import 'package:crypto_desctop/domain/repository/coin_repo.dart';
import 'package:crypto_desctop/presentation/pages/auth_cubit.dart';
import 'package:crypto_desctop/presentation/pages/coin_cubit.dart';
import 'package:crypto_desctop/presentation/pages/coin_search_cubit.dart';
import 'package:crypto_desctop/presentation/pages/portfolio_cubit.dart';
import 'package:crypto_desctop/presentation/widgets/connectivity_banner.dart';
import 'package:crypto_desctop/router/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  ThemeCubit themeCubit = ThemeCubit();

  try {
    // init Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );

    // init Isar
    final dir = await getApplicationDocumentsDirectory();
    final isarDir = Directory('${dir.path}/isar_db');
    if (!isarDir.existsSync()) {
      isarDir.createSync();
    }

    final isar = await Isar.open([
      IsarCoinSchema,
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
        BlocProvider.value(value: getIt<ConnectivityCubit>()),
        BlocProvider(
          create: (context) {
            // Don't load coins yet - wait for auth check
            // Security: Only load coins after user is verified as authorized
            return CoinCubit(getIt<CoinRepo>(), getIt<ConnectivityCubit>());
          },
        ),
        BlocProvider(
          create: (context) =>
              CoinSearchCubit(allCoins: [], coinRepo: getIt<CoinRepo>()),
        ),
        BlocProvider(
          create: (context) => PortfolioCubit(
            portfolioRepository: getIt(),
            coinRepo: getIt(),
            connectivityCubit: getIt<ConnectivityCubit>(),
          ),
        ),
        BlocProvider(
          create: (context) {
            final portfolioCubit = context.read<PortfolioCubit>();
            final coinCubit = context.read<CoinCubit>();
            // AuthCubit(AuthRepository authRepository)
            // getIt() → getIt<AuthRepository>() → instance of AuthRepositoryImpl
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
            builder: (context, child) {
              return Column(
                children: [
                  const ConnectivityBanner(),
                  Expanded(child: child ?? const SizedBox.shrink()),
                ],
              );
            },
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
    // Clear search when navigating away from home tab
    if (index != 0) {
      context.read<CoinSearchCubit>().clearSearch();
    }

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

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Market';
      case 1:
        return 'Portfolio';
      case 2:
        return 'Settings';
      default:
        return '';
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
              title: Text(
                _getPageTitle(selectedIndex),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              centerTitle: false,
              actions: [
                // Theme toggle
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, themeState) {
                    final isDark = themeState is ThemeDark;
                    return IconButton(
                      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                      onPressed: () {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                    );
                  },
                ),
                // Auth buttons
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    if (authState is AuthAuthenticated) {
                      return IconButton(
                        icon: const Icon(Icons.person),
                        onPressed: () {
                          context.go(AppConstants.settingsRoute);
                        },
                      );
                    } else {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              context.go(AppConstants.loginRoute);
                            },
                            child: const Text('Login'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              context.go(AppConstants.registerRoute);
                            },
                            child: const Text('Register'),
                          ),
                          const SizedBox(width: 8),
                        ],
                      );
                    }
                  },
                ),
              ],
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Crypto App',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your crypto portfolio',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildNavItem(
                    context,
                    title: 'Home',
                    icon: Icons.home_rounded,
                    selectedIcon: Icons.home,
                    isSelected: selectedIndex == 0,
                    onTap: () {
                      context.go(AppConstants.homeRoute);
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildNavItem(
                    context,
                    title: 'Portfolio',
                    icon: Icons.pie_chart_outline,
                    selectedIcon: Icons.pie_chart,
                    isSelected: selectedIndex == 1,
                    onTap: () {
                      context.read<CoinSearchCubit>().clearSearch();
                      context.go(AppConstants.portfolioRoute);
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildNavItem(
                    context,
                    title: 'Settings',
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    isSelected: selectedIndex == 2,
                    onTap: () {
                      context.read<CoinSearchCubit>().clearSearch();
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
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Theme toggle
                      BlocBuilder<ThemeCubit, ThemeState>(
                        builder: (context, themeState) {
                          final isDark = themeState is ThemeDark;
                          return Row(
                            children: [
                              Icon(
                                isDark ? Icons.dark_mode : Icons.light_mode,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    context.read<ThemeCubit>().toggleTheme();
                                  },
                                  child: Text(
                                    isDark ? 'Dark Mode' : 'Light Mode',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                              Switch(
                                value: isDark,
                                onChanged: (value) {
                                  context.read<ThemeCubit>().toggleTheme();
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'v1.0.0',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Made with Flutter',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
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

  Widget _buildNavItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required IconData selectedIcon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            border: isSelected
                ? Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, size: 20, color: colorScheme.primary),
            ],
          ),
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
