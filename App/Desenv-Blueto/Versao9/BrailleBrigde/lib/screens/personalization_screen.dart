import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/settings_manager.dart';

class PersonalizationScreen extends StatefulWidget {
  final SettingsManager settings;
  final Color bgTop, bgMid, bgBot;

  const PersonalizationScreen({
    super.key,
    required this.settings,
    required this.bgTop,
    required this.bgMid,
    required this.bgBot,
  });

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
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
    final secondary = s.secondaryAppColor;
    final bgColor = isNeon ? const Color(0xFF050510) : widget.bgTop;
    final cardColor = isNeon ? const Color(0xFF0A0A20) : Theme.of(context).colorScheme.surface.withAlpha(230);
    final textColor = isNeon ? Colors.white : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Personalizacao', style: GoogleFonts.getFont(s.fontName, color: Colors.white)),
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
            _buildSection('Tema', cardColor, textColor, [
              _buildThemeOption('Claro', Icons.light_mode, ThemeMode.light, accent),
              _buildThemeOption('Escuro', Icons.dark_mode, ThemeMode.dark, accent),
              _buildThemeOption('Sistema', Icons.phone_android, ThemeMode.system, accent),
            ]),
            const SizedBox(height: 16),
            _buildSection('Estilo do App', cardColor, textColor, [
              _buildStyleOption('Padrao', 'Design Material3', 'padrao', Icons.style, accent),
              _buildStyleOption('Neon', 'Visual com brilho neon', 'neon', Icons.flash_on, accent),
            ]),
            const SizedBox(height: 16),
            _buildSection('Cor Primaria do App', cardColor, textColor, _buildColorGrid(accent, (c) => s.setPrimaryAppColor(c))),
            const SizedBox(height: 16),
            _buildSection('Cor Secundaria do App', cardColor, textColor, _buildColorGrid(secondary, (c) => s.setSecondaryAppColor(c))),
            const SizedBox(height: 16),
            _buildSection('Cor de Destaque (Seed)', cardColor, textColor, _buildColorGrid(s.seedColor, (c) => s.setSeedColor(c))),
            const SizedBox(height: 16),
            _buildSection('Fonte', cardColor, textColor, _buildFontList(accent)),
            const SizedBox(height: 16),
            _buildSection('Tamanho da Fonte', cardColor, textColor, _buildFontSizeSlider(accent, textColor)),
            const SizedBox(height: 16),
            _buildSection('Cor Texto Principal', cardColor, textColor, _buildTextColorGrid(s.primaryTextColor, (c) => s.setPrimaryTextColor(c))),
            const SizedBox(height: 16),
            _buildSection('Cor Texto Secundario', cardColor, textColor, _buildTextColorGrid(s.secondaryTextColor, (c) => s.setSecondaryTextColor(c))),
            const SizedBox(height: 16),
            _buildPreview(cardColor, accent, textColor),
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

