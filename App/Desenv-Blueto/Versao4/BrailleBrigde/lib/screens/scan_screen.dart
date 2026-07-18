import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() => _isScanning = false);
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
      body: _isScanning
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF6C63FF)),
                  const SizedBox(height: 20),
                  Text(
                    'Procurando dispositivos...',
                    style: GoogleFonts.poppins(fontSize: 16, color: const Color(0xFF757575)),
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bluetooth_searching_rounded, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text(
                    'Nenhum dispositivo encontrado',
                    style: GoogleFonts.poppins(fontSize: 18, color: const Color(0xFF757575)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _startScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Escanear Novamente', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            ),
    );
  }
}
