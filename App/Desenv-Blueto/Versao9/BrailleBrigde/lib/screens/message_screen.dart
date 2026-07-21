import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/bluetooth_service.dart';
import '../services/settings_manager.dart';
import '../utils/braille_converter.dart';
import '../database/database_helper.dart';

class MessageScreen extends StatefulWidget {
  final Color bgTop, bgMid, bgBot;
  final SettingsManager settings;
  const MessageScreen({super.key, required this.bgTop, required this.bgMid, required this.bgBot, required this.settings});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final BrailleBluetoothService _bleService = BrailleBluetoothService();
  bool _isSending = false;
  String _selectedChar = '';
  List<int> _currentDots = [0, 0, 0, 0, 0, 0];
  bool _isConnected = false;
  int _deviceCount = 0;
  List<ConnectedDevice> _devices = [];
  ConnectedDevice? _selectedDevice;
  StreamSubscription? _connectionSub;
  StreamSubscription? _devicesSub;
  StreamSubscription? _statusSub;
  String _lastStatus = '';
  int _sendProgress = 0;
  int _sendTotal = 0;
  final List<String> _history = [];
  int _historyIndex = -1;
  bool _isNumericMode = false;
  bool _sendToAll = true;

  @override
  void initState() {
    super.initState();
    _isConnected = _bleService.isConnected;
    _deviceCount = _bleService.connectedCount;
    _devices = _bleService.connectedDevices;
    if (_devices.isNotEmpty) {
      _selectedDevice = _devices.firstWhere((d) => d.isReady, orElse: () => _devices.first);
    }
    _loadHistory();
    _loadSettings();
    _connectionSub = _bleService.connectionStream.listen((connected) {
      if (mounted) setState(() {
        _isConnected = connected;
        _deviceCount = _bleService.connectedCount;
        _devices = _bleService.connectedDevices;
        if (_selectedDevice != null && !_devices.any((d) => d.id == _selectedDevice!.id && d.isReady)) {
          _selectedDevice = _devices.isNotEmpty ? _devices.firstWhere((d) => d.isReady, orElse: () => _devices.first) : null;
        }
      });
    });
    _devicesSub = _bleService.devicesStream.listen((devices) {
      if (mounted) setState(() {
        _devices = devices;
        _deviceCount = devices.where((d) => d.isReady).length;
        _isConnected = _bleService.isConnected;
        if (_selectedDevice != null && !devices.any((d) => d.id == _selectedDevice!.id && d.isReady)) {
          _selectedDevice = devices.isNotEmpty ? devices.firstWhere((d) => d.isReady, orElse: () => devices.first) : null;
        }
      });
    });
    _statusSub = _bleService.statusStream.listen((msg) {
      if (mounted) setState(() => _lastStatus = msg);
    });
  }

  Future<void> _loadHistory() async {
    final texts = await DatabaseHelper.instance.getLastTexts(5);
    if (mounted) {
      setState(() {
        _history.clear();
        _history.addAll(texts);
      });
    }
  }

  Future<void> _loadSettings() async {
    final speed = await DatabaseHelper.instance.getSettingInt('espSpeed', defaultValue: 1500);
    final pause = await DatabaseHelper.instance.getSettingInt('espPause', defaultValue: 500);
    _bleService.setEspSpeed(speed);
    _bleService.setEspPause(pause);
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    _devicesSub?.cancel();
    _statusSub?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    if (text.isEmpty) {
      setState(() {
        _selectedChar = '';
        _currentDots = [0, 0, 0, 0, 0, 0];
      });
      return;
    }
    final lastChar = text.substring(text.length - 1);
    final braille = BrailleConverter.charToBraille(lastChar);
    setState(() {
      _selectedChar = lastChar.toUpperCase();
      _currentDots = braille.split('').map((c) => int.parse(c)).toList();
    });
  }

