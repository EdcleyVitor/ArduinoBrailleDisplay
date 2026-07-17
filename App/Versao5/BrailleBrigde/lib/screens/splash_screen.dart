import 'package:flutter/material.dart';
import 'dart:async';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _dotsController;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;

  final List<bool> _dotStates = [false, false, false, false, false, false];
  Timer? _dotTimer;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoController.forward();

    int dotIndex = 0;
    _dotTimer = Timer.periodic(const Duration(milliseconds: 180), (timer) {
      if (!mounted) return;
      setState(() {
        _dotStates[dotIndex % 6] = !_dotStates[dotIndex % 6];
        dotIndex++;
      });
    });

    Timer(const Duration(milliseconds: 2500), () {
      _dotTimer?.cancel();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                MainScreen(
              onThemeChanged: (mode) {},
              onColorChanged: (color) {},
              currentThemeMode: ThemeMode.system,
              currentSeedColor: const Color(0xFF6C63FF),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    _logoController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C63FF), Color(0xFF3F3D99), Color(0xFF1A1A2E)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withAlpha(80),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              'BrailleBridge',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: Colors.black.withAlpha(80),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Conectando mundos pelo Braille',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withAlpha(180),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 60),
            _buildBrailleDots(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrailleDots() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildDot(0),
              const SizedBox(width: 24),
              _buildDot(3),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDot(1),
              const SizedBox(width: 24),
              _buildDot(4),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDot(2),
              const SizedBox(width: 24),
              _buildDot(5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _dotStates[index] ? Colors.white : Colors.white.withAlpha(30),
        boxShadow: _dotStates[index]
            ? [
                BoxShadow(
                  color: Colors.white.withAlpha(100),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
    );
  }
}
