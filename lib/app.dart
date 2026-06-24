import 'package:flutter/material.dart';

import 'screens/export_screen.dart';
import 'screens/experience_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/project_screen.dart';
import 'screens/skill_screen.dart';

class CareerPortfolioApp extends StatefulWidget {
  const CareerPortfolioApp({super.key});

  @override
  State<CareerPortfolioApp> createState() => _CareerPortfolioAppState();
}

class _CareerPortfolioAppState extends State<CareerPortfolioApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF071B33);
    const cyan = Color(0xFF00B8D9);
    final lightScheme = ColorScheme.fromSeed(
      seedColor: cyan,
      brightness: Brightness.light,
      surface: const Color(0xFFFFFBF5),
      primary: navy,
      secondary: cyan,
      tertiary: const Color(0xFF7857D9),
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: cyan,
      brightness: Brightness.dark,
      surface: const Color(0xFF0B1726),
      primary: const Color(0xFF8DD8F7),
      secondary: const Color(0xFF54D6EC),
      tertiary: const Color(0xFFB9A5FF),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CareerPortfolio',
      themeMode: _themeMode,
      theme: _theme(lightScheme),
      darkTheme: _theme(darkScheme),
      home: HomeShell(
        themeMode: _themeMode,
        onThemeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }

  ThemeData _theme(ColorScheme scheme) => ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: .45),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

class HomeShell extends StatefulWidget {
  const HomeShell({
    required this.themeMode,
    required this.onThemeChanged,
    super.key,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  static const _titles = [
    'Profil',
    'Compétences',
    'Projets',
    'Parcours',
    'Exporter',
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      const ProfileScreen(),
      const SkillScreen(),
      const ProjectScreen(),
      const ExperienceScreen(),
      const ExportScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Changer de thème',
            onPressed: () {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              widget.onThemeChanged(isDark ? ThemeMode.light : ThemeMode.dark);
            },
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Compétences',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Projets',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Expériences',
          ),
          NavigationDestination(
            icon: Icon(Icons.ios_share_outlined),
            selectedIcon: Icon(Icons.ios_share),
            label: 'Export',
          ),
        ],
      ),
    );
  }
}
