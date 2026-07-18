import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppStyle { padrao, neon }

class PersonalizationScreen extends StatefulWidget {
  final Color bgTop, bgMid, bgBot;
  final ThemeMode currentThemeMode;
  final Color currentSeedColor;
  final AppStyle currentStyle;
  final void Function(ThemeMode) onThemeChanged;
  final void Function(Color) onColorChanged;
  final void Function(AppStyle) onStyleChanged;

  const PersonalizationScreen({
    super.key,
    required this.bgTop,
    required this.bgMid,
    required this.bgBot,
    required this.currentThemeMode,
    required this.currentSeedColor,
    required this.currentStyle,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.onStyleChanged,
  });

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  late ThemeMode _themeMode;
  late Color _seedColor;
  late AppStyle _appStyle;

  final List<ColorOption> _colors = [
    ColorOption(color: const Color(0xFF6C63FF), name: 'Roxo'),
    ColorOption(color: const Color(0xFF2196F3), name: 'Azul'),
    ColorOption(color: const Color(0xFF4CAF50), name: 'Verde'),
    ColorOption(color: const Color(0xFFFF9800), name: 'Laranja'),
    ColorOption(color: const Color(0xFFF44336), name: 'Vermelho'),
    ColorOption(color: const Color(0xFFE91E63), name: 'Rosa'),
    ColorOption(color: const Color(0xFF00BCD4), name: 'Ciano'),
    ColorOption(color: const Color(0xFF9C27B0), name: 'Magenta'),
    ColorOption(color: const Color(0xFF795548), name: 'Marrom'),
    ColorOption(color: const Color(0xFF607D8B), name: 'Cinza Azul'),
  ];

  @override
  void initState() {
    super.initState();
    _themeMode = widget.currentThemeMode;
    _seedColor = widget.currentSeedColor;
    _appStyle = widget.currentStyle;
  }

  @override
  Widget build(BuildContext context) {
    final isNeon = _appStyle == AppStyle.neon;
    final bgColor = isNeon ? const Color(0xFF050510) : widget.bgTop;
    final cardColor = isNeon ? const Color(0xFF0A0A20) : Theme.of(context).colorScheme.surface.withAlpha(230);
    final textColor = isNeon ? Colors.white : null;
    final accentColor = isNeon ? const Color(0xFF00E5FF) : const Color(0xFF6C63FF);

    return Scaffold(
      appBar: AppBar(
        title: Text('Personalizacao', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: isNeon ? const Color(0xFF0A0A20) : accentColor,
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
            _buildSection('Tema', cardColor, textColor, [
              _buildThemeOption('Claro', Icons.light_mode, ThemeMode.light, accentColor, textColor),
              _buildThemeOption('Escuro', Icons.dark_mode, ThemeMode.dark, accentColor, textColor),
              _buildThemeOption('Sistema', Icons.phone_android, ThemeMode.system, accentColor, textColor),
            ]),
            const SizedBox(height: 20),
            _buildSection('Cor de Destaque', cardColor, textColor, _buildColorGrid(accentColor)),
            const SizedBox(height: 20),
            _buildSection('Estilo do App', cardColor, textColor, [
              _buildStyleOption('Padrao', 'Design Material3', AppStyle.padrao, Icons.style, accentColor, textColor),
              _buildStyleOption('Neon', 'Visual com brilho neon', AppStyle.neon, Icons.flash_on, accentColor, textColor),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Color cardColor, Color? textColor, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeOption(String label, IconData icon, ThemeMode mode, Color accent, Color? textColor) {
    final isSelected = _themeMode == mode;
    return ListTile(
      leading: Icon(icon, color: isSelected ? accent : Colors.grey),
      title: Text(label, style: GoogleFonts.poppins(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: textColor)),
      trailing: isSelected ? Icon(Icons.check_circle, color: accent) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isSelected ? accent.withAlpha(20) : null,
      onTap: () {
        setState(() => _themeMode = mode);
        widget.onThemeChanged(mode);
      },
    );
  }

  List<Widget> _buildColorGrid(Color accent) {
    return [
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _colors.map((c) {
          final isSelected = _seedColor.value == c.color.value;
          return GestureDetector(
            onTap: () {
              setState(() => _seedColor = c.color);
              widget.onColorChanged(c.color);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: c.color,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 3),
                boxShadow: isSelected ? [BoxShadow(color: c.color.withAlpha(100), blurRadius: 12, spreadRadius: 2)] : [],
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
            ),
          );
        }).toList(),
      ),
    ];
  }

  Widget _buildStyleOption(String label, String desc, AppStyle style, IconData icon, Color accent, Color? textColor) {
    final isSelected = _appStyle == style;
    return ListTile(
      leading: Icon(icon, color: isSelected ? accent : Colors.grey),
      title: Text(label, style: GoogleFonts.poppins(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: textColor)),
      subtitle: Text(desc, style: GoogleFonts.poppins(fontSize: 12, color: textColor ?? Colors.grey)),
      trailing: isSelected ? Icon(Icons.check_circle, color: accent) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isSelected ? accent.withAlpha(20) : null,
      onTap: () {
        setState(() => _appStyle = style);
        widget.onStyleChanged(style);
      },
    );
  }
}

class ColorOption {
  final Color color;
  final String name;
  ColorOption({required this.color, required this.name});
}
