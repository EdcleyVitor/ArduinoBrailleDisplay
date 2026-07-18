import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/bluetooth_service.dart';
import 'scan_screen.dart';

class ConnectionScreen extends StatefulWidget {
  final Color bgTop, bgMid, bgBot;
  const ConnectionScreen({super.key, required this.bgTop, required this.bgMid, required this.bgBot});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final BrailleBluetoothService _bleService = BrailleBluetoothService();
  bool _isConnected = false;
  BluetoothAdapterState _btState = BluetoothAdapterState.unknown;
  String _statusMessage = 'Aguardando conexao...';
  StreamSubscription? _connectionSub;
  StreamSubscription? _statusSub;
  StreamSubscription? _btStateSub;

  @override
  void initState() {
    super.initState();
    _isConnected = _bleService.isConnected;
    _connectionSub = _bleService.connectionStream.listen((connected) {
      if (mounted) setState(() => _isConnected = connected);
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

  void _openScan() async {
    await _ensureBluetooth();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanScreen(bleService: _bleService)),
    );
    if (result == true) {
      setState(() {});
    }
  }

  void _disconnect() {
    _bleService.disconnect();
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
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Pare o seu dispositivo BrailleBridge',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withAlpha(180),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
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
                        _isConnected
                            ? Icons.bluetooth_rounded
                            : !_isBluetoothOn
                                ? Icons.bluetooth_disabled_rounded
                                : Icons.bluetooth_disabled_rounded,
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
                    if (_isConnected && _bleService.device != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withAlpha(15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _bleService.device!.platformName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (!_isConnected)
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
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _disconnect,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red, width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              'Desconectar',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
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
}
