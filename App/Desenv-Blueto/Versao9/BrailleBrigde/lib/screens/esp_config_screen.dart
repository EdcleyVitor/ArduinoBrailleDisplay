import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/bluetooth_service.dart';
import '../services/settings_manager.dart';
import '../database/database_helper.dart';



class EspConfigScreen extends StatefulWidget {
  final SettingsManager settings;
  final Color bgTop, bgMid, bgBot;
  const EspConfigScreen({super.key, required this.settings, required this.bgTop, required this.bgMid, required this.bgBot});

  @override
  State<EspConfigScreen> createState() => _EspConfigScreenState();
}

class _EspConfigScreenState extends State<EspConfigScreen> {
  final BrailleBluetoothService _bleService = BrailleBluetoothService();
  late double _speed;
  late double _pause;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _speed = _bleService.espSpeed.toDouble();
    _pause = _bleService.espPause.toDouble();
    _isConnected = _bleService.isConnected;
    _bleService.connectionStream.listen((c) {
      if (mounted) setState(() => _isConnected = c);
    });
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final savedSpeed = await DatabaseHelper.instance.getSettingInt('espSpeed', defaultValue: 1500);
    final savedPause = await DatabaseHelper.instance.getSettingInt('espPause', defaultValue: 500);
    if (mounted) {
      setState(() {
        _speed = savedSpeed.toDouble();
        _pause = savedPause.toDouble();
      });
      _bleService.setEspSpeed(savedSpeed);
      _bleService.setEspPause(savedPause);
    }
  }

  String _speedLabel(double val) {
    if (val <= 700) return 'Muito rapido';
    if (val <= 1200) return 'Rapido';
    if (val <= 2000) return 'Normal';
    if (val <= 3500) return 'Lento';
    return 'Muito lento';
  }

  String _pauseLabel(double val) {
    if (val <= 200) return 'Minima';
    if (val <= 400) return 'Curta';
    if (val <= 800) return 'Normal';
    if (val <= 1500) return 'Longa';
    return 'Muito longa';
  }

  void _sendSpeed() async {
    final ms = _speed.toInt();
    _bleService.setEspSpeed(ms);
    await DatabaseHelper.instance.saveSettingInt('espSpeed', ms);
    await _bleService.sendConfig('SPEED', ms.toString());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Velocidade definida: ${ms}ms', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _sendPause() async {
    final ms = _pause.toInt();
    _bleService.setEspPause(ms);
    await DatabaseHelper.instance.saveSettingInt('espPause', ms);
    await _bleService.sendConfig('PAUSE', ms.toString());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pausa definida: ${ms}ms', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _sendTest(String test) async {
    await _bleService.sendConfig('TEST', test);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Teste "$test" enviado ao ESP32', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFF6C63FF),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _stopTest() async {
    await _bleService.sendConfig('TEST', 'STOP');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Teste parado', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Config ESP32', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [widget.bgTop, widget.bgMid, widget.bgBot],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSpeedCard(),
            const SizedBox(height: 16),
            _buildPauseCard(),
            const SizedBox(height: 16),
            _buildTestCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha(230),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed, color: Color(0xFF6C63FF)),
              const SizedBox(width: 10),
              Text('Velocidade de Exibicao', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Tempo que cada letra fica acesa no display', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '${(_speed / 1000).toStringAsFixed(1)}s',
              style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF6C63FF)),
            ),
          ),
          Center(
            child: Text(_speedLabel(_speed), style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
          ),
          Slider(
            value: _speed,
            min: 500,
            max: 5000,
            divisions: 18,
            activeColor: const Color(0xFF6C63FF),
            label: '${(_speed / 1000).toStringAsFixed(1)}s',
            onChanged: (val) => setState(() => _speed = val),
            onChangeEnd: (_) => _sendSpeed(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0.5s', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              Text('5.0s', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPauseCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha(230),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pause_circle_outline, color: Color(0xFF6C63FF)),
              const SizedBox(width: 10),
              Text('Pausa entre Letras', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Tempo de apagado entre uma letra e outra', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '${_pause.toInt()}ms',
              style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: const Color(0xFF6C63FF)),
            ),
          ),
          Center(
            child: Text(_pauseLabel(_pause), style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
          ),
          Slider(
            value: _pause,
            min: 100,
            max: 3000,
            divisions: 29,
            activeColor: const Color(0xFF6C63FF),
            label: '${_pause.toInt()}ms',
            onChanged: (val) => setState(() => _pause = val),
            onChangeEnd: (_) => _sendPause(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('100ms', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              Text('3000ms', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha(230),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science, color: Color(0xFF6C63FF)),
              const SizedBox(width: 10),
              Text('Modo Teste', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Teste os LEDs do ESP32', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          if (_isConnected) ...[
            _buildTestButton(
              'Teste Onda',
              'Efeito onda horizontal nos LEDs',
              Icons.waves,
              () => _sendTest('WAVE'),
            ),
            const SizedBox(height: 12),
            _buildTestButton(
              'Teste Individual',
              'Cada LED acende separadamente',
              Icons.touch_app,
              () => _sendTest('PINS'),
            ),
            const SizedBox(height: 12),
            _buildTestButton(
              'Parar Teste',
              'Desliga todos os LEDs',
              Icons.stop_circle,
              () => _stopTest(),
              color: Colors.red,
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bluetooth_disabled, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Conecte-se ao ESP32 para usar os testes', style: GoogleFonts.poppins())),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTestButton(String label, String desc, IconData icon, VoidCallback onTap, {Color? color}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            Text(desc, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}
