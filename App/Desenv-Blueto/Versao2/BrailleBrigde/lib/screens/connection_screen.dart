import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scan_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  BluetoothDevice? _device;
  bool _isConnected = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  void _checkConnection() {
    if (_device != null) {
      setState(() {
        _isConnected = _device!.isConnected;
      });
    }
  }

  void _openScan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanScreen()),
    );
    if (result != null && result is BluetoothDevice) {
      setState(() {
        _device = result;
        _isConnected = result.isConnected;
      });
    }
  }

  void _disconnect() async {
    if (_device != null) {
      await _device!.disconnect();
      setState(() {
        _isConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.bluetooth,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Conectar Dispositivo',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                      size: 80,
                      color: _isConnected ? const Color(0xFF22C55E) : Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isConnected ? 'Conectado' : 'Desconectado',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _isConnected ? const Color(0xFF22C55E) : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_device != null)
                      Text(
                        _device!.platformName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    const SizedBox(height: 30),
                    if (!_isConnected)
                      ElevatedButton(
                        onPressed: _isScanning ? null : _openScan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isScanning ? 'Escaneando...' : 'Escanear Dispositivos',
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: _disconnect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Desconectar',
                          style: GoogleFonts.poppins(fontSize: 16),
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
