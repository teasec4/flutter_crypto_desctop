import 'package:crypto_desctop/presentation/pages/content_page.dart';
import 'package:crypto_desctop/presentation/pages/settings_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypto Desctop App',
      theme: _buildTheme(),
      home: const HomePage(),
    );
  }

  ThemeData _buildTheme() {
    const primaryColor = Color(0xFF6366F1); // Индиго
    const secondaryColor = Color(0xFF8B5CF6); // Фиолетовый
    const surfaceColor = Color(0xFFF8FAFC); // Светлый

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        outline: Colors.grey.shade300,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.white,
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 28,
        ),
        unselectedIconTheme: IconThemeData(
          color: Colors.grey.shade500,
          size: 24,
        ),
        selectedLabelTextStyle: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: primaryColor,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey.shade400;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.3);
          }
          return Colors.grey.shade300;
        }),
      ),
      listTileTheme: const ListTileThemeData(
        selectedColor: primaryColor,
        selectedTileColor: Color(0xFFE0E7FF),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade800,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
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
            const DrawerHeader(child: Text("Menu")),
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



