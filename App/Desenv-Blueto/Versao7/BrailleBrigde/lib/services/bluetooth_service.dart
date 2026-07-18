import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../database/database_helper.dart';

class BrailleBluetoothService {
  static final BrailleBluetoothService _instance = BrailleBluetoothService._internal();
  factory BrailleBluetoothService() => _instance;
  BrailleBluetoothService._internal();

  static const String serviceUUID = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const String writeUUID = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';
  static const String notifyUUID = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';

  BluetoothDevice? _device;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _notifyCharacteristic;
  bool _isConnected = false;
  StreamSubscription? _connectionStateSub;
  StreamSubscription? _notifySub;
  int _espSpeed = 1500;
  int _espPause = 500;

  final _connectionController = StreamController<bool>.broadcast();
  final _scanController = StreamController<List<ScanResult>>.broadcast();
  final _statusController = StreamController<String>.broadcast();
  final _notifyController = StreamController<String>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<List<ScanResult>> get scanStream => _scanController.stream;
  Stream<String> get statusStream => _statusController.stream;
  Stream<String> get notifyStream => _notifyController.stream;

  bool get isConnected => _isConnected;
  BluetoothDevice? get device => _device;
  int get espSpeed => _espSpeed;
  int get espPause => _espPause;
  BluetoothCharacteristic? get notifyCharacteristic => _notifyCharacteristic;

  BluetoothAdapterState get adapterState => FlutterBluePlus.adapterStateNow;

  Future<bool> isBluetoothOn() async {
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  Future<bool> ensureBluetoothOn() async {
    final state = await FlutterBluePlus.adapterState.first;
    if (state == BluetoothAdapterState.on) return true;
    try {
      await FlutterBluePlus.turnOn(timeout: 10);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await FlutterBluePlus.adapterState.first;
    }
  }

  void _onDeviceDisconnected() {
    _isConnected = false;
    _writeCharacteristic = null;
    _notifyCharacteristic = null;
    _notifySub?.cancel();
    _connectionController.add(false);
    _statusController.add('Dispositivo desconectado');
  }

  void startScan() async {
    _statusController.add('Procurando dispositivos...');
    _scanController.add([]);

    FlutterBluePlus.scanResults.listen((results) {
      _scanController.add(results);
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    Future.delayed(const Duration(seconds: 10), () {
      FlutterBluePlus.stopScan();
    });
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      _device = device;
      _statusController.add('Conectando a ${device.platformName}...');

      await device.connect(timeout: const Duration(seconds: 15));
      _isConnected = true;
      _connectionController.add(true);
      _statusController.add('Conectado. Descobrindo servicos...');

      _connectionStateSub?.cancel();
      _connectionStateSub = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _onDeviceDisconnected();
        }
      });

      await device.requestMtu(512);
      await Future.delayed(const Duration(milliseconds: 500));

      List<BluetoothService> services = await device.discoverServices();

      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == serviceUUID.toLowerCase()) {
          for (var char in service.characteristics) {
            final uuid = char.uuid.toString().toLowerCase();
            if (uuid == writeUUID.toLowerCase()) {
              _writeCharacteristic = char;
            }
            if (uuid == notifyUUID.toLowerCase()) {
              _notifyCharacteristic = char;
              await char.setNotifyValue(true);
              _notifySub?.cancel();
              _notifySub = char.onValueReceived.listen((value) {
                final msg = String.fromCharCodes(value);
                _notifyController.add(msg);
              });
            }
          }
          if (_writeCharacteristic != null && _notifyCharacteristic != null) {
            _statusController.add('Pronto para enviar!');
            return true;
          }
        }
      }

      for (var service in services) {
        for (var char in service.characteristics) {
          if (char.properties.write && _writeCharacteristic == null) {
            _writeCharacteristic = char;
          }
          if (char.properties.notify && _notifyCharacteristic == null) {
            _notifyCharacteristic = char;
            await char.setNotifyValue(true);
            _notifySub?.cancel();
            _notifySub = char.onValueReceived.listen((value) {
              final msg = String.fromCharCodes(value);
              _notifyController.add(msg);
            });
          }
        }
        if (_writeCharacteristic != null && _notifyCharacteristic != null) {
          _statusController.add('Caracteristic detectada (auto)');
          return true;
        }
      }

      if (_writeCharacteristic != null) {
        _statusController.add('Sem notify, modo basico');
        return true;
      }

      _statusController.add('ERRO: nenhuma caracteristica de escrita encontrada');
      return false;
    } catch (e) {
      _isConnected = false;
      _device = null;
      _writeCharacteristic = null;
      _notifyCharacteristic = null;
      _notifySub?.cancel();
      _connectionController.add(false);
      _statusController.add('Erro ao conectar: $e');
      DatabaseHelper.instance.logError('BLE', 'Falha ao conectar', details: e.toString());
      return false;
    }
  }

  void disconnect() async {
    _notifySub?.cancel();
    try {
      await _notifyCharacteristic?.setNotifyValue(false);
    } catch (_) {}
    try {
      await _device?.disconnect();
    } catch (_) {}
    _device = null;
    _writeCharacteristic = null;
    _notifyCharacteristic = null;
    _isConnected = false;
    _connectionController.add(false);
    _statusController.add('Desconectado');
  }

  Future<void> sendConfig(String key, String value) async {
    final cmd = '@$key:$value';
    await _sendRaw(cmd);
  }

  Future<void> sendText(String text) async {
    await _sendRaw(text);
  }

  Future<void> sendChar(String char) async {
    await _sendRaw(char);
  }

  Future<void> _sendRaw(String data) async {
    if (_writeCharacteristic == null || !_isConnected) {
      _statusController.add('ERRO: nao conectado!');
      return;
    }

    try {
      await _writeCharacteristic!.write(data.codeUnits, withoutResponse: false);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('6') || msg.contains('not connected')) {
        _onDeviceDisconnected();
        _statusController.add('ERRO: dispositivo desconectado');
        DatabaseHelper.instance.logError('BLE', 'Dispositivo desconectado durante envio', details: 'Dado: $data | Erro: $e');
      } else {
        _statusController.add('ERRO ao enviar: $e');
        DatabaseHelper.instance.logError('BLE', 'Erro ao enviar dados', details: 'Dado: $data | Erro: $e');
      }
    }
  }

  void setEspSpeed(int ms) {
    _espSpeed = ms;
  }

  void setEspPause(int ms) {
    _espPause = ms;
  }

  void dispose() {
    _connectionStateSub?.cancel();
    _notifySub?.cancel();
    _connectionController.close();
    _scanController.close();
    _statusController.close();
    _notifyController.close();
  }
}
