import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BrailleBrigdeApp());
}

class BrailleBrigdeApp extends StatefulWidget {
  const BrailleBrigdeApp({super.key});

  @override
  State<BrailleBrigdeApp> createState() => _BrailleBrigdeAppState();
}

class _BrailleBrigdeAppState extends State<BrailleBrigdeApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = const Color(0xFF1565C0);

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    final colorValue = prefs.getInt('seedColor') ?? 0xFF1565C0;

    setState(() {
      _themeMode = ThemeMode.values[themeIndex];
      _seedColor = Color(colorValue);
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    setState(() => _themeMode = mode);
  }

  Future<void> _setSeedColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seedColor', color.value);
    setState(() => _seedColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Braille Bridge',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        useMaterial3: true,
      ),
      home: MainScreen(
        onThemeChanged: _setThemeMode,
        onColorChanged: _setSeedColor,
        currentThemeMode: _themeMode,
        currentSeedColor: _seedColor,
      ),
    );
  }
}
