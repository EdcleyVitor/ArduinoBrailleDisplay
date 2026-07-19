import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';

class SupportScreen extends StatefulWidget {
  final Color bgTop, bgMid, bgBot;
  const SupportScreen({super.key, required this.bgTop, required this.bgMid, required this.bgBot});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  List<Map<String, dynamic>> _errors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadErrors();
  }

  Future<void> _loadErrors() async {
    final errors = await DatabaseHelper.instance.getErrors();
    if (mounted) {
      setState(() {
        _errors = errors;
        _loading = false;
      });
    }
  }

  Future<void> _exportTxt() async {
    try {
      final path = await DatabaseHelper.instance.exportErrorsTxt();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arquivo salvo: $path', style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(
              label: 'Compartilhar',
              textColor: Colors.white,
              onPressed: () => Share.shareXFiles([XFile(path)], text: 'Log de erros BrailleBridge'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _clearErrors() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Limpar erros?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Isso vai apagar todos os logs de erro.', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancelar', style: GoogleFonts.poppins())),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Limpar', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.clearErrors();
      await _loadErrors();
    }
  }

  String _formatTimestamp(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suporte / Erros', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Exportar .txt',
            onPressed: _exportTxt,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Limpar',
            onPressed: _errors.isEmpty ? null : _clearErrors,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [widget.bgTop, widget.bgMid, widget.bgBot],
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _errors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: Colors.white.withAlpha(100)),
                        const SizedBox(height: 16),
                        Text('Nenhum erro registrado', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Tudo funcionando normalmente!', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13)),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.white70, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${_errors.length} erro(s) registrado(s). Toque no icone de download para exportar.',
                                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _errors.length,
                          itemBuilder: (context, index) {
                            final error = _errors[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.withAlpha(50)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          error['screen'] ?? 'Desconhecido',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _formatTimestamp(error['timestamp'] as int),
                                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    error['message'] ?? '',
                                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
                                  ),
                                  if (error['details'] != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      error['details'],
                                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
