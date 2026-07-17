import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'connection_screen.dart';
import 'message_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  final void Function(ThemeMode) onThemeChanged;
  final void Function(Color) onColorChanged;
  final ThemeMode currentThemeMode;
  final Color currentSeedColor;

  const MainScreen({
    super.key,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.currentThemeMode,
    required this.currentSeedColor,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [];
  }

  List<Widget> _buildScreens() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgTop = isDark ? const Color(0xFF1A1A2E) : const Color(0xFF6C63FF);
    final bgMid = isDark ? const Color(0xFF121225) : const Color(0xFF4A45B5);
    final bgBot = isDark ? const Color(0xFF0A0A15) : const Color(0xFF1A1A2E);

    return [
      ConnectionScreen(bgTop: bgTop, bgMid: bgMid, bgBot: bgBot),
      MessageScreen(bgTop: bgTop, bgMid: bgMid, bgBot: bgBot),
      SettingsScreen(
        bgTop: bgTop,
        bgMid: bgMid,
        bgBot: bgBot,
        onThemeChanged: widget.onThemeChanged,
        onColorChanged: widget.onColorChanged,
        currentThemeMode: widget.currentThemeMode,
        currentSeedColor: widget.currentSeedColor,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _buildScreens(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: Theme.of(context).colorScheme.surface,
          indicatorColor: widget.currentSeedColor.withAlpha(25),
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.bluetooth_disabled_rounded, size: 26),
              selectedIcon: Icon(Icons.bluetooth_connected_rounded, size: 26),
              label: 'Conectar',
            ),
            const NavigationDestination(
              icon: Icon(Icons.send_rounded, size: 26),
              selectedIcon: Icon(Icons.send_rounded, size: 26),
              label: 'Enviar',
            ),
            const NavigationDestination(
              icon: Icon(Icons.tune_rounded, size: 26),
              selectedIcon: Icon(Icons.tune_rounded, size: 26),
              label: 'Config',
            ),
          ],
        ),
      ),
    );
  }
}
