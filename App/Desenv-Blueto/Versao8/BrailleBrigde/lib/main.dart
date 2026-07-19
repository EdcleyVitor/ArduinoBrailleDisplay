import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/personalization_screen.dart';
import 'services/settings_manager.dart';

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
  final SettingsManager _settings = SettingsManager();

  @override
  void initState() {
    super.initState();
    _settings.loadAll();
    _settings.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  TextTheme _buildTextTheme() {
    return TextTheme(
      bodyLarge: GoogleFonts.getFont(_settings.fontName, fontSize: _settings.fontSize, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.getFont(_settings.fontName, fontSize: _settings.fontSize, fontWeight: FontWeight.w400),
      bodySmall: GoogleFonts.getFont(_settings.fontName, fontSize: _settings.fontSize - 2, fontWeight: FontWeight.w400),
      titleLarge: GoogleFonts.getFont(_settings.fontName, fontSize: _settings.fontSize + 6, fontWeight: FontWeight.bold),
      titleMedium: GoogleFonts.getFont(_settings.fontName, fontSize: _settings.fontSize + 2, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.getFont(_settings.fontName, fontSize: _settings.fontSize, fontWeight: FontWeight.w600),
      labelLarge: GoogleFonts.getFont(_settings.fontName, fontSize: _settings.fontSize, fontWeight: FontWeight.w600),
      labelMedium: GoogleFonts.getFont(_settings.fontName, fontSize: _settings.fontSize, fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.getFont(_settings.fontName, fontSize: _settings.fontSize - 3, fontWeight: FontWeight.w500),
      headlineLarge: GoogleFonts.getFont(_settings.fontName, fontSize: _settings.fontSize + 8, fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.getFont(_settings.fontName, fontSize: _settings.fontSize + 4, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.getFont(_settings.fontName, fontSize: _settings.fontSize + 2, fontWeight: FontWeight.w600),
      displayLarge: GoogleFonts.getFont(_settings.fontName, fontSize: _settings.fontSize + 10, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.getFont(_settings.fontName, fontSize: _settings.fontSize + 6, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.getFont(_settings.fontName, fontSize: _settings.fontSize + 4, fontWeight: FontWeight.w600),
    );
  }

  ThemeData _buildLightTheme() {
    if (_settings.isNeon) {
      return ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFF0A0A15),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _settings.primaryAppColor,
          brightness: Brightness.light,
        ),
        textTheme: _buildTextTheme(),
        useMaterial3: true,
      );
    }
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _settings.primaryAppColor, brightness: Brightness.light),
      textTheme: _buildTextTheme(),
      useMaterial3: true,
    );
  }

  ThemeData _buildDarkTheme() {
    if (_settings.isNeon) {
      return ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050510),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _settings.primaryAppColor,
          brightness: Brightness.dark,
        ),
        textTheme: _buildTextTheme(),
        useMaterial3: true,
      );
    }
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _settings.primaryAppColor, brightness: Brightness.dark),
      textTheme: _buildTextTheme(),
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_settings.loaded) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A0A2E), Color(0xFF6C63FF), Color(0xFF0A0A2E)],
              ),
            ),
            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _settings,
      builder: (context, child) {
        return MaterialApp(
          title: 'BrailleBridge',
          debugShowCheckedModeBanner: false,
          themeMode: _settings.isNeon ? ThemeMode.dark : _settings.themeMode,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          home: SplashScreen(settings: _settings),
        );
      },
    );
  }
}
