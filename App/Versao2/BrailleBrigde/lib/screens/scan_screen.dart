import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanning = false;
  List<ScanResult> _results = [];

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() async {
    setState(() => _isScanning = true);
    // Simplified scan - in real implementation use flutter_blue_plus
    await Future.delayed(const Duration(seconds: 3));
    setState(() => _isScanning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Escanear Dispositivos',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: _isScanning
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bluetooth_searching, size: 80, color: Colors.grey),
                      const SizedBox(height: 20),
                      Text(
                        'Nenhum dispositivo encontrado',
                        style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _startScan,
                        child: const Text('Escanear Novamente'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.bluetooth),
                      title: Text(_results[index].device.platformName),
                      subtitle: Text(_results[index].device.remoteId.toString()),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(context, _results[index].device);
                      },
                    );
                  },
                ),
    );
  }
}
