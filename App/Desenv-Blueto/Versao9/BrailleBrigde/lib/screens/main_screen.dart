import 'package:flutter/material.dart';
import '../services/settings_manager.dart';
import 'connection_screen.dart';
import 'message_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  final SettingsManager settings;
  const MainScreen({super.key, required this.settings});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.settings.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  List<Widget> _buildScreens() {
    final s = widget.settings;
    final isNeon = s.isNeon;
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
      bgTop = s.primaryAppColor;
      bgMid = HSLColor.fromColor(s.primaryAppColor).withLightness(HSLColor.fromColor(s.primaryAppColor).lightness - 0.15).toColor();
      bgBot = const Color(0xFF1A1A2E);
    }

    return [
      ConnectionScreen(bgTop: bgTop, bgMid: bgMid, bgBot: bgBot),
      MessageScreen(bgTop: bgTop, bgMid: bgMid, bgBot: bgBot, settings: s),
      SettingsScreen(settings: s, bgTop: bgTop, bgMid: bgMid, bgBot: bgBot),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.settings;
    final isNeon = s.isNeon;
    final primary = s.primaryAppColor;
    final secondary = s.secondaryAppColor;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _buildScreens(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isNeon ? secondary.withAlpha(15) : Colors.black.withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: isNeon ? const Color(0xFF0A0A20) : Theme.of(context).colorScheme.surface,
          indicatorColor: primary.withAlpha(25),
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.bluetooth_disabled_rounded, size: 26, color: isNeon ? Colors.white54 : null),
              selectedIcon: Icon(Icons.bluetooth_connected_rounded, size: 26, color: isNeon ? secondary : primary),
              label: 'Conectar',
            ),
            NavigationDestination(
              icon: Icon(Icons.send_rounded, size: 26, color: isNeon ? Colors.white54 : null),
              selectedIcon: Icon(Icons.send_rounded, size: 26, color: isNeon ? secondary : primary),
              label: 'Enviar',
            ),
            NavigationDestination(
              icon: Icon(Icons.tune_rounded, size: 26, color: isNeon ? Colors.white54 : null),
              selectedIcon: Icon(Icons.tune_rounded, size: 26, color: isNeon ? secondary : primary),
              label: 'Config',
            ),
          ],
        ),
      ),
    );
  }
}
