import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BrailleBluetoothService {
  static const String serviceUUID = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const String writeUUID = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';
  static const String notifyUUID = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';

  static final BrailleBluetoothService _instance = BrailleBluetoothService._internal();
  factory BrailleBluetoothService() => _instance;
  BrailleBluetoothService._internal();

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;

  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  final StreamController<List<ScanResult>> _scanController = StreamController<List<ScanResult>>.broadcast();
  final StreamController<String> _statusController = StreamController<String>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<List<ScanResult>> get scanStream => _scanController.stream;
  Stream<String> get statusStream => _statusController.stream;

  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _connectedDevice != null;

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
    await FlutterBluePlus.adapterState.first;
  }

  void startScan() async {
    _statusController.add('Escaneando...');

    FlutterBluePlus.scanResults.listen((results) {
      _scanController.add(results);
    });

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
      androidUsesFineLocation: true,
    );

    await Future.delayed(const Duration(seconds: 10));
    await FlutterBluePlus.stopScan();
    _statusController.add('Scan finalizado');
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _statusController.add('Scan parado');
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      _statusController.add('Conectando ao ${device.platformName}...');

      await device.connect(timeout: const Duration(seconds: 15));
      _connectedDevice = device;
      _connectionController.add(true);
      _statusController.add('Conectado. Descobrindo servicos...');

      await device.requestMtu(512);
      await Future.delayed(const Duration(milliseconds: 500));

      final services = await device.discoverServices();

      for (final service in services) {
        if (service.uuid.toString().toLowerCase() == serviceUUID.toLowerCase()) {
          for (final characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() == writeUUID.toLowerCase()) {
              _writeCharacteristic = characteristic;
              _statusController.add('Conectado a ${device.platformName}');
              return true;
            }
          }
        }
      }

      _statusController.add('Servico NUS nao encontrado. Tentando auto-detectar...');
      for (final service in services) {
        for (final characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            _writeCharacteristic = characteristic;
            _statusController.add('Conectado (auto-detectado)');
            return true;
          }
        }
      }

      _statusController.add('ERRO: nenhuma caracteristica de escrita encontrada');
      return false;
    } catch (e) {
      _statusController.add('Erro ao conectar: $e');
      _connectionController.add(false);
      _connectedDevice = null;
      _writeCharacteristic = null;
      return false;
    }
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _writeCharacteristic = null;
      _connectionController.add(false);
      _statusController.add('Desconectado');
    }
  }

  Future<bool> sendBraillePattern(String pattern) async {
    if (_writeCharacteristic == null) {
      _statusController.add('ERRO: nao conectado');
      return false;
    }

    try {
      final bytes = Uint8List.fromList(pattern.codeUnits);
      await _writeCharacteristic!.write(bytes, withoutResponse: true);
      _statusController.add('Enviado: $pattern');
      return true;
    } catch (e) {
      _statusController.add('ERRO ao enviar: $e');
      return false;
    }
  }

  Future<bool> sendText(String text) async {
    if (_writeCharacteristic == null) {
      _statusController.add('ERRO: nao conectado');
      return false;
    }

    try {
      final bytes = Uint8List.fromList(text.codeUnits);
      await _writeCharacteristic!.write(bytes, withoutResponse: false);
      _statusController.add('Texto enviado (${text.length} caracteres)');
      return true;
    } catch (e) {
      _statusController.add('ERRO ao enviar texto: $e');
      try {
        final bytes = Uint8List.fromList(text.codeUnits);
        await _writeCharacteristic!.write(bytes, withoutResponse: true);
        _statusController.add('Texto enviado sem resposta (${text.length} caracteres)');
        return true;
      } catch (e2) {
        _statusController.add('ERRO ao enviar (tentativa 2): $e2');
        return false;
      }
    }
  }

  void dispose() {
    _connectionController.close();
    _scanController.close();
    _statusController.close();
  }
}
