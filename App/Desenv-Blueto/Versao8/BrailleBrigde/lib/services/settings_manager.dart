import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class SettingsManager extends ChangeNotifier {
  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = const Color(0xFF6C63FF);
  String _appStyle = 'padrao';
  String _fontName = 'Poppins';
  double _fontSize = 14.0;
  Color _primaryTextColor = const Color(0xFFFFFFFF);
  Color _secondaryTextColor = const Color(0xFFB0B0B0);
  Color _primaryAppColor = const Color(0xFF6C63FF);
  Color _secondaryAppColor = const Color(0xFF00E5FF);
  int _espSpeed = 1500;
  int _espPause = 500;
  bool _separadorAlfabetoNumero = true;
  bool _ignorarAcentos = false;
  bool _caracteresEspeciais = false;
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  bool get isNeon => _appStyle == 'neon';
  AppStyle get appStyle => _appStyle == 'neon' ? AppStyle.neon : AppStyle.padrao;
  String get fontName => _fontName;
  double get fontSize => _fontSize;
  Color get primaryTextColor => _primaryTextColor;
  Color get secondaryTextColor => _secondaryTextColor;
  Color get primaryAppColor => _primaryAppColor;
  Color get secondaryAppColor => _secondaryAppColor;
  int get espSpeed => _espSpeed;
  int get espPause => _espPause;
  bool get separadorAlfabetoNumero => _separadorAlfabetoNumero;
  bool get ignorarAcentos => _ignorarAcentos;
  bool get caracteresEspeciais => _caracteresEspeciais;
  bool get loaded => _loaded;

  Future<void> loadAll() async {
    final db = DatabaseHelper.instance;
    final themeIndex = await db.getSettingInt('themeMode', defaultValue: 2);
    final colorValue = await db.getSettingInt('seedColor', defaultValue: 0xFF6C63FF);
    final style = await db.getSetting('appStyle') ?? 'padrao';
    final font = await db.getSetting('fontName') ?? 'Poppins';
    final size = await db.getSettingDouble('fontSize', defaultValue: 14.0);
    final priText = await db.getSettingInt('primaryTextColor', defaultValue: 0xFFFFFFFF);
    final secText = await db.getSettingInt('secondaryTextColor', defaultValue: 0xFFB0B0B0);
    final priApp = await db.getSettingInt('primaryAppColor', defaultValue: 0xFF6C63FF);
    final secApp = await db.getSettingInt('secondaryAppColor', defaultValue: 0xFF00E5FF);
    final speed = await db.getSettingInt('espSpeed', defaultValue: 1500);
    final pause = await db.getSettingInt('espPause', defaultValue: 500);
    final sep = await db.getSettingBool('separadorAlfabetoNumero', defaultValue: true);
    final acentos = await db.getSettingBool('ignorarAcentos', defaultValue: false);
    final especiais = await db.getSettingBool('caracteresEspeciais', defaultValue: false);

    _themeMode = themeIndex < ThemeMode.values.length ? ThemeMode.values[themeIndex] : ThemeMode.system;
    _seedColor = Color(colorValue);
    _appStyle = style;
    _fontName = font;
    _fontSize = size;
    _primaryTextColor = Color(priText);
    _secondaryTextColor = Color(secText);
    _primaryAppColor = Color(priApp);
    _secondaryAppColor = Color(secApp);
    _espSpeed = speed;
    _espPause = pause;
    _separadorAlfabetoNumero = sep;
    _ignorarAcentos = acentos;
    _caracteresEspeciais = especiais;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await DatabaseHelper.instance.saveSettingInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    await DatabaseHelper.instance.saveSettingInt('seedColor', color.value);
    notifyListeners();
  }

  Future<void> setAppStyle(String style) async {
    _appStyle = style;
    await DatabaseHelper.instance.saveSetting('appStyle', style);
    notifyListeners();
  }

  Future<void> setFontName(String font) async {
    _fontName = font;
    await DatabaseHelper.instance.saveSetting('fontName', font);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    await DatabaseHelper.instance.saveSettingDouble('fontSize', size);
    notifyListeners();
  }

  Future<void> setPrimaryTextColor(Color color) async {
    _primaryTextColor = color;
    await DatabaseHelper.instance.saveSettingInt('primaryTextColor', color.value);
    notifyListeners();
  }

  Future<void> setSecondaryTextColor(Color color) async {
    _secondaryTextColor = color;
    await DatabaseHelper.instance.saveSettingInt('secondaryTextColor', color.value);
    notifyListeners();
  }

  Future<void> setPrimaryAppColor(Color color) async {
    _primaryAppColor = color;
    await DatabaseHelper.instance.saveSettingInt('primaryAppColor', color.value);
    notifyListeners();
  }

  Future<void> setSecondaryAppColor(Color color) async {
    _secondaryAppColor = color;
    await DatabaseHelper.instance.saveSettingInt('secondaryAppColor', color.value);
    notifyListeners();
  }

  Future<void> setEspSpeed(int ms) async {
    _espSpeed = ms;
    await DatabaseHelper.instance.saveSettingInt('espSpeed', ms);
    notifyListeners();
  }

  Future<void> setEspPause(int ms) async {
    _espPause = ms;
    await DatabaseHelper.instance.saveSettingInt('espPause', ms);
    notifyListeners();
  }

  Future<void> setSeparadorAlfabetoNumero(bool value) async {
    _separadorAlfabetoNumero = value;
    await DatabaseHelper.instance.saveSettingBool('separadorAlfabetoNumero', value);
    notifyListeners();
  }

  Future<void> setIgnorarAcentos(bool value) async {
    _ignorarAcentos = value;
    await DatabaseHelper.instance.saveSettingBool('ignorarAcentos', value);
    notifyListeners();
  }

  Future<void> setCaracteresEspeciais(bool value) async {
    _caracteresEspeciais = value;
    await DatabaseHelper.instance.saveSettingBool('caracteresEspeciais', value);
    notifyListeners();
  }
}

enum AppStyle { padrao, neon }
