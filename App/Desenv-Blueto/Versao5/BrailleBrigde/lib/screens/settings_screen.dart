import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  final Color bgTop, bgMid, bgBot;
  final void Function(ThemeMode) onThemeChanged;
  final void Function(Color) onColorChanged;
  final ThemeMode currentThemeMode;
  final Color currentSeedColor;

  const SettingsScreen({
    super.key,
    required this.bgTop,
    required this.bgMid,
    required this.bgBot,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.currentThemeMode,
    required this.currentSeedColor,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _displaySpeed = 1.5;

  static const List<Color> _colors = [
    Color(0xFF2196F3),
    Color(0xFF6C63FF),
    Color(0xFF009688),
    Color(0xFFFF9800),
    Color(0xFFF44336),
    Color(0xFF4CAF50),
  ];

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
                    decoration: BoxDecoration(color: Colors.white.withAlpha(25), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Text('Config', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildSectionTitle('Personalização'),
                    const SizedBox(height: 12),
                    _buildThemeSection(),
                    const SizedBox(height: 16),
                    _buildColorSection(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Dispositivo'),
                    const SizedBox(height: 12),
                    _buildSpeedCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Informações'),
                    const SizedBox(height: 12),
                    _buildInfoCard(icon: Icons.code_rounded, title: 'BrailleBridge', subtitle: 'Versão 5.0.0'),
                    const SizedBox(height: 8),
                    _buildInfoCard(icon: Icons.person_rounded, title: 'Desenvolvedor', subtitle: 'Edcley Vitor'),
                    const SizedBox(height: 8),
                    _buildInfoCard(icon: Icons.school_rounded, title: 'Orientador', subtitle: 'Josecley Fialho'),
                    const SizedBox(height: 8),
                    _buildGitHubCard(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildThemeSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: widget.currentSeedColor.withAlpha(15), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.dark_mode_rounded, color: widget.currentSeedColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Tema', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildThemeOption(ThemeMode.light, 'Claro', Icons.light_mode_rounded),
              const SizedBox(width: 8),
              _buildThemeOption(ThemeMode.dark, 'Escuro', Icons.dark_mode_rounded),
              const SizedBox(width: 8),
              _buildThemeOption(ThemeMode.system, 'Sistema', Icons.phone_iphone_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(ThemeMode mode, String label, IconData icon) {
    final isSelected = widget.currentThemeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onThemeChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? widget.currentSeedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? widget.currentSeedColor : Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(height: 4),
              Text(label, style: GoogleFonts.poppins(fontSize: 11, color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: widget.currentSeedColor.withAlpha(15), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.palette_rounded, color: widget.currentSeedColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Cor de Destaque', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _colors.map((color) {
              final isSelected = widget.currentSeedColor.value == color.value;
              return GestureDetector(
                onTap: () => widget.onColorChanged(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 3),
                    boxShadow: isSelected ? [BoxShadow(color: color.withAlpha(80), blurRadius: 8, spreadRadius: 2)] : [],
                  ),
                  child: isSelected ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: widget.currentSeedColor.withAlpha(15), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.speed_rounded, color: widget.currentSeedColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Velocidade', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('${_displaySpeed.toStringAsFixed(1)}s por letra', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: widget.currentSeedColor,
              inactiveTrackColor: widget.currentSeedColor.withAlpha(30),
              thumbColor: widget.currentSeedColor,
              overlayColor: widget.currentSeedColor.withAlpha(30),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _displaySpeed,
              min: 0.5,
              max: 3.0,
              divisions: 5,
              onChanged: (value) => setState(() => _displaySpeed = value),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rápido', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
              Text('Lento', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: widget.currentSeedColor.withAlpha(15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: widget.currentSeedColor, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGitHubCard() {
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse('https://github.com/EdcleyVitor/ArduinoBrailleDisplay');
        if (await canLaunchUrl(url)) await launchUrl(url);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(50)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: widget.currentSeedColor.withAlpha(15), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.link_rounded, color: widget.currentSeedColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GitHub', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('Ver código-fonte', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.open_in_new_rounded, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
