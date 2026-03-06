import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_lock/core/providers/providers.dart';
import 'package:study_lock/screens/main_shell.dart';
import 'package:study_lock/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _dotsController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Glow pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Dots loading animation
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Navigate after delay — check if first launch
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateNext();
      }
    });
  }

  void _navigateNext() {
    // Use a simple ProviderScope lookup via context
    final container = ProviderScope.containerOf(context);
    final settings = container.read(settingsProvider);

    Widget nextScreen;
    if (settings.isFirstLaunch) {
      nextScreen = const OnboardingScreen();
    } else {
      nextScreen = const MainShell();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E21), Color(0xFF0D1333), Color(0xFF070B1A)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            // Lock icon with glow effect
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return _buildGlowingIcon(_pulseAnimation.value);
              },
            ),
            const SizedBox(height: 32),
            // App name
            const Text(
              'Study Lock',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              'Control your time',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(flex: 3),
            // Loading dots
            AnimatedBuilder(
              animation: _dotsController,
              builder: (context, child) {
                return _buildLoadingDots(_dotsController.value);
              },
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowingIcon(double pulseValue) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: 180 * pulseValue,
            height: 180 * pulseValue,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF1A3AFF).withValues(alpha: 0.15),
                  const Color(0xFF1A3AFF).withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                stops: const [0.3, 0.7, 1.0],
              ),
            ),
          ),
          // Middle glow ring
          Container(
            width: 140 * pulseValue,
            height: 140 * pulseValue,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF2244FF).withValues(alpha: 0.25),
                  const Color(0xFF2244FF).withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: const [0.4, 0.7, 1.0],
              ),
            ),
          ),
          // Inner glow circle
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A30E0).withValues(alpha: 0.3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A3AFF).withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          // Lock icon with clock
          SizedBox(
            width: 70,
            height: 70,
            child: CustomPaint(painter: _LockClockPainter()),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDots(double animValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final delay = index * 0.3;
        final adjustedValue = ((animValue - delay) % 1.0).clamp(0.0, 1.0);
        final opacity = (sin(adjustedValue * pi)).clamp(0.2, 1.0);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: opacity),
          ),
        );
      }),
    );
  }
}

class _LockClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2244FF)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Lock body (rounded rectangle)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - 2, cy + 6), width: 34, height: 28),
      const Radius.circular(5),
    );
    canvas.drawRRect(bodyRect, paint);

    // Lock shackle (arc)
    final shacklePaint = Paint()
      ..color = const Color(0xFF2244FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final shackleRect = Rect.fromCenter(
      center: Offset(cx - 2, cy - 5),
      width: 22,
      height: 24,
    );
    canvas.drawArc(shackleRect, pi, pi, false, shacklePaint);

    // Keyhole
    final keyholePaint = Paint()
      ..color = const Color(0xFF0A0E21)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx - 2, cy + 4), 3.5, keyholePaint);

    // Keyhole bottom line
    final keyholeLinePaint = Paint()
      ..color = const Color(0xFF0A0E21)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - 2, cy + 7),
      Offset(cx - 2, cy + 12),
      keyholeLinePaint,
    );

    // Small clock circle (bottom-right of lock)
    final clockCx = cx + 14;
    final clockCy = cy + 14;
    final clockRadius = 11.0;

    // Clock background
    final clockBgPaint = Paint()
      ..color = const Color(0xFF0A0E21)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(clockCx, clockCy), clockRadius + 2, clockBgPaint);

    // Clock outline
    final clockOutlinePaint = Paint()
      ..color = const Color(0xFF2244FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset(clockCx, clockCy), clockRadius, clockOutlinePaint);

    // Clock hands
    final handPaint = Paint()
      ..color = const Color(0xFF2244FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Hour hand (pointing up)
    canvas.drawLine(
      Offset(clockCx, clockCy),
      Offset(clockCx, clockCy - 6),
      handPaint,
    );

    // Minute hand (pointing right)
    canvas.drawLine(
      Offset(clockCx, clockCy),
      Offset(clockCx + 5, clockCy),
      handPaint,
    );

    // Clock center dot
    canvas.drawCircle(Offset(clockCx, clockCy), 1.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
