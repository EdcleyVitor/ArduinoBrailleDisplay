import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/settings_manager.dart';
import 'personalization_screen.dart';
import 'preferences_screen.dart';
import 'esp_config_screen.dart';
import 'info_screen.dart';
import 'support_screen.dart';



class SettingsScreen extends StatelessWidget {
  final SettingsManager settings;
  final Color bgTop, bgMid, bgBot;

  const SettingsScreen({
    super.key,
    required this.settings,
    required this.bgTop,
    required this.bgMid,
    required this.bgBot,
  });

  @override
  Widget build(BuildContext context) {
    final s = settings;
    final primary = s.primaryAppColor;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgTop, bgMid, bgBot],
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
                    child: const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Configuracoes',
                    style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
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
                    BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildNavButton(context, primary,
                      icon: Icons.palette_rounded,
                      title: 'Personalizacao',
                      subtitle: 'Tema, cores, fonte, icones e estilo',
                      onTap: () => _open(context, PersonalizationScreen(settings: s, bgTop: bgTop, bgMid: bgMid, bgBot: bgBot)),
                    ),
                    const SizedBox(height: 12),
                    _buildNavButton(context, primary,
                      icon: Icons.tune,
                      title: 'Preferencias do App',
                      subtitle: 'Separador, acentos, caracteres especiais',
                      onTap: () => _open(context, PreferencesScreen(settings: s, bgTop: bgTop, bgMid: bgMid, bgBot: bgBot)),
                    ),
                    const SizedBox(height: 12),
                    _buildNavButton(context, primary,
                      icon: Icons.memory,
                      title: 'Config ESP32',
                      subtitle: 'Velocidade, pausa, teste',
                      onTap: () => _open(context, EspConfigScreen(settings: s, bgTop: bgTop, bgMid: bgMid, bgBot: bgBot)),
                    ),
                    const SizedBox(height: 12),
                    _buildNavButton(context, primary,
                      icon: Icons.bug_report,
                      title: 'Suporte / Erros',
                      subtitle: 'Ver logs, exportar .txt',
                      onTap: () => _open(context, SupportScreen(bgTop: bgTop, bgMid: bgMid, bgBot: bgBot)),
                    ),
                    const SizedBox(height: 12),
                    _buildNavButton(context, primary,
                      icon: Icons.info_outline,
                      title: 'Informacoes',
                      subtitle: 'Sobre, equipe, tecnologias',
                      onTap: () => _open(context, InfoScreen(bgTop: bgTop, bgMid: bgMid, bgBot: bgBot)),
                    ),
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

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildNavButton(BuildContext context, Color primary, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(30)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(subtitle, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
