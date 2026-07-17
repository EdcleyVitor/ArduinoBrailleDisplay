import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const BrailleBridgeApp());
}

class BrailleBridgeApp extends StatefulWidget {
  const BrailleBridgeApp({super.key});

  @override
  State<BrailleBridgeApp> createState() => _BrailleBridgeAppState();
}

class _BrailleBridgeAppState extends State<BrailleBridgeApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = const Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 2;
    final colorValue = prefs.getInt('seedColor') ?? 0xFF6C63FF;
    setState(() {
      _themeMode = ThemeMode.values[themeIndex];
      _seedColor = Color(colorValue);
    });
  }

  Future<bool> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final launched = prefs.getBool('hasLaunched') ?? false;
    if (!launched) {
      await prefs.setBool('hasLaunched', true);
    }
    return !launched;
  }

  void _onThemeChanged(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  void _onColorChanged(Color color) async {
    setState(() => _seedColor = color);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seedColor', color.value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrailleBridge',
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
      home: FutureBuilder<bool>(
        future: _checkFirstLaunch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.data == true) {
            return const SplashScreen();
          }
          return MainScreen(
            onThemeChanged: _onThemeChanged,
            onColorChanged: _onColorChanged,
            currentThemeMode: _themeMode,
            currentSeedColor: _seedColor,
          );
        },
      ),
    );
  }
}
