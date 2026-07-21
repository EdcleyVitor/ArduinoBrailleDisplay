import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/bluetooth_service.dart';
import '../services/settings_manager.dart';
import 'scan_screen.dart';

class ConnectionScreen extends StatefulWidget {
  final Color bgTop, bgMid, bgBot;
  const ConnectionScreen({super.key, required this.bgTop, required this.bgMid, required this.bgBot});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final BrailleBluetoothService _bleService = BrailleBluetoothService();
  final SettingsManager _settings = SettingsManager();
  bool _isConnected = false;
  int _deviceCount = 0;
  List<ConnectedDevice> _devices = [];
  BluetoothAdapterState _btState = BluetoothAdapterState.unknown;
  String _statusMessage = 'Aguardando conexao...';
  StreamSubscription? _connectionSub;
  StreamSubscription? _devicesSub;
  StreamSubscription? _statusSub;
  StreamSubscription? _btStateSub;

  @override
  void initState() {
    super.initState();
    _isConnected = _bleService.isConnected;
    _deviceCount = _bleService.connectedCount;
    _devices = _bleService.connectedDevices;
    _connectionSub = _bleService.connectionStream.listen((connected) {
      if (mounted) setState(() {
        _isConnected = connected;
        _deviceCount = _bleService.connectedCount;
        _devices = _bleService.connectedDevices;
      });
    });
    _devicesSub = _bleService.devicesStream.listen((devices) {
      if (mounted) setState(() {
        _devices = devices;
        _deviceCount = devices.where((d) => d.isReady).length;
        _isConnected = _bleService.isConnected;
      });
    });
    _statusSub = _bleService.statusStream.listen((msg) {
      if (mounted) setState(() => _statusMessage = msg);
    });
    _btStateSub = FlutterBluePlus.adapterState.listen((state) {
      if (mounted) setState(() => _btState = state);
    });
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    _devicesSub?.cancel();
    _statusSub?.cancel();
    _btStateSub?.cancel();
    super.dispose();
  }

  Future<void> _ensureBluetooth() async {
    if (_btState == BluetoothAdapterState.on) return;
    final on = await _bleService.ensureBluetoothOn();
    if (!on && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Bluetooth Desligado', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text('Ligue o Bluetooth do seu celular para conectar ao ESP32.', style: GoogleFonts.poppins()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: GoogleFonts.poppins(color: const Color(0xFF6C63FF))),
            ),
          ],
        ),
      );
    }
  }

  void _openScan({bool additional = false}) async {
    await _ensureBluetooth();
    final settings = SettingsManager();
    final isAdditional = additional && settings.conectarMultiplos;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanScreen(bleService: _bleService, isAdditional: isAdditional)),
    );
    if (result == true) {
      setState(() {});
    }
  }

  void _disconnectDevice(ConnectedDevice cd) {
    _bleService.disconnectDevice(cd.device);
  }

  void _disconnectAll() {
    _bleService.disconnectAll();
  }

  void _connectAll() async {
    await _ensureBluetooth();
    if (!_isBluetoothOn) return;

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF6C63FF)),
              const SizedBox(height: 20),
              Text('Procurando dispositivos...', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              StreamBuilder<String>(
                stream: _bleService.statusStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      );
    }

    final devices = await _bleService.scanAndFindBridges(timeout: const Duration(seconds: 8));

    if (devices.isEmpty) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nenhum BrailleBridge encontrado!', style: GoogleFonts.poppins()),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    int connected = 0;
    for (var device in devices) {
      final alreadyConnected = _bleService.connectedDevices.any((d) => d.id == device.remoteId.toString() && d.isReady);
      if (alreadyConnected) continue;
      final success = await _bleService.connectToDevice(device);
      if (success) connected++;
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            connected > 0 ? '$connected dispositivo(s) conectado(s)!' : 'Falha ao conectar',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: connected > 0 ? const Color(0xFF4CAF50) : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      setState(() {});
    }
  }

  bool get _isBluetoothOn => _btState == BluetoothAdapterState.on;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [widget.bgTop, widget.bgMid, widget.bgBot],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bluetooth_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Conectar',
                    style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  if (_deviceCount > 1) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_deviceCount dispositivos',
                        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF4CAF50), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Pare o seu dispositivo BrailleBridge',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withAlpha(180)),
              ),
            ),
            const SizedBox(height: 24),
            if (_isConnected && _devices.isNotEmpty) ...[
              _buildConnectedDevicesList(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    if (_settings.conectarMultiplos)
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () => _openScan(additional: true),
                            icon: const Icon(Icons.add, size: 20),
                            label: Text('Mais', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 4,
                            ),
                          ),
                        ),
                      ),
                    if (_settings.conectarMultiplos) const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _connectAll,
                          icon: const Icon(Icons.flash_on_rounded, size: 18),
                          label: Text('Todos', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4CAF50),
                            side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _disconnectAll,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text('Desconectar', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _isConnected
                                ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
                                : _isBluetoothOn
                                    ? [const Color(0xFFE0E0E0), const Color(0xFFBDBDBD)]
                                    : [const Color(0xFFFF9800), const Color(0xFFE65100)],
                          ),
                          boxShadow: _isConnected
                              ? [BoxShadow(color: const Color(0xFF4CAF50).withAlpha(60), blurRadius: 24, spreadRadius: 4)]
                              : !_isBluetoothOn
                                  ? [BoxShadow(color: const Color(0xFFFF9800).withAlpha(40), blurRadius: 20, spreadRadius: 2)]
                                  : [],
                        ),
                        child: Icon(
                          _isConnected ? Icons.bluetooth_rounded : Icons.bluetooth_disabled_rounded,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        _isConnected
                            ? 'Conectado!'
                            : !_isBluetoothOn
                                ? 'Bluetooth Desligado'
                                : 'Desconectado',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _isConnected
                              ? const Color(0xFF2E7D32)
                              : !_isBluetoothOn
                                  ? const Color(0xFFE65100)
                                  : const Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withAlpha(120)),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _openScan,
                            icon: Icon(
                              _isBluetoothOn ? Icons.bluetooth_searching_rounded : Icons.bluetooth_rounded,
                              size: 22,
                            ),
                            label: Text(
                              _isBluetoothOn ? 'Escanear Dispositivos' : 'Ligar Bluetooth e Escanear',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isBluetoothOn ? const Color(0xFF6C63FF) : const Color(0xFFFF9800),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _isBluetoothOn ? _connectAll : null,
                            icon: const Icon(Icons.flash_on_rounded, size: 20),
                            label: Text('Conectar Todos', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4CAF50),
                              side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedDevicesList() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _devices.length,
          itemBuilder: (context, index) {
            final cd = _devices[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cd.isReady ? const Color(0xFF4CAF50).withAlpha(10) : Colors.grey.withAlpha(10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cd.isReady ? const Color(0xFF4CAF50).withAlpha(50) : Colors.grey.withAlpha(30),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cd.isReady ? const Color(0xFF4CAF50).withAlpha(20) : Colors.grey.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.bluetooth_rounded,
                      color: cd.isReady ? const Color(0xFF4CAF50) : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cd.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(
                          cd.id,
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (cd.isReady)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withAlpha(15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ON',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF4CAF50)),
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _disconnectDevice(cd),
                    icon: const Icon(Icons.close, color: Colors.red, size: 20),
                    tooltip: 'Desconectar',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
