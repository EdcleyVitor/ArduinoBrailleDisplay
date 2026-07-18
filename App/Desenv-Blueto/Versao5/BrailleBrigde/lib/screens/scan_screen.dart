import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/bluetooth_service.dart';

class ScanScreen extends StatefulWidget {
  final BrailleBluetoothService bleService;
  const ScanScreen({super.key, required this.bleService});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<ScanResult> _results = [];
  bool _isScanning = false;
  StreamSubscription? _scanSub;
  StreamSubscription? _statusSub;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _scanSub = widget.bleService.scanStream.listen((results) {
      if (mounted) {
        setState(() {
          _results = results.where((r) {
            final name = r.device.platformName.toLowerCase();
            return name.contains('braille') ||
                name.contains('ble') ||
                name.contains('esp') ||
                name.isNotEmpty;
          }).toList();
        });
      }
    });
    _statusSub = widget.bleService.statusStream.listen((msg) {
      if (mounted) setState(() => _statusMessage = msg);
    });
    _checkAndScan();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }

  Future<void> _checkAndScan() async {
    final on = await widget.bleService.ensureBluetoothOn();
    if (!on && mounted) {
      _showBluetoothOffDialog();
      return;
    }
    await widget.bleService.requestPermissions();
    _startScan();
  }

  void _showBluetoothOffDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bluetooth Desligado', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Ligue o Bluetooth do seu celular para escanear dispositivos.', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final on = await widget.bleService.ensureBluetoothOn();
              if (on && mounted) _startScan();
            },
            child: Text('Ligar', style: GoogleFonts.poppins(color: const Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      _results = [];
    });
    widget.bleService.startScan();
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) setState(() => _isScanning = false);
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF6C63FF)),
            const SizedBox(height: 20),
            Text('Conectando...', style: GoogleFonts.poppins()),
            const SizedBox(height: 8),
            StreamBuilder<String>(
              stream: widget.bleService.statusStream,
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

    final success = await widget.bleService.connectToDevice(device);
    if (mounted) {
      Navigator.pop(context);
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao conectar. Verifique se o ESP32 esta ligado.', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanear Dispositivos', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isScanning && _results.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF6C63FF)),
                  const SizedBox(height: 20),
                  Text('Procurando dispositivos...', style: GoogleFonts.poppins(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Ative o Bluetooth do seu celular', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                ],
              ),
            )
          : _results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bluetooth_searching_rounded, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 20),
                      Text('Nenhum dispositivo encontrado', style: GoogleFonts.poppins(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Verifique se o ESP32 esta ligado', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('Tente reiniciar o ESP32', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _startScan,
                        icon: const Icon(Icons.refresh),
                        label: Text('Escanear Novamente', style: GoogleFonts.poppins()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (_isScanning)
                      const LinearProgressIndicator(color: Color(0xFF6C63FF)),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final device = _results[index].device;
                          final name = device.platformName.isNotEmpty
                              ? device.platformName
                              : 'Desconhecido';
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const Icon(Icons.bluetooth_rounded, color: Color(0xFF6C63FF)),
                              title: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                              subtitle: Text(device.remoteId.toString(), style: GoogleFonts.poppins(fontSize: 12)),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => _connectToDevice(device),
                            ),
                          );
                        },
                      ),
                    ),
                    if (!_isScanning && _results.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _startScan,
                            icon: const Icon(Icons.refresh),
                            label: Text('Escanear Novamente', style: GoogleFonts.poppins()),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6C63FF),
                              side: const BorderSide(color: Color(0xFF6C63FF)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
