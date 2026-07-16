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
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF2563EB).withAlpha(30),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.bluetooth_disabled),
              selectedIcon: Icon(Icons.bluetooth, color: Color(0xFF2563EB)),
              label: 'Conectar',
            ),
            NavigationDestination(
              icon: Icon(Icons.send_outlined),
              selectedIcon: Icon(Icons.send, color: Color(0xFF2563EB)),
              label: 'Enviar',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings, color: Color(0xFF2563EB)),
              label: 'Config',
            ),
          ],
        ),
      ),
    );
  }
}
