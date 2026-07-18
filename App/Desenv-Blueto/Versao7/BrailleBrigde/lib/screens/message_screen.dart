import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/bluetooth_service.dart';
import '../utils/braille_converter.dart';
import '../database/database_helper.dart';

class MessageScreen extends StatefulWidget {
  final Color bgTop, bgMid, bgBot;
  const MessageScreen({super.key, required this.bgTop, required this.bgMid, required this.bgBot});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _controller = TextEditingController();
  final BrailleBluetoothService _bleService = BrailleBluetoothService();
  bool _isSending = false;
  String _selectedChar = '';
  List<int> _currentDots = [0, 0, 0, 0, 0, 0];
  bool _isConnected = false;
  StreamSubscription? _connectionSub;
  StreamSubscription? _statusSub;
  StreamSubscription? _notifySub;
  String _lastStatus = '';
  int _sendProgress = 0;
  int _sendTotal = 0;
  bool _waitingForDone = false;
  final List<String> _history = [];
  int _historyIndex = -1;

  @override
  void initState() {
    super.initState();
    _isConnected = _bleService.isConnected;
    _loadHistory();
    _loadSettings();
    _connectionSub = _bleService.connectionStream.listen((connected) {
      if (mounted) setState(() => _isConnected = connected);
    });
    _statusSub = _bleService.statusStream.listen((msg) {
      _lastStatus = msg;
    });
    _notifySub = _bleService.notifyStream.listen((msg) {
      if (msg == '@DONE' && _waitingForDone) {
        _waitingForDone = false;
      }
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
    _statusSub?.cancel();
    _notifySub?.cancel();
    _controller.dispose();
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

  Future<void> _sendText() async {
    final text = _controller.text.trim();
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

    await DatabaseHelper.instance.insertText(text);
    await _loadHistory();

    setState(() {
      _isSending = true;
      _sendTotal = text.length;
      _sendProgress = 0;
    });

    _historyIndex = -1;

    for (int i = 0; i < text.length; i++) {
      if (!mounted || !_isSending || !_isConnected) break;

      final char = text[i];
      final braille = BrailleConverter.charToBraille(char);
      setState(() {
        _sendProgress = i + 1;
        _selectedChar = char.toUpperCase();
        _currentDots = braille.split('').map((c) => int.parse(c)).toList();
      });

      await _bleService.sendChar(char);

      if (_bleService.notifyCharacteristic != null) {
        _waitingForDone = true;
        final completer = Completer<void>();
        Timer? timeout;

        final sub = _bleService.notifyStream.listen((msg) {
          if (msg == '@DONE' && !completer.isCompleted) {
            timeout?.cancel();
            completer.complete();
          }
        });

        timeout = Timer(Duration(milliseconds: _bleService.espSpeed + _bleService.espPause + 2000), () {
          if (!completer.isCompleted) {
            completer.complete();
          }
        });

        await completer.future;
        sub.cancel();
      } else {
        await Future.delayed(Duration(milliseconds: _bleService.espSpeed + _bleService.espPause + 350));
      }
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

      final hasError = _lastStatus.startsWith('ERRO');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(hasError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(hasError ? _lastStatus : 'Texto enviado!', style: GoogleFonts.poppins()),
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
                        Text('ON', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF4CAF50), fontWeight: FontWeight.w600)),
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
                          onChanged: _onTextChanged,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          enabled: !_isSending,
                          style: GoogleFonts.poppins(fontSize: 18),
                          decoration: InputDecoration(
                            hintText: 'Digite aqui...',
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
                                          Text('Enviar', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
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
