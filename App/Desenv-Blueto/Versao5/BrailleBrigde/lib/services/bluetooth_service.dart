import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BrailleBluetoothService {
  static final BrailleBluetoothService _instance = BrailleBluetoothService._internal();
  factory BrailleBluetoothService() => _instance;
  BrailleBluetoothService._internal();

  static const String serviceUUID = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const String writeUUID = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';
  static const String notifyUUID = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';

  BluetoothDevice? _device;
  BluetoothCharacteristic? _writeCharacteristic;
  bool _isConnected = false;
  StreamSubscription? _connectionStateSub;

  final _connectionController = StreamController<bool>.broadcast();
  final _scanController = StreamController<List<ScanResult>>.broadcast();
  final _statusController = StreamController<String>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<List<ScanResult>> get scanStream => _scanController.stream;
  Stream<String> get statusStream => _statusController.stream;

  bool get isConnected => _isConnected;
  BluetoothDevice? get device => _device;

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
            if (char.uuid.toString().toLowerCase() == writeUUID.toLowerCase()) {
              _writeCharacteristic = char;
              _statusController.add('Pronto para enviar!');
              return true;
            }
          }
        }
      }

      _statusController.add('Servico NUS nao encontrado. Tentando auto-detectar...');
      for (var service in services) {
        for (var char in service.characteristics) {
          if (char.properties.write) {
            _writeCharacteristic = char;
            _statusController.add('Caracteristic detectada (auto)');
            return true;
          }
        }
      }

      _statusController.add('ERRO: nenhuma caracteristica de escrita encontrada');
      return false;
    } catch (e) {
      _isConnected = false;
      _device = null;
      _writeCharacteristic = null;
      _connectionStateSub?.cancel();
      _connectionController.add(false);
      _statusController.add('Erro ao conectar: $e');
      return false;
    }
  }

  void disconnect() async {
    _connectionStateSub?.cancel();
    try {
      await _device?.disconnect();
    } catch (_) {}
    _device = null;
    _writeCharacteristic = null;
    _isConnected = false;
    _connectionController.add(false);
    _statusController.add('Desconectado');
  }

  Future<void> sendText(String text) async {
    if (_writeCharacteristic == null || !_isConnected) {
      _statusController.add('ERRO: nao conectado!');
      return;
    }

    try {
      _statusController.add('Enviando...');
      await _writeCharacteristic!.write(text.codeUnits, withoutResponse: false);
      _statusController.add('Enviado: "$text"');
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('6') || msg.contains('not connected') || msg.contains('device is not connected')) {
        _onDeviceDisconnected();
        _statusController.add('ERRO: dispositivo desconectado');
      } else if (msg.contains('not supported') || msg.contains('null')) {
        _statusController.add('ERRO: caracteristica BLE incompativel');
      } else {
        _statusController.add('ERRO ao enviar: $e');
      }
    }
  }

  void dispose() {
    _connectionStateSub?.cancel();
    _connectionController.close();
    _scanController.close();
    _statusController.close();
  }
}
