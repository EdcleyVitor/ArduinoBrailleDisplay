import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatelessWidget {
  final Color bgTop, bgMid, bgBot;
  const InfoScreen({super.key, required this.bgTop, required this.bgMid, required this.bgBot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informacoes', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgMid, bgBot],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInfoCard(
              icon: Icons.info_outline,
              title: 'Sobre o BrailleBridge',
              children: [
                _infoRow('Versao', '6.0.0'),
                _infoRow('Plataforma', 'ESP32 + Flutter'),
                _infoRow('Protocolo', 'BLE (Nordic UART Service)'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.people,
              title: 'Equipe',
              children: [
                _infoRow('Desenvolvedor', 'Edcley Vitor'),
                _infoRow('Orientador', 'Josecley Fialho'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.code,
              title: 'Tecnologias',
              children: [
                _infoRow('App', 'Flutter 3.32 + Dart'),
                _infoRow('BLE', 'flutter_blue_plus'),
                _infoRow('Fontes', 'google_fonts (Poppins)'),
                _infoRow('Persistencia', 'sqflite (SQLite)'),
                _infoRow('Firmware', 'Arduino C++ (ESP32)'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.memory,
              title: 'Firmware',
              children: [
                _infoRow('Pinos LEDs', 'D18, D19, D21, D25, D33, D32'),
                _infoRow('LED Interno', 'GPIO 2'),
                _infoRow('BLE Service', 'NUS (6e400001)'),
                _infoRow('Config', 'Preferences (EEPROM)'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse('https://github.com/EdcleyVitor/ArduinoBrailleDisplay')),
                icon: const Icon(Icons.open_in_new),
                label: Text('Ver no GitHub', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dados: Julho 2026',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6C63FF)),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.white70)),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}
