import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../database/database_helper.dart';

class ConnectedDevice {
  final BluetoothDevice device;
  BluetoothCharacteristic? writeCharacteristic;
  BluetoothCharacteristic? notifyCharacteristic;
  StreamSubscription? connectionStateSub;
  StreamSubscription? notifySub;
  bool isReady;

  ConnectedDevice({
    required this.device,
    this.writeCharacteristic,
    this.notifyCharacteristic,
    this.isReady = false,
  });

  String get name => device.platformName.isNotEmpty ? device.platformName : 'Desconhecido';
  String get id => device.remoteId.toString();
}

class BrailleBluetoothService {
  static final BrailleBluetoothService _instance = BrailleBluetoothService._internal();
  factory BrailleBluetoothService() => _instance;
  BrailleBluetoothService._internal();

  static const String serviceUUID = '6e400001-b5a3-f393-e0a9-e50e24dcca9e';
  static const String writeUUID = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';
  static const String notifyUUID = '6e400003-b5a3-f393-e0a9-e50e24dcca9e';
  static const String signUUID = '6e400004-b5a3-f393-e0a9-e50e24dcca9e';
  static const String bridgeSignature = 'WhatGodWrought1844';

  final List<ConnectedDevice> _connectedDevices = [];
  int _espSpeed = 1500;
  int _espPause = 500;

  final _connectionController = StreamController<bool>.broadcast();
  final _devicesController = StreamController<List<ConnectedDevice>>.broadcast();
  final _scanController = StreamController<List<ScanResult>>.broadcast();
  final _statusController = StreamController<String>.broadcast();
  final _notifyController = StreamController<String>.broadcast();
  final _deviceNotifyController = StreamController<DeviceNotify>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<List<ConnectedDevice>> get devicesStream => _devicesController.stream;
  Stream<List<ScanResult>> get scanStream => _scanController.stream;
  Stream<String> get statusStream => _statusController.stream;
  Stream<String> get notifyStream => _notifyController.stream;
  Stream<DeviceNotify> get deviceNotifyStream => _deviceNotifyController.stream;

  bool get isConnected => _connectedDevices.any((d) => d.isReady);
  List<ConnectedDevice> get connectedDevices => List.unmodifiable(_connectedDevices);
  int get connectedCount => _connectedDevices.where((d) => d.isReady).length;
  ConnectedDevice? get primaryDevice => _connectedDevices.firstWhere((d) => d.isReady, orElse: () => _connectedDevices.isNotEmpty ? _connectedDevices.first : ConnectedDevice(device: BluetoothDevice(remoteId: DeviceIdentifier(''))));

  BluetoothDevice? get device => primaryDevice?.device;
  BluetoothCharacteristic? get notifyCharacteristic => primaryDevice?.notifyCharacteristic;
  int get espSpeed => _espSpeed;
  int get espPause => _espPause;

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

