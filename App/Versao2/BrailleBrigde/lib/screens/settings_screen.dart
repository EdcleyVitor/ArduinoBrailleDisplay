import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _displaySpeed = 1.5;

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
                  Icon(Icons.settings, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'Configurações',
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
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Speed Setting
                    Text(
                      'Velocidade de Exibição',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ajuste a velocidade em que as letras são exibidas no display.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: _displaySpeed,
                      min: 0.5,
                      max: 3.0,
                      divisions: 5,
                      label: '${_displaySpeed.toStringAsFixed(1)}s',
                      activeColor: const Color(0xFF2563EB),
                      onChanged: (value) {
                        setState(() => _displaySpeed = value);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rápido', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                        Text('Lento', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Divider(color: Colors.grey[300]),
                    const SizedBox(height: 20),
                    // About Section
                    Text(
                      'Sobre',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.info_outline,
                      title: 'BrailleBridge',
                      subtitle: 'Versão 2.0.0',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoCard(
                      icon: Icons.person_outline,
                      title: 'Desenvolvedor',
                      subtitle: 'Edcley Vitor',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoCard(
                      icon: Icons.school_outlined,
                      title: 'Orientador',
                      subtitle: 'Josecley Fialho',
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
