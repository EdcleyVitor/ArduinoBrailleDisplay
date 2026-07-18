import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'connection_screen.dart';
import 'message_screen.dart';
import 'settings_screen.dart';
import 'personalization_screen.dart';

class MainScreen extends StatefulWidget {
  final void Function(ThemeMode) onThemeChanged;
  final void Function(Color) onColorChanged;
  final void Function(AppStyle) onStyleChanged;
  final ThemeMode currentThemeMode;
  final Color currentSeedColor;
  final AppStyle currentStyle;

  const MainScreen({
    super.key,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.onStyleChanged,
    required this.currentThemeMode,
    required this.currentSeedColor,
    required this.currentStyle,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> _buildScreens() {
    final isNeon = widget.currentStyle == AppStyle.neon;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgTop, bgMid, bgBot;
    if (isNeon) {
      bgTop = const Color(0xFF050510);
      bgMid = const Color(0xFF0A0A20);
      bgBot = const Color(0xFF030308);
    } else if (isDark) {
      bgTop = const Color(0xFF1A1A2E);
      bgMid = const Color(0xFF121225);
      bgBot = const Color(0xFF0A0A15);
    } else {
      bgTop = const Color(0xFF6C63FF);
      bgMid = const Color(0xFF4A45B5);
      bgBot = const Color(0xFF1A1A2E);
    }

    return [
      ConnectionScreen(bgTop: bgTop, bgMid: bgMid, bgBot: bgBot),
      MessageScreen(bgTop: bgTop, bgMid: bgMid, bgBot: bgBot),
      SettingsScreen(
        bgTop: bgTop,
        bgMid: bgMid,
        bgBot: bgBot,
        onThemeChanged: widget.onThemeChanged,
        onColorChanged: widget.onColorChanged,
        onStyleChanged: widget.onStyleChanged,
        currentThemeMode: widget.currentThemeMode,
        currentSeedColor: widget.currentSeedColor,
        currentStyle: widget.currentStyle,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isNeon = widget.currentStyle == AppStyle.neon;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _buildScreens(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isNeon ? const Color(0xFF00E5FF).withAlpha(15) : Colors.black.withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: isNeon ? const Color(0xFF0A0A20) : Theme.of(context).colorScheme.surface,
          indicatorColor: (isNeon ? const Color(0xFF00E5FF) : widget.currentSeedColor).withAlpha(25),
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.bluetooth_disabled_rounded, size: 26, color: isNeon ? Colors.white54 : null),
              selectedIcon: Icon(Icons.bluetooth_connected_rounded, size: 26, color: isNeon ? const Color(0xFF00E5FF) : null),
              label: 'Conectar',
            ),
            NavigationDestination(
              icon: Icon(Icons.send_rounded, size: 26, color: isNeon ? Colors.white54 : null),
              selectedIcon: Icon(Icons.send_rounded, size: 26, color: isNeon ? const Color(0xFF00E5FF) : null),
              label: 'Enviar',
            ),
            NavigationDestination(
              icon: Icon(Icons.tune_rounded, size: 26, color: isNeon ? Colors.white54 : null),
              selectedIcon: Icon(Icons.tune_rounded, size: 26, color: isNeon ? const Color(0xFF00E5FF) : null),
              label: 'Config',
            ),
          ],
        ),
      ),
    );
  }
}