  Future<bool> verifySignature(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();
      for (var svc in services) {
        if (svc.uuid.toString().toLowerCase() == serviceUUID.toLowerCase()) {
          for (var char in svc.characteristics) {
            if (char.uuid.toString().toLowerCase() == signUUID.toLowerCase()) {
              final value = await char.read();
              final sig = String.fromCharCodes(value);
              return sig == bridgeSignature;
            }
          }
        }
      }
    } catch (_) {}
    return false;
  }

  Future<List<BluetoothDevice>> scanAndFindBridges({Duration timeout = const Duration(seconds: 8)}) async {
    final found = <BluetoothDevice>[];

    final sub = FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        final name = r.device.platformName.toLowerCase();
        if (name.contains('braille') && !found.any((d) => d.remoteId == r.device.remoteId)) {
          found.add(r.device);
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: timeout);
    sub.cancel();
    return found;
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await FlutterBluePlus.adapterState.first;
    }
  }

  void _emitDevices() {
    _devicesController.add(List.unmodifiable(_connectedDevices));
    _connectionController.add(isConnected);
  }

  void _onDeviceDisconnected(ConnectedDevice cd) {
    cd.isReady = false;
    cd.writeCharacteristic = null;
    cd.notifyCharacteristic = null;
    cd.notifySub?.cancel();
    cd.connectionStateSub?.cancel();
    _connectedDevices.remove(cd);
    _emitDevices();
    try { cd.device.disconnect(); } catch (_) {}
    _statusController.add('${cd.name} desconectado');
  }

  ConnectedDevice? _findByDevice(BluetoothDevice device) {
    for (var cd in _connectedDevices) {
      if (cd.device.remoteId == device.remoteId) return cd;
    }
    return null;
  }

  Future<bool> connectToDevice(BluetoothDevice device, {bool isAdditional = false}) async {
    try {
      final existing = _findByDevice(device);
      if (existing != null && existing.isReady) {
        _statusController.add('Ja conectado a ${device.platformName}');
        return true;
      }

      _statusController.add('Conectando a ${device.platformName}...');

      await device.connect(timeout: const Duration(seconds: 15));

      var cd = existing ?? ConnectedDevice(device: device);
      if (!_connectedDevices.contains(cd)) {
        _connectedDevices.add(cd);
      }

      cd.connectionStateSub?.cancel();
      cd.connectionStateSub = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _onDeviceDisconnected(cd);
        }
      });

      await device.requestMtu(512);
      await Future.delayed(const Duration(milliseconds: 500));

      List<BluetoothService> services = await device.discoverServices();

      for (var svc in services) {
        if (svc.uuid.toString().toLowerCase() == serviceUUID.toLowerCase()) {
          for (var char in svc.characteristics) {
            final uuid = char.uuid.toString().toLowerCase();
            if (uuid == writeUUID.toLowerCase()) {
              cd.writeCharacteristic = char;
            }
            if (uuid == notifyUUID.toLowerCase()) {
              cd.notifyCharacteristic = char;
              await char.setNotifyValue(true);
              cd.notifySub?.cancel();
              cd.notifySub = char.onValueReceived.listen((value) {
                final msg = String.fromCharCodes(value);
                _notifyController.add(msg);
                _deviceNotifyController.add(DeviceNotify(device: device, message: msg));
              });
            }
          }
          break;
        }
      }

      if (cd.writeCharacteristic == null) {
        for (var svc in services) {
          for (var char in svc.characteristics) {
            if (char.properties.write && cd.writeCharacteristic == null) {
              cd.writeCharacteristic = char;
            }
            if (char.properties.notify && cd.notifyCharacteristic == null) {
              cd.notifyCharacteristic = char;
              await char.setNotifyValue(true);
              cd.notifySub?.cancel();
              cd.notifySub = char.onValueReceived.listen((value) {
                final msg = String.fromCharCodes(value);
                _notifyController.add(msg);
                _deviceNotifyController.add(DeviceNotify(device: device, message: msg));
              });
            }
          }
        }
      }

      cd.isReady = cd.writeCharacteristic != null;
      _emitDevices();

      if (cd.isReady) {
        _statusController.add('Conectado a ${cd.name}!');
        return true;
      } else {
        _statusController.add('ERRO: nenhuma caracteristica encontrada em ${cd.name}');
        return false;
      }
    } catch (e) {
      final cd = _findByDevice(device);
      if (cd != null) _onDeviceDisconnected(cd);
      _statusController.add('Erro ao conectar: $e');
      DatabaseHelper.instance.logError('BLE', 'Falha ao conectar', details: e.toString());
      return false;
    }
  }

  void disconnectDevice(BluetoothDevice device) {
    final cd = _findByDevice(device);
    if (cd != null) _onDeviceDisconnected(cd);
  }

  void disconnectAll() {
    final devices = List<ConnectedDevice>.from(_connectedDevices);
    for (var cd in devices) {
      _onDeviceDisconnected(cd);
    }
  }

  void disconnect() => disconnectAll();

  ConnectedDevice? getConnectedDevice(BluetoothDevice device) => _findByDevice(device);

  Future<void> sendConfig(String key, String value, {BluetoothDevice? target}) async {
    final cmd = '@$key:$value';
    await _sendRaw(cmd, target: target);
  }

  Future<void> sendText(String text, {BluetoothDevice? target}) async {
    await _sendRaw(text, target: target);
  }

  Future<void> sendChar(String char, {BluetoothDevice? target}) async {
    await _sendRaw(char, target: target);
  }

  Future<void> sendToAll(String data) async {
    for (var cd in _connectedDevices) {
      if (cd.isReady) {
        await _sendRaw(data, target: cd.device);
      }
    }
  }

  Future<void> _sendRaw(String data, {BluetoothDevice? target}) async {
    if (target != null) {
      final cd = _findByDevice(target);
      if (cd == null || !cd.isReady || cd.writeCharacteristic == null) {
        _statusController.add('ERRO: ${cd?.name ?? "dispositivo"} nao conectado!');
        return;
      }
      try {
        await cd.writeCharacteristic!.write(data.codeUnits, withoutResponse: false);
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('6') || msg.contains('not connected')) {
          _onDeviceDisconnected(cd);
        }
        _statusController.add('ERRO ao enviar: $e');
        DatabaseHelper.instance.logError('BLE', 'Erro ao enviar', details: 'Dado: $data | Erro: $e');
      }
      return;
    }

    final cd = primaryDevice;
    if (cd == null || !cd.isReady || cd.writeCharacteristic == null) {
      _statusController.add('ERRO: nao conectado!');
      return;
    }

    try {
      await cd.writeCharacteristic!.write(data.codeUnits, withoutResponse: false);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('6') || msg.contains('not connected')) {
        _onDeviceDisconnected(cd);
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

  void dispose() {
    for (var cd in _connectedDevices) {
      cd.connectionStateSub?.cancel();
      cd.notifySub?.cancel();
    }
    _connectionController.close();
    _devicesController.close();
    _scanController.close();
    _statusController.close();
    _notifyController.close();
    _deviceNotifyController.close();
  }
}

class DeviceNotify {
  final BluetoothDevice device;
  final String message;
  DeviceNotify({required this.device, required this.message});
}
