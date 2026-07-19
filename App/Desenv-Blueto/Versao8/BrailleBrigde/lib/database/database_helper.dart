import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('braille_bridge.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 5, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE texts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE errors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp INTEGER NOT NULL,
        screen TEXT NOT NULL,
        message TEXT NOT NULL,
        details TEXT
      )
    ''');

    await db.insert('settings', {'key': 'themeMode', 'value': '2'});
    await db.insert('settings', {'key': 'seedColor', 'value': '0xFF6C63FF'});
    await db.insert('settings', {'key': 'appStyle', 'value': 'padrao'});
    await db.insert('settings', {'key': 'espSpeed', 'value': '1500'});
    await db.insert('settings', {'key': 'espPause', 'value': '500'});
    await db.insert('settings', {'key': 'fontName', 'value': 'Poppins'});
    await db.insert('settings', {'key': 'fontSize', 'value': '14.0'});
    await db.insert('settings', {'key': 'primaryTextColor', 'value': '0xFFFFFFFF'});
    await db.insert('settings', {'key': 'secondaryTextColor', 'value': '0xFFB0B0B0'});
    await db.insert('settings', {'key': 'primaryAppColor', 'value': '0xFF6C63FF'});
    await db.insert('settings', {'key': 'secondaryAppColor', 'value': '0xFF00E5FF'});
    await db.insert('settings', {'key': 'separadorAlfabetoNumero', 'value': '1'});
    await db.insert('settings', {'key': 'ignorarAcentos', 'value': '0'});
    await db.insert('settings', {'key': 'caracteresEspeciais', 'value': '0'});
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.insert('settings', {'key': 'espPause', 'value': '500'});
    }
    if (oldVersion < 3) {
      await db.insert('settings', {'key': 'fontName', 'value': 'Poppins'});
      await db.insert('settings', {'key': 'fontSize', 'value': '14.0'});
      await db.insert('settings', {'key': 'primaryTextColor', 'value': '0xFFFFFFFF'});
      await db.insert('settings', {'key': 'secondaryTextColor', 'value': '0xFFB0B0B0'});
      await db.insert('settings', {'key': 'primaryAppColor', 'value': '0xFF6C63FF'});
      await db.insert('settings', {'key': 'secondaryAppColor', 'value': '0xFF00E5FF'});
    }
    if (oldVersion < 5) {
      await db.insert('settings', {'key': 'separadorAlfabetoNumero', 'value': '1'});
      await db.insert('settings', {'key': 'ignorarAcentos', 'value': '0'});
      await db.insert('settings', {'key': 'caracteresEspeciais', 'value': '0'});
    }
  }

  Future<void> insertText(String text) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert('texts', {'content': text, 'timestamp': now});
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM texts'),
    );
    if (count != null && count > 5) {
      await db.rawDelete('''
        DELETE FROM texts WHERE id NOT IN (
          SELECT id FROM texts ORDER BY timestamp DESC LIMIT 5
        )
      ''');
    }
  }

  Future<List<String>> getLastTexts(int limit) async {
    final db = await database;
    final result = await db.query(
      'texts',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((row) => row['content'] as String).toList();
  }

  Future<void> logError(String screen, String message, {String? details}) async {
    final db = await database;
    await db.insert('errors', {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'screen': screen,
      'message': message,
      'details': details,
    });
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM errors'),
    );
    if (count != null && count > 100) {
      await db.rawDelete('''
        DELETE FROM errors WHERE id NOT IN (
          SELECT id FROM errors ORDER BY timestamp DESC LIMIT 100
        )
      ''');
    }
  }

  Future<List<Map<String, dynamic>>> getErrors() async {
    final db = await database;
    return await db.query('errors', orderBy: 'timestamp DESC');
  }

  Future<String> exportErrorsTxt() async {
    final errors = await getErrors();
    final buffer = StringBuffer();
    buffer.writeln('=== BrailleBridge - Log de Erros ===');
    buffer.writeln('Exportado em: ${DateTime.now().toString()}');
    buffer.writeln('Total de erros: ${errors.length}');
    buffer.writeln('');

    for (final error in errors) {
      final ts = DateTime.fromMillisecondsSinceEpoch(error['timestamp'] as int);
      buffer.writeln('---');
      buffer.writeln('Data: ${ts.toString()}');
      buffer.writeln('Tela: ${error['screen']}');
      buffer.writeln('Erro: ${error['message']}');
      if (error['details'] != null) {
        buffer.writeln('Detalhes: ${error['details']}');
      }
      buffer.writeln('');
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/braillebridge_erros.txt');
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String;
    }
    return null;
  }

  Future<int> getSettingInt(String key, {int defaultValue = 0}) async {
    final val = await getSetting(key);
    if (val != null) return int.tryParse(val) ?? defaultValue;
    return defaultValue;
  }

  Future<double> getSettingDouble(String key, {double defaultValue = 0.0}) async {
    final val = await getSetting(key);
    if (val != null) return double.tryParse(val) ?? defaultValue;
    return defaultValue;
  }

  Future<bool> getSettingBool(String key, {bool defaultValue = false}) async {
    final val = await getSetting(key);
    if (val != null) return val == '1';
    return defaultValue;
  }

  Future<void> saveSettingInt(String key, int value) async {
    await saveSetting(key, value.toString());
  }

  Future<void> saveSettingDouble(String key, double value) async {
    await saveSetting(key, value.toString());
  }

  Future<void> saveSettingBool(String key, bool value) async {
    await saveSetting(key, value ? '1' : '0');
  }

  Future<void> clearTexts() async {
    final db = await database;
    await db.delete('texts');
  }

  Future<void> clearErrors() async {
    final db = await database;
    await db.delete('errors');
  }
}
