import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/bluetooth_service.dart';
import 'scan_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final BrailleBluetoothService _bleService = BrailleBluetoothService();
  bool _isConnected = false;
  String _deviceName = '';
  String _statusMessage = '';
  StreamSubscription? _connectionSub;
  StreamSubscription? _statusSub;

  @override
  void initState() {
    super.initState();
    _isConnected = _bleService.isConnected;
    if (_bleService.connectedDevice != null) {
      _deviceName = _bleService.connectedDevice!.platformName;
    }
    _connectionSub = _bleService.connectionStream.listen((connected) {
      if (mounted) {
        setState(() {
          _isConnected = connected;
          if (!connected) _deviceName = '';
        });
      }
    });
    _statusSub = _bleService.statusStream.listen((msg) {
      if (mounted) setState(() => _statusMessage = msg);
    });
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }

  Future<void> _openScan() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ScanScreen(bleService: _bleService)),
    );

    if (result == true && mounted) {
      setState(() {
        _isConnected = true;
        _deviceName = _bleService.connectedDevice?.platformName ?? 'ESP32';
      });
    }
  }

  Future<void> _disconnect() async {
    await _bleService.disconnect();
    if (mounted) {
      setState(() {
        _isConnected = false;
        _deviceName = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121220) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Braille Bridge',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Conexão Bluetooth',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: _isConnected
                                  ? primaryColor.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                              size: 50,
                              color: _isConnected ? primaryColor : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _isConnected ? _deviceName : 'Nenhum dispositivo',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _isConnected ? primaryColor : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isConnected
                                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _isConnected ? const Color(0xFF4CAF50) : Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isConnected ? 'Conectado' : 'Desconectado',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _isConnected ? const Color(0xFF4CAF50) : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_statusMessage.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              _statusMessage,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isDark ? Colors.grey : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isConnected ? _disconnect : _openScan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isConnected ? const Color(0xFFEF5350) : primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isConnected ? Icons.link_off : Icons.bluetooth_searching, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              _isConnected ? 'Desconectar' : 'Buscar Dispositivos',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: primaryColor.withOpacity(0.7), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Conecte ao ESP32 "BrailleBridge" para enviar textos',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: primaryColor.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
