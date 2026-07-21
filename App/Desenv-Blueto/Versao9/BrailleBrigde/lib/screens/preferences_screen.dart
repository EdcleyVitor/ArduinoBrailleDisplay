import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/settings_manager.dart';

class PreferencesScreen extends StatefulWidget {
  final SettingsManager settings;
  final Color bgTop, bgMid, bgBot;

  const PreferencesScreen({
    super.key,
    required this.settings,
    required this.bgTop,
    required this.bgMid,
    required this.bgBot,
  });

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  @override
  void initState() {
    super.initState();
    widget.settings.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.settings.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.settings;
    final isNeon = s.isNeon;
    final accent = s.primaryAppColor;
    final bgColor = isNeon ? const Color(0xFF050510) : widget.bgTop;
    final cardColor = isNeon ? const Color(0xFF0A0A20) : Theme.of(context).colorScheme.surface.withAlpha(230);
    final textColor = isNeon ? Colors.white : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Preferencias do App', style: GoogleFonts.getFont(s.fontName, color: Colors.white)),
        backgroundColor: isNeon ? const Color(0xFF0A0A20) : accent,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgColor, widget.bgMid, widget.bgBot],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('Envio de Texto', cardColor, textColor, [
              _buildToggle(
                title: 'Separador Alfabeto/Numeros',
                subtitle: 'Divide teclado em Abc (letras) e 123 (numeros + operacoes)',
                value: s.separadorAlfabetoNumero,
                onChanged: (val) => s.setSeparadorAlfabetoNumero(val),
                icon: Icons.tab,
                accent: accent,
                s: s,
                textColor: textColor,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('Conversao Braille', cardColor, textColor, [
              _buildToggle(
                title: 'Ignorar Acentos',
                subtitle: 'Remove acentos antes de converter (a, e, c...)',
                value: s.ignorarAcentos,
                onChanged: (val) => s.setIgnorarAcentos(val),
                icon: Icons.text_fields,
                accent: accent,
                s: s,
                textColor: textColor,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('Caracteres Especiais', cardColor, textColor, [
              _buildToggle(
                title: 'Caracteres Especiais',
                subtitle: 'Permite envio de ?, !, /, @, #, etc.',
                value: s.caracteresEspeciais,
                onChanged: (val) => s.setCaracteresEspeciais(val),
                icon: Icons.code,
                accent: accent,
                s: s,
                textColor: textColor,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('Conexao', cardColor, textColor, [
              _buildToggle(
                title: 'Conectar em Multiplas',
                subtitle: 'Permite conectar em varios ESP32s ao mesmo tempo',
                value: s.conectarMultiplos,
                onChanged: (val) => s.setConectarMultiplos(val),
                icon: Icons.device_hub,
                accent: accent,
                s: s,
                textColor: textColor,
              ),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Color cardColor, Color? textColor, List<Widget> children) {
    final s = widget.settings;
    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.getFont(s.fontName, fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggle({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    required Color accent,
    required SettingsManager s,
    required Color? textColor,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: value ? accent : Colors.grey),
      title: Text(title, style: GoogleFonts.getFont(s.fontName, fontWeight: FontWeight.w600, color: textColor)),
      subtitle: Text(subtitle, style: GoogleFonts.getFont(s.fontName, fontSize: 12, color: Colors.grey)),
      value: value,
      onChanged: onChanged,
      activeColor: accent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: value ? accent.withAlpha(15) : null,
    );
  }
}
