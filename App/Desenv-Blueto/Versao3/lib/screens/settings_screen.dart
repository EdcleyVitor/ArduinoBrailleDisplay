import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final Function(Color) onColorChanged;
  final ThemeMode currentThemeMode;
  final Color currentSeedColor;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.currentThemeMode,
    required this.currentSeedColor,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _displaySpeed = 1500;

  final List<Color> _colorOptions = [
    const Color(0xFF1565C0),
    const Color(0xFF7B1FA2),
    const Color(0xFF00897B),
    const Color(0xFFE65100),
    const Color(0xFFC62828),
    const Color(0xFF2E7D32),
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121220) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Configurações',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ajustes do aplicativo',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildSection(
                      title: 'Personalização',
                      icon: Icons.palette,
                      primaryColor: primaryColor,
                      isDark: isDark,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tema',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildThemeButton(
                                    icon: Icons.light_mode,
                                    label: 'Claro',
                                    isSelected: widget.currentThemeMode == ThemeMode.light,
                                    onTap: () => widget.onThemeChanged(ThemeMode.light),
                                    primaryColor: primaryColor,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildThemeButton(
                                    icon: Icons.dark_mode,
                                    label: 'Escuro',
                                    isSelected: widget.currentThemeMode == ThemeMode.dark,
                                    onTap: () => widget.onThemeChanged(ThemeMode.dark),
                                    primaryColor: primaryColor,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildThemeButton(
                                    icon: Icons.brightness_auto,
                                    label: 'Sistema',
                                    isSelected: widget.currentThemeMode == ThemeMode.system,
                                    onTap: () => widget.onThemeChanged(ThemeMode.system),
                                    primaryColor: primaryColor,
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Cor do tema',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: _colorOptions.map((color) {
                                  final isSelected = widget.currentSeedColor.value == color.value;
                                  return GestureDetector(
                                    onTap: () => widget.onColorChanged(color),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? Colors.white : Colors.transparent,
                                          width: 3,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: color.withOpacity(0.4),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: isSelected
                                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                                          : null,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildSection(
                      title: 'Configurações do Dispositivo',
                      icon: Icons.devices,
                      primaryColor: primaryColor,
                      isDark: isDark,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Velocidade de exibição',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: isDark ? Colors.white : Colors.grey.shade700,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${(_displaySpeed / 1000).toStringAsFixed(1)}s',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: primaryColor,
                                  inactiveTrackColor: Colors.grey.shade200,
                                  thumbColor: primaryColor,
                                  overlayColor: primaryColor.withOpacity(0.1),
                                ),
                                child: Slider(
                                  value: _displaySpeed,
                                  min: 600,
                                  max: 3000,
                                  divisions: 12,
                                  onChanged: (value) {
                                    setState(() => _displaySpeed = value);
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Em breve disponível!',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        backgroundColor: Colors.orange,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.construction),
                                  label: Text(
                                    'Configurações avançadas',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade200,
                                    foregroundColor: Colors.grey.shade600,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildSection(
                      title: 'Informações',
                      icon: Icons.info_outline,
                      primaryColor: primaryColor,
                      isDark: isDark,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                label: 'Versão',
                                value: '2.0.0',
                                primaryColor: primaryColor,
                                isDark: isDark,
                              ),
                              _buildInfoRow(
                                label: 'Desenvolvido por',
                                value: 'Edcley Vitor',
                                primaryColor: primaryColor,
                                isDark: isDark,
                              ),
                              _buildInfoRow(
                                label: 'Orientador',
                                value: 'Josecley Fialho',
                                primaryColor: primaryColor,
                                isDark: isDark,
                              ),
                              _buildInfoRow(
                                label: 'Data',
                                value: 'Julho 2026',
                                primaryColor: primaryColor,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final uri = Uri.parse('https://github.com/EdcleyVitor/ArduinoBrailleDisplay');
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    }
                                  },
                                  icon: const Icon(Icons.code),
                                  label: Text(
                                    'Ver no GitHub',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color primaryColor,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Icon(icon, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          children.first,
        ],
      ),
    );
  }

  Widget _buildThemeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : (isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : (isDark ? Colors.grey : Colors.grey.shade600),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : (isDark ? Colors.grey : Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required Color primaryColor,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.grey : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
