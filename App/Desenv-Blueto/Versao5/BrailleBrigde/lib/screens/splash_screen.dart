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
  late AnimationController _popController;
  late AnimationController _brandController;
  late Animation<double> _popScale;
  late Animation<double> _popOpacity;
  late Animation<double> _brandOpacity;
  late Animation<Offset> _brandSlide;

  final List<double> _dotOpacities = [0, 0, 0, 0, 0, 0];
  final List<double> _dotScales = [0.4, 0.4, 0.4, 0.4, 0.4, 0.4];
  final List<bool> _dotBlink = [false, false, false, false, false, false];
  final List<bool> _dotPulse = [false, false, false, false, false, false];
  Timer? _animTimer;

  @override
  void initState() {
    super.initState();

    _popController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _popScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _popController, curve: Curves.elasticOut),
    );
    _popOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _popController, curve: Curves.easeOut),
    );

    _brandController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _brandOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _brandController, curve: Curves.easeOut),
    );
    _brandSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _brandController, curve: Curves.easeOutCubic),
    );

    _runAnimation();
  }

  void _runAnimation() async {
    _popController.forward();

    await Future.delayed(const Duration(milliseconds: 800));

    for (int i = 0; i < 6; i++) {
      if (!mounted) return;
      final reverseIndex = 5 - i;
      setState(() {
        _dotBlink[reverseIndex] = true;
      });
      await Future.delayed(const Duration(milliseconds: 140));
    }

    await Future.delayed(const Duration(milliseconds: 1400));

    for (int i = 0; i < 6; i++) {
      if (!mounted) return;
      setState(() {
        _dotBlink[i] = false;
        _dotPulse[i] = true;
      });
      await Future.delayed(const Duration(milliseconds: 120));
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      _brandController.forward();
    }

    await Future.delayed(const Duration(milliseconds: 2500));

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
  }

  @override
  void dispose() {
    _animTimer?.cancel();
    _popController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF030712),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.1),
              radius: 0.8,
              colors: [
                const Color(0xFF0F172A),
                const Color(0xFF030712),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _popController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _popOpacity.value,
                    child: Transform.scale(
                      scale: _popScale.value,
                      child: _buildBrailleDots(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 50),
              SlideTransition(
                position: _brandSlide,
                child: FadeTransition(
                  opacity: _brandOpacity,
                  child: Column(
                    children: [
                      _buildSignalIcon(),
                      const SizedBox(height: 20),
                      _buildBrandText(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignalIcon() {
    return AnimatedBuilder(
      animation: _brandController,
      builder: (context, child) {
        final glow = 5.0 + (_brandController.value * 20.0);
        return Icon(
          Icons.wifi_rounded,
          size: 54,
          color: const Color(0xFF00E5FF),
          shadows: [
            Shadow(
              color: const Color(0xFF00E5FF).withAlpha((glow * 4).toInt().clamp(0, 255)),
              blurRadius: glow,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBrandText() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 36,
          letterSpacing: 3,
        ),
        children: [
          TextSpan(
            text: 'Braille',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: const Color(0xFF00E5FF).withAlpha(120),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          TextSpan(
            text: 'Bridge',
            style: TextStyle(
              fontWeight: FontWeight.w200,
              color: Colors.white.withAlpha(230),
              shadows: [
                Shadow(
                  color: const Color(0xFF00E5FF).withAlpha(120),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrailleDots() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1F2937),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildDot(0),
              const SizedBox(width: 20),
              _buildDot(3),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildDot(1),
              const SizedBox(width: 20),
              _buildDot(4),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildDot(2),
              const SizedBox(width: 20),
              _buildDot(5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isBlink = _dotBlink[index];
    final isPulse = _dotPulse[index];

    Color dotColor;
    List<BoxShadow> shadows;

    if (isPulse) {
      dotColor = const Color(0xFF00E5FF);
      shadows = [
        BoxShadow(
          color: const Color(0xFF00E5FF).withAlpha(150),
          blurRadius: 18,
          spreadRadius: 4,
        ),
        BoxShadow(
          color: const Color(0xFF00FFFF).withAlpha(80),
          blurRadius: 40,
          spreadRadius: 8,
        ),
      ];
    } else if (isBlink) {
      dotColor = const Color(0xFF00FFFF);
      shadows = [
        BoxShadow(
          color: const Color(0xFF00E5FF).withAlpha(180),
          blurRadius: 16,
          spreadRadius: 3,
        ),
      ];
    } else {
      dotColor = const Color(0xFF111827);
      shadows = [
        BoxShadow(
          color: Colors.black.withAlpha(100),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withAlpha(80),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: isPulse ? 1500 : 300),
      curve: isPulse ? Curves.easeInOut : Curves.easeOut,
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dotColor,
        border: Border.all(
          color: isPulse
              ? const Color(0xFF00FFFF)
              : isBlink
                  ? Colors.white
                  : const Color(0xFF1F2937),
          width: 2,
        ),
        boxShadow: shadows,
      ),
      child: isPulse
          ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withAlpha(60),
                    Colors.transparent,
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
