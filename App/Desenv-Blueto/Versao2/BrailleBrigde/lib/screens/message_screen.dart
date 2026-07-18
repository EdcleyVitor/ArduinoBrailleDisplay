import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _controller = TextEditingController();
  String _preview = '';
  bool _isSending = false;

  // Braille alphabet mapping
  static const Map<String, List<int>> _brailleMap = {
    'a': [1, 0, 0, 0, 0, 0],
    'b': [1, 1, 0, 0, 0, 0],
    'c': [1, 0, 0, 1, 0, 0],
    'd': [1, 0, 0, 1, 1, 0],
    'e': [1, 0, 0, 0, 1, 0],
    'f': [1, 1, 0, 1, 0, 0],
    'g': [1, 1, 0, 1, 1, 0],
    'h': [1, 1, 0, 0, 1, 0],
    'i': [0, 1, 0, 1, 0, 0],
    'j': [0, 1, 0, 1, 1, 0],
    'k': [1, 0, 1, 0, 0, 0],
    'l': [1, 1, 1, 0, 0, 0],
    'm': [1, 0, 1, 1, 0, 0],
    'n': [1, 0, 1, 1, 1, 0],
    'o': [1, 0, 1, 0, 1, 0],
    'p': [1, 1, 1, 1, 0, 0],
    'q': [1, 1, 1, 1, 1, 0],
    'r': [1, 1, 1, 0, 1, 0],
    's': [0, 1, 1, 1, 0, 0],
    't': [0, 1, 1, 1, 1, 0],
    'u': [1, 0, 1, 0, 0, 1],
    'v': [1, 1, 1, 0, 0, 1],
    'w': [0, 1, 0, 1, 1, 1],
    'x': [1, 0, 1, 1, 0, 1],
    'y': [1, 0, 1, 1, 1, 1],
    'z': [1, 0, 1, 0, 1, 1],
  };

  void _updatePreview() {
    setState(() {
      _preview = _controller.text.toLowerCase();
    });
  }

  void _sendText() async {
    if (_controller.text.isEmpty) return;
    setState(() => _isSending = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isSending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Texto enviado: ${_controller.text}'),
        backgroundColor: const Color(0xFF22C55E),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updatePreview);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                  Icon(Icons.send, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'Enviar Mensagem',
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
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Text Input
                      TextField(
                        controller: _controller,
                        maxLines: 3,
                        style: GoogleFonts.poppins(fontSize: 18),
                        decoration: InputDecoration(
                          labelText: 'Digite o texto',
                          labelStyle: GoogleFonts.poppins(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2563EB)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Braille Preview
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pré-visualização Braille:',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _preview.isNotEmpty ? _preview.toUpperCase() : '...',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Send Button
                      ElevatedButton(
                        onPressed: _isSending ? null : _sendText,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: _isSending
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Enviar para Display',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
