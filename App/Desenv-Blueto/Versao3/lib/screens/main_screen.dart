import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'connection_screen.dart';
import 'message_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final Function(Color) onColorChanged;
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
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            indicatorColor: primaryColor.withOpacity(0.1),
            height: 80,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.bluetooth_outlined,
                  color: _currentIndex == 0 ? primaryColor : Colors.grey,
                  size: 28,
                ),
                selectedIcon: Icon(
                  Icons.bluetooth_connected,
                  color: primaryColor,
                  size: 28,
                ),
                label: 'Conectar',
              ),
              NavigationDestination(
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                selectedIcon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                label: 'Enviar',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.settings_outlined,
                  color: _currentIndex == 2 ? primaryColor : Colors.grey,
                  size: 28,
                ),
                selectedIcon: Icon(
                  Icons.settings,
                  color: primaryColor,
                  size: 28,
                ),
                label: 'Config',
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> get _screens => [
    const ConnectionScreen(),
    const MessageScreen(),
    SettingsScreen(
      onThemeChanged: widget.onThemeChanged,
      onColorChanged: widget.onColorChanged,
      currentThemeMode: widget.currentThemeMode,
      currentSeedColor: widget.currentSeedColor,
    ),
  ];
}
