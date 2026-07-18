import 'dart:async';
import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'personalization_screen.dart';
import '../services/settings_manager.dart';

class SplashScreen extends StatefulWidget {
  final SettingsManager settings;
  const SplashScreen({super.key, required this.settings});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late List<AnimationController> _dotControllers;
  late List<Animation<double>> _dotScales;
  late List<Animation<double>> _dotGlows;
  late AnimationController _lineController;
  late AnimationController _textController;

  bool _dotsDone = false;
  bool _lineDone = false;

  @override
  void initState() {
    super.initState();

    _dotControllers = List.generate(6, (i) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    ));

    _dotScales = _dotControllers.map((c) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.elasticOut),
      ),
    ).toList();

    _dotGlows = _dotControllers.map((c) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeOut),
      ),
    ).toList();

    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 600));

    for (int i = 0; i < 6; i++) {
      if (!mounted) return;
      _dotControllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 150));
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _dotsDone = true);

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _lineController.forward();
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() => _lineDone = true);
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainScreen(settings: widget.settings),
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _dotControllers) {
      c.dispose();
    }
    _lineController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dotSpacing = screenWidth * 0.12;
    final centerX = screenWidth / 2;
    final centerY = MediaQuery.of(context).size.height * 0.42;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A2E), Color(0xFF6C63FF), Color(0xFF0A0A2E)],
          ),
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([..._dotControllers, _lineController, _textController]),
          builder: (context, child) {
            return Stack(
              children: [
                for (int i = 0; i < 6; i++)
                  _buildDot(i, centerX, centerY, dotSpacing),
                if (_dotsDone) _buildLine(centerX, centerY, dotSpacing),
                if (_lineDone) _buildTitle(centerX, centerY),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDot(int index, double centerX, double centerY, double spacing) {
    final col = index % 3;
    final row = index ~/ 3;

    double x, y;
    if (!_dotsDone) {
      x = centerX + (col - 1) * spacing;
      y = centerY + (row - 0.5) * 50;
    } else {
      x = centerX + (index - 2.5) * (spacing * 0.6);
      y = centerY;
    }

    final scale = _dotScales[index].value;
    final glow = _dotGlows[index].value;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      left: x - 14,
      top: y - 14,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withAlpha((glow * 180).toInt()),
                blurRadius: 15 * glow + 5,
                spreadRadius: 4 * glow,
              ),
              BoxShadow(
                color: const Color(0xFF6C63FF).withAlpha((glow * 120).toInt()),
                blurRadius: 25 * glow + 10,
                spreadRadius: 8 * glow,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLine(double centerX, double centerY, double spacing) {
    final lineWidth = spacing * 0.6 * 5 + 28;
    final progress = _lineController.value;

    return Positioned(
      left: centerX - lineWidth / 2,
      top: centerY - 1.5,
      child: Container(
        width: lineWidth * progress,
        height: 3,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white.withAlpha(50), Colors.white, Colors.white.withAlpha(50)],
          ),
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(color: Colors.white.withAlpha(60), blurRadius: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(double centerX, double centerY) {
    final opacity = _textController.value;
    final slide = (1 - _textController.value) * 20;

    return Positioned(
      left: 0,
      right: 0,
      top: centerY - 60 - slide,
      child: Opacity(
        opacity: opacity,
        child: Column(
          children: [
            Text(
              'BrailleBridge',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [Shadow(color: Colors.white54, blurRadius: 20)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