  void _switchMode(bool numeric) {
    setState(() {
      _isNumericMode = numeric;
    });
    _focusNode.unfocus();
    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  Future<void> _sendText() async {
    var text = _controller.text.trim();
    if (text.isEmpty) return;
    if (!_isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conecte-se ao ESP32 primeiro!', style: GoogleFonts.poppins()),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    final s = widget.settings;
    text = BrailleConverter.filterText(
      text,
      ignorarAcentos: s.ignorarAcentos,
      caracteresEspeciais: s.caracteresEspeciais,
    );

    if (text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Texto vazio apos filtros!', style: GoogleFonts.poppins()),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    await DatabaseHelper.instance.insertText(text);
    await _loadHistory();

    setState(() {
      _isSending = true;
      _sendTotal = text.length;
      _sendProgress = 0;
    });

    _historyIndex = -1;

    final targets = _sendToAll
        ? _devices.where((d) => d.isReady).toList()
        : (_selectedDevice != null && _selectedDevice!.isReady ? [_selectedDevice!] : _devices.where((d) => d.isReady).toList());

    for (var t in targets) {
      await _bleService.sendConfig('SPEED', _bleService.espSpeed.toString(), target: t.device);
      await _bleService.sendConfig('PAUSE', _bleService.espPause.toString(), target: t.device);
    }

    for (int i = 0; i < text.length; i++) {
      if (!mounted || !_isSending || !_isConnected) break;

      final char = text[i];
      final braille = BrailleConverter.charToBraille(char);
      setState(() {
        _sendProgress = i + 1;
        _selectedChar = char.toUpperCase();
        _currentDots = braille.split('').map((c) => int.parse(c)).toList();
      });

      await Future.wait(targets.map((t) => _bleService.sendChar(braille, target: t.device)));
      await Future.delayed(Duration(milliseconds: _bleService.espSpeed + _bleService.espPause + 500));
    }

    if (mounted) {
      setState(() {
        _isSending = false;
        _sendProgress = 0;
        _sendTotal = 0;
        _selectedChar = '';
        _currentDots = [0, 0, 0, 0, 0, 0];
        _controller.clear();
      });

      final targetCount = targets.length;
      final hasError = _lastStatus.startsWith('ERRO');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(hasError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasError
                      ? _lastStatus
                      : targetCount > 1
                          ? 'Texto enviado para $targetCount dispositivos!'
                          : 'Texto enviado!',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
          backgroundColor: hasError ? Colors.red : const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: hasError ? 4 : 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _historyUp() {
    if (_history.isEmpty) return;
    _historyIndex++;
    if (_historyIndex >= _history.length) _historyIndex = _history.length - 1;
    _controller.text = _history[_historyIndex];
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    _onTextChanged(_controller.text);
  }

  void _historyDown() {
    if (_history.isEmpty) return;
    _historyIndex--;
    if (_historyIndex < 0) {
      _historyIndex = -1;
      _controller.clear();
      _onTextChanged('');
    } else {
      _controller.text = _history[_historyIndex];
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
      _onTextChanged(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.settings;
    final showModeSelector = s.separadorAlfabetoNumero;
    final readyDevices = _devices.where((d) => d.isReady).toList();

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
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Text('Enviar', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Spacer(),
                  if (_isConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFF4CAF50).withAlpha(30), borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF4CAF50))),
                        const SizedBox(width: 6),
                        Text(
                          _deviceCount > 1 ? '$_deviceCount ON' : 'ON',
                          style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF4CAF50), fontWeight: FontWeight.w600),
                        ),
                      ]),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.orange.withAlpha(30), borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orange)),
                        const SizedBox(width: 6),
                        Text('OFF', style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                ],
              ),
            ),
            if (_isConnected && readyDevices.length > 1) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildDeviceSelector(readyDevices),
              ),
            ],
            if (showModeSelector) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _switchMode(false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isNumericMode ? const Color(0xFF6C63FF) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.keyboard, size: 18, color: !_isNumericMode ? Colors.white : Colors.grey),
                                const SizedBox(width: 6),
                                Text('Texto', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: !_isNumericMode ? Colors.white : Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _switchMode(true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isNumericMode ? const Color(0xFF6C63FF) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.numbers, size: 18, color: _isNumericMode ? Colors.white : Colors.grey),
                                const SizedBox(width: 6),
                                Text('123', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: _isNumericMode ? Colors.white : Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildBrailleLetter(),
                          const SizedBox(width: 20),
                          Expanded(child: _buildBrailleCell()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_isSending && _sendTotal > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Enviando...', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6C63FF))),
                                  Text('$_sendProgress/$_sendTotal', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6C63FF))),
                                ],
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: _sendProgress / _sendTotal,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
                                borderRadius: BorderRadius.circular(4),
                                minHeight: 6,
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: _onTextChanged,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          enabled: !_isSending,
                          keyboardType: _isNumericMode
                              ? const TextInputType.numberWithOptions(signed: true, decimal: true)
                              : TextInputType.text,
                          inputFormatters: _isNumericMode
                              ? [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-x÷X/\s]')),
                                  TextInputFormatter.withFunction((oldValue, newValue) {
                                    return newValue;
                                  }),
                                ]
                              : null,
                          textCapitalization: _isNumericMode ? TextCapitalization.none : TextCapitalization.sentences,
                          style: GoogleFonts.poppins(fontSize: 18),
                          decoration: InputDecoration(
                            hintText: _isNumericMode ? 'Numeros e operacoes...' : 'Digite aqui...',
                            hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[300]!)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[300]!)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2)),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: _isSending ? null : _historyUp,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF6C63FF),
                                  side: const BorderSide(color: Color(0xFF6C63FF)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Icon(Icons.keyboard_arrow_up, size: 28),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: _isSending ? null : _historyDown,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF6C63FF),
                                  side: const BorderSide(color: Color(0xFF6C63FF)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Icon(Icons.keyboard_arrow_down, size: 28),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isSending ? null : _sendText,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isConnected ? const Color(0xFF6C63FF) : Colors.grey,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 4,
                                ),
                                child: _isSending
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.send_rounded, size: 18),
                                          const SizedBox(width: 6),
                                          Text(
                                            _sendToAll && readyDevices.length > 1
                                                ? 'Enviar p/ Todos'
                                                : 'Enviar',
                                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceSelector(List<ConnectedDevice> readyDevices) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.devices, size: 18, color: Theme.of(context).colorScheme.onSurface.withAlpha(150)),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<ConnectedDevice?>(
              value: _sendToAll ? null : _selectedDevice,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: Theme.of(context).colorScheme.surface,
              hint: Text(
                'Todos (${readyDevices.length})',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              items: [
                if (readyDevices.length > 1)
                  DropdownMenuItem<ConnectedDevice?>(
                    value: null,
                    child: Row(
                      children: [
                        const Icon(Icons.groups, size: 16, color: Color(0xFF6C63FF)),
                        const SizedBox(width: 8),
                        Text('Todos (${readyDevices.length})', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ...readyDevices.map((cd) => DropdownMenuItem<ConnectedDevice?>(
                  value: cd,
                  child: Row(
                    children: [
                      const Icon(Icons.bluetooth, size: 16, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(cd.name, style: GoogleFonts.poppins(), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _sendToAll = value == null;
                  _selectedDevice = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrailleLetter() {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _selectedChar.isNotEmpty ? const Color(0xFF6C63FF) : Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
            boxShadow: _selectedChar.isNotEmpty ? [BoxShadow(color: const Color(0xFF6C63FF).withAlpha(60), blurRadius: 12)] : [],
          ),
          child: Center(
            child: Text(
              _selectedChar.isNotEmpty ? _selectedChar : '-',
              style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _currentDots.where((d) => d == 1).length > 0 ? '${_currentDots.where((d) => d == 1).length} pts' : 'Aguardando',
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildBrailleCell() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildDot(0), const SizedBox(width: 20), _buildDot(3)]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildDot(1), const SizedBox(width: 20), _buildDot(4)]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildDot(2), const SizedBox(width: 20), _buildDot(5)]),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = _currentDots[index] == 1;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF6C63FF) : Theme.of(context).colorScheme.outlineVariant.withAlpha(60),
        boxShadow: isActive ? [BoxShadow(color: const Color(0xFF6C63FF).withAlpha(80), blurRadius: 8, spreadRadius: 2)] : [],
      ),
      child: isActive ? const Icon(Icons.circle, size: 10, color: Colors.white) : null,
    );
  }
}