  Widget _buildThemeOption(String label, IconData icon, ThemeMode mode, Color accent) {
    final s = widget.settings;
    final isSelected = s.themeMode == mode;
    return ListTile(
      leading: Icon(icon, color: isSelected ? accent : Colors.grey),
      title: Text(label, style: GoogleFonts.getFont(s.fontName, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? Icon(Icons.check_circle, color: accent) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isSelected ? accent.withAlpha(20) : null,
      onTap: () => s.setThemeMode(mode),
    );
  }

  Widget _buildStyleOption(String label, String desc, String style, IconData icon, Color accent) {
    final s = widget.settings;
    final isSelected = s.appStyle.name == style;
    return ListTile(
      leading: Icon(icon, color: isSelected ? accent : Colors.grey),
      title: Text(label, style: GoogleFonts.getFont(s.fontName, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      subtitle: Text(desc, style: GoogleFonts.getFont(s.fontName, fontSize: 12, color: Colors.grey)),
      trailing: isSelected ? Icon(Icons.check_circle, color: accent) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: isSelected ? accent.withAlpha(20) : null,
      onTap: () => s.setAppStyle(style),
    );
  }

  List<Widget> _buildColorGrid(Color current, Function(Color) onSelected) {
    final colors = [
      const Color(0xFF6C63FF), const Color(0xFF2196F3), const Color(0xFF4CAF50),
      const Color(0xFFFF9800), const Color(0xFFF44336), const Color(0xFFE91E63),
      const Color(0xFF00BCD4), const Color(0xFF9C27B0), const Color(0xFF795548),
      const Color(0xFF607D8B), const Color(0xFF009688), const Color(0xFFFF5722),
      const Color(0xFF3F51B5), const Color(0xFF8BC34A), const Color(0xFFFFC107),
      const Color(0xFFCDDC39), const Color(0xFF000000), const Color(0xFFFFFFFF),
    ];
    return [
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: colors.map((c) {
          final isSelected = current.value == c.value;
          return GestureDetector(
            onTap: () => onSelected(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : (c.computeLuminance() > 0.5 ? Colors.grey[400]! : Colors.grey[700]!),
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected ? [BoxShadow(color: c.withAlpha(100), blurRadius: 12, spreadRadius: 2)] : [],
              ),
              child: isSelected ? Icon(Icons.check, color: c.computeLuminance() > 0.5 ? Colors.black : Colors.white, size: 18) : null,
            ),
          );
        }).toList(),
      ),
    ];
  }

  List<Widget> _buildTextColorGrid(Color current, Function(Color) onSelected) {
    final colors = [
      const Color(0xFFFFFFFF), const Color(0xFFF5F5F5), const Color(0xFFE0E0E0),
      const Color(0xFFB0B0B0), const Color(0xFF757575), const Color(0xFF424242),
      const Color(0xFF000000), const Color(0xFF6C63FF), const Color(0xFF2196F3),
      const Color(0xFF4CAF50), const Color(0xFFFF9800), const Color(0xFFF44336),
    ];
    return [
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: colors.map((c) {
          final isSelected = current.value == c.value;
          return GestureDetector(
            onTap: () => onSelected(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : (c.computeLuminance() > 0.5 ? Colors.grey[400]! : Colors.grey[700]!),
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: isSelected ? Icon(Icons.check, color: c.computeLuminance() > 0.5 ? Colors.black : Colors.white, size: 18) : null,
            ),
          );
        }).toList(),
      ),
    ];
  }

  List<Widget> _buildFontList(Color accent) {
    final fonts = ['Poppins', 'Roboto', 'Lato', 'Montserrat', 'Open Sans', 'Raleway', 'Nunito', 'Quicksand', 'Inter', 'DM Sans'];
    final s = widget.settings;
    return fonts.map((font) {
      final isSelected = s.fontName == font;
      return ListTile(
        leading: Icon(Icons.text_fields, color: isSelected ? accent : Colors.grey, size: 20),
        title: Text(font, style: GoogleFonts.getFont(font, fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        trailing: isSelected ? Icon(Icons.check_circle, color: accent) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? accent.withAlpha(20) : null,
        onTap: () => s.setFontName(font),
      );
    }).toList();
  }

  List<Widget> _buildFontSizeSlider(Color accent, Color? textColor) {
    final s = widget.settings;
    return [
      Center(
        child: Text(
          '${s.fontSize.toInt()}px',
          style: GoogleFonts.getFont(s.fontName, fontSize: 24, fontWeight: FontWeight.bold, color: accent),
        ),
      ),
      Slider(
        value: s.fontSize,
        min: 10,
        max: 24,
        divisions: 14,
        activeColor: accent,
        label: '${s.fontSize.toInt()}px',
        onChanged: (val) => s.setFontSize(val),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('10px', style: GoogleFonts.getFont(s.fontName, fontSize: 11, color: Colors.grey)),
          Text('24px', style: GoogleFonts.getFont(s.fontName, fontSize: 11, color: Colors.grey)),
        ],
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Aa Bb Cc 123',
          style: GoogleFonts.getFont(s.fontName, fontSize: s.fontSize, color: s.primaryTextColor),
        ),
      ),
    ];
  }

  Widget _buildPreview(Color cardColor, Color accent, Color? textColor) {
    final s = widget.settings;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withAlpha(50)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: accent),
              const SizedBox(width: 8),
              Text('Preview', style: GoogleFonts.getFont(s.fontName, fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Texto Principal - BrailleBridge',
            style: GoogleFonts.getFont(s.fontName, fontSize: s.fontSize, fontWeight: FontWeight.bold, color: s.primaryTextColor),
          ),
          const SizedBox(height: 4),
          Text(
            'Texto secundario - descricao do app',
            style: GoogleFonts.getFont(s.fontName, fontSize: s.fontSize - 2, color: s.secondaryTextColor),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(8)),
                child: Text('Botao', style: GoogleFonts.getFont(s.fontName, color: Colors.white, fontSize: s.fontSize - 2)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: s.secondaryAppColor, borderRadius: BorderRadius.circular(8)),
                child: Text('Secundario', style: GoogleFonts.getFont(s.fontName, color: Colors.white, fontSize: s.fontSize - 2)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
