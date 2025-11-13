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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey.shade600),
      ),
      home: const HomePage(),
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

    final bool isWide = width >= 1000;     // full NavigationRail
    final bool isMedium = width >= 700;    // compact NavigationRail
    final bool isNarrow = width < 700;     // burger btn + Drawer

    return Scaffold(
      key: _scaffoldKey,
      drawer: isNarrow
      ? Drawer(
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
      )
      : null,

      body: Row(
        children: [
          //  Wide
          if (isWide)
            NavigationRail(
              selectedIndex: selectedIndex,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (i) =>
                  setState(() => selectedIndex = i),
              destinations: _destinations,
            ),

          // Medium
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
          if (isNarrow)
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ),
            ),
          // ✅ MAIN CONTENT
          Expanded(child: _buildContent()),
        ],
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



