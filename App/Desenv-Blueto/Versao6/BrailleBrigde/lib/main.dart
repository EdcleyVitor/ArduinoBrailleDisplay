import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_screen.dart';
import 'screens/personalization_screen.dart';
import 'database/database_helper.dart';

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
  AppStyle _appStyle = AppStyle.padrao;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final db = DatabaseHelper.instance;
    final themeIndex = await db.getSettingInt('themeMode', defaultValue: 2);
    final colorValue = await db.getSettingInt('seedColor', defaultValue: 0xFF6C63FF);
    final styleIndex = await db.getSettingInt('appStyle', defaultValue: 0);
    setState(() {
      _themeMode = ThemeMode.values[themeIndex];
      _seedColor = Color(colorValue);
      _appStyle = AppStyle.values[styleIndex];
    });
  }

  void _onThemeChanged(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    await DatabaseHelper.instance.saveSettingInt('themeMode', mode.index);
  }

  void _onColorChanged(Color color) async {
    setState(() => _seedColor = color);
    await DatabaseHelper.instance.saveSettingInt('seedColor', color.value);
  }

  void _onStyleChanged(AppStyle style) async {
    setState(() => _appStyle = style);
    await DatabaseHelper.instance.saveSettingInt('appStyle', style.index);
  }

  ThemeData _buildLightTheme() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light),
      textTheme: GoogleFonts.poppinsTextTheme(),
      useMaterial3: true,
    );
    if (_appStyle == AppStyle.neon) {
      return ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFF0A0A15),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        useMaterial3: true,
      );
    }
    return base;
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
      useMaterial3: true,
    );
    if (_appStyle == AppStyle.neon) {
      return ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050510),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        useMaterial3: true,
      );
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrailleBridge',
      debugShowCheckedModeBanner: false,
      themeMode: _appStyle == AppStyle.neon ? ThemeMode.dark : _themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: MainScreen(
        onThemeChanged: _onThemeChanged,
        onColorChanged: _onColorChanged,
        onStyleChanged: _onStyleChanged,
        currentThemeMode: _themeMode,
        currentSeedColor: _seedColor,
        currentStyle: _appStyle,
      ),
    );
  }
}
