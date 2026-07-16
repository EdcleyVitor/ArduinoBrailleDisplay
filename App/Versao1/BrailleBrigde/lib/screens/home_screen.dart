import 'dart:async';
import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import '../utils/braille_converter.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BrailleBluetoothService _bleService = BrailleBluetoothService();
  final TextEditingController _textController = TextEditingController();

  bool _isConnected = false;
  String _deviceName = '';
  String _braillePreview = '';
  String _statusMessage = '';
  StreamSubscription? _connectionSub;
  StreamSubscription? _statusSub;

  @override
  void initState() {
    super.initState();
    _connectionSub = _bleService.connectionStream.listen((connected) {
      setState(() => _isConnected = connected);
    });
    _statusSub = _bleService.statusStream.listen((msg) {
      setState(() => _statusMessage = msg);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _connectionSub?.cancel();
    _statusSub?.cancel();
    _bleService.dispose();
    super.dispose();
  }

  void _updateBraillePreview(String text) {
    setState(() => _braillePreview = BrailleConverter.textToBraille(text));
  }

  Future<void> _openScan() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ScanScreen(bleService: _bleService),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _isConnected = true;
        _deviceName = _bleService.connectedDevice?.platformName ?? 'ESP32';
      });
    }
  }

  Future<void> _sendText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um texto para enviar')),
      );
      return;
    }

    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conecte a um dispositivo primeiro'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final sent = await _bleService.sendText(text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sent ? 'Texto enviado com sucesso!' : 'Erro ao enviar'),
          backgroundColor: sent ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Braille Bridge'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(
              _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
              color: _isConnected ? Colors.green : Colors.red,
            ),
            onPressed: _openScan,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      _isConnected
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth_disabled,
                      size: 48,
                      color: _isConnected ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isConnected ? 'Conectado: $_deviceName' : 'Desconectado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isConnected ? Colors.green : Colors.grey,
                      ),
                    ),
                    if (_statusMessage.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _statusMessage,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openScan,
                        icon: const Icon(Icons.bluetooth_searching),
                        label: Text(_isConnected ? 'Trocar dispositivo' : 'Conectar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Texto para Display Braille:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              onChanged: _updateBraillePreview,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Digite aqui...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Visualização Braille:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _braillePreview.isEmpty
                  ? const Text(
                      'A visualização aparecerá aqui',
                      style: TextStyle(color: Colors.grey),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _braillePreview,
                          style: const TextStyle(
                            fontSize: 24,
                            fontFamily: 'monospace',
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Padrão: $_braillePreview',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isConnected ? _sendText : null,
                icon: const Icon(Icons.send),
                label: const Text(
                  'ENVIAR PARA DISPLAY',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            if (!_isConnected) ...[
              const SizedBox(height: 8),
              const Text(
                'Conecte ao ESP32 para enviar',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
