import 'package:crypto_desctop/core/theme/app_theme.dart';
import 'package:crypto_desctop/core/theme/theme_cubit.dart';
import 'package:crypto_desctop/presentation/pages/content_page.dart';
import 'package:crypto_desctop/presentation/pages/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Crypto Desctop App',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeState is ThemeDark ? ThemeMode.dark : ThemeMode.light,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onSelectIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop(); // close Drawer
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isWide = width >= 1000;
    final bool isMedium = width >= 700;
    final bool isNarrow = width < 700;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isNarrow ? _buildDrawer() : null,
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
              onDestinationSelected: (i) =>
                  setState(() => selectedIndex = i),
              destinations: _destinations,
            ),

          // Medium layout
          if (!isWide && isMedium)
            NavigationRail(
              selectedIndex: selectedIndex,
              labelType: NavigationRailLabelType.none,
              onDestinationSelected: (i) =>
                  setState(() => selectedIndex = i),
              minWidth: 60,
              groupAlignment: -1.0,
              destinations: _destinations,
            ),

          // Main content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade400, Colors.purple.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.currency_bitcoin,
                        size: 32,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Crypto Tracker",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "v1.0.0",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text("Home"),
              selected: selectedIndex == 0,
              onTap: () => _onSelectIndex(0),
            ),
            ListTile(
              title: const Text("Portfolio"),
              selected: selectedIndex == 1,
              onTap: () => _onSelectIndex(1),
            ),
            ListTile(
              title: const Text("Settings"),
              selected: selectedIndex == 2,
              onTap: () => _onSelectIndex(2),
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

  Widget _buildContent() {
    switch (selectedIndex) {
      case 1:
        return const Center(child: Text("Portfolio Page"));
      case 2:
        return SettingsView();
      default:
        return const ContentPage();
    }
  }
}



