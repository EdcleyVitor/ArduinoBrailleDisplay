import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'connection_screen.dart';
import 'message_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ConnectionScreen(),
    const MessageScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
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
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF6C63FF).withAlpha(25),
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.bluetooth_disabled_rounded, size: 26),
              selectedIcon: Icon(Icons.bluetooth_connected_rounded, size: 26, color: Color(0xFF6C63FF)),
              label: 'Conectar',
            ),
            NavigationDestination(
              icon: Icon(Icons.send_rounded, size: 26),
              selectedIcon: Icon(Icons.send_rounded, size: 26, color: Color(0xFF6C63FF)),
              label: 'Enviar',
            ),
            NavigationDestination(
              icon: Icon(Icons.tune_rounded, size: 26),
              selectedIcon: Icon(Icons.tune_rounded, size: 26, color: Color(0xFF6C63FF)),
              label: 'Config',
            ),
          ],
        ),
      ),
    );
  }
}
