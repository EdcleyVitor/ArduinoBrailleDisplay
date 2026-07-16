import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BrailleBluetoothService {
  final FlutterBluePlus _ble = FlutterBluePlus();

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;

  static const String serviceUUID = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const String writeUUID = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';
  static const String notifyUUID = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';

  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  final StreamController<List<ScanResult>> _scanController = StreamController<List<ScanResult>>.broadcast();
  final StreamController<String> _statusController = StreamController<String>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<List<ScanResult>> get scanStream => _scanController.stream;
  Stream<String> get statusStream => _statusController.stream;

  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _connectedDevice != null;

  Future<void> startScan() async {
    _statusController.add('Escaneando...');

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
      androidUsesFineLocation: true,
    );

    FlutterBluePlus.scanResults.listen((results) {
      _scanController.add(results);
    });

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

      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevice = device;
      _connectionController.add(true);

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

      if (_writeCharacteristic == null && services.isNotEmpty) {
        for (final service in services) {
          for (final characteristic in service.characteristics) {
            if (characteristic.properties.write) {
              _writeCharacteristic = characteristic;
              _statusController.add('Conectado (auto-detectado)');
              return true;
            }
          }
        }
      }

      _statusController.add('Erro: characteristic não encontrada');
      return false;
    } catch (e) {
      _statusController.add('Erro ao conectar: $e');
      _connectionController.add(false);
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
      _statusController.add('Erro: não conectado');
      return false;
    }

    try {
      final bytes = Uint8List.fromList(pattern.codeUnits);
      await _writeCharacteristic!.write(bytes, withoutResponse: true);
      _statusController.add('Enviado: $pattern');
      return true;
    } catch (e) {
      _statusController.add('Erro ao enviar: $e');
      return false;
    }
  }

  Future<bool> sendText(String text) async {
    if (_writeCharacteristic == null) {
      _statusController.add('Erro: não conectado');
      return false;
    }

    try {
      final bytes = Uint8List.fromList(text.codeUnits);
      await _writeCharacteristic!.write(bytes, withoutResponse: false);
      _statusController.add('Texto enviado (${text.length} caracteres)');
      return true;
    } catch (e) {
      _statusController.add('Erro ao enviar texto: $e');
      return false;
    }
  }

  void dispose() {
    _connectionController.close();
    _scanController.close();
    _statusController.close();
  }
}
