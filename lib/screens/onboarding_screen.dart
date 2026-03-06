import 'dart:math';
import 'package:flutter/material.dart';
import 'package:study_lock/screens/permission_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      topTitle: 'Study Lock',
      topTitleAlignment: Alignment.centerLeft,
      title: 'Take Back Your\nTime',
      subtitle: 'Block distracting apps and focus on what\nmatters.',
      illustrationType: IllustrationType.phoneWithApps,
      buttonText: 'Next',
      showArrow: false,
    ),
    OnboardingPageData(
      topTitle: 'Set Long Lock Timers',
      topTitleAlignment: Alignment.center,
      title: 'Lock apps for hours so\nyou cannot open them.',
      subtitle:
          'Set a customized duration to\ncompletely block access to\ndistracting applications.',
      illustrationType: IllustrationType.stopwatch,
      buttonText: 'Next',
      showArrow: true,
      showTimer: true,
    ),
    OnboardingPageData(
      topTitle: '',
      topTitleAlignment: Alignment.center,
      title: 'Unlock When Time Ends',
      subtitle: 'Apps automatically unlock when\nthe timer ends.',
      illustrationType: IllustrationType.clockAndLock,
      buttonText: 'Get Started',
      showArrow: true,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _onGetStarted();
    }
  }

  void _onGetStarted() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PermissionScreen()),
    );
  }

  void _onSkip() {
    _onGetStarted();
  }

  @override
  void dispose() {
    _pageController.dispose();
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
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with title and skip
              _buildTopBar(),
              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              // Page indicator
              _buildPageIndicator(),
              const SizedBox(height: 24),
              // Bottom button
              _buildBottomButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final page = _pages[_currentPage];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          if (page.topTitleAlignment == Alignment.centerLeft)
            Text(
              page.topTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            const SizedBox(),
          if (page.topTitleAlignment == Alignment.center) ...[
            const Spacer(),
            Text(
              page.topTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: _onSkip,
            child: Text(
              'Skip',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPageData page) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Illustration
            _buildIllustration(page.illustrationType),
            const SizedBox(height: 32),
            // Title
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            // Subtitle
            Text(
              page.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 15,
                height: 1.5,
              ),
            ),
            // Timer display for page 2
            if (page.showTimer) ...[
              const SizedBox(height: 32),
              _buildTimerDisplay(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(IllustrationType type) {
    switch (type) {
      case IllustrationType.phoneWithApps:
        return const _PhoneWithAppsIllustration();
      case IllustrationType.stopwatch:
        return const _StopwatchIllustration();
      case IllustrationType.clockAndLock:
        return const _ClockAndLockIllustration();
    }
  }

  Widget _buildTimerDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimerBox('20', 'HOURS'),
        const SizedBox(width: 16),
        _buildTimerBox('00', 'MINUTES'),
        const SizedBox(width: 16),
        _buildTimerBox('00', 'SECONDS'),
      ],
    );
  }

  Widget _buildTimerBox(String value, String label) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF141832),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? const Color(0xFF2244FF)
                : Colors.white.withValues(alpha: 0.25),
          ),
        );
      }),
    );
  }

  Widget _buildBottomButton() {
    final page = _pages[_currentPage];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2244FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(page.buttonText),
              if (page.showArrow) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// --- Data Model ---

enum IllustrationType { phoneWithApps, stopwatch, clockAndLock }

class OnboardingPageData {
  final String topTitle;
  final Alignment topTitleAlignment;
  final String title;
  final String subtitle;
  final IllustrationType illustrationType;
  final String buttonText;
  final bool showArrow;
  final bool showTimer;

  const OnboardingPageData({
    required this.topTitle,
    required this.topTitleAlignment,
    required this.title,
    required this.subtitle,
    required this.illustrationType,
    required this.buttonText,
    this.showArrow = false,
    this.showTimer = false,
  });
}

// --- Page 1 Illustration: Phone with floating app icons ---

class _PhoneWithAppsIllustration extends StatelessWidget {
  const _PhoneWithAppsIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3A4A5C), Color(0xFF2A3642)],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Wooden surface at the bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 80,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF8B7355), Color(0xFF6B5740)],
                    ),
                  ),
                ),
              ),
              // Phone body
              Positioned(
                bottom: 40,
                child: Container(
                  width: 220,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF555555),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              // Floating app icons
              ..._buildFloatingIcons(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFloatingIcons() {
    final icons = [
      _AppIcon(Icons.facebook, const Color(0xFF1877F2), 36, 80, 140),
      _AppIcon(Icons.play_circle_fill, const Color(0xFFFF0000), 30, 135, 115),
      _AppIcon(Icons.chat_bubble, const Color(0xFF25D366), 26, 175, 155),
      _AppIcon(Icons.camera_alt, const Color(0xFFE4405F), 28, 50, 175),
      _AppIcon(Icons.alternate_email, const Color(0xFF1DA1F2), 24, 75, 220),
      _AppIcon(Icons.discord, const Color(0xFF5865F2), 28, 180, 185),
      _AppIcon(Icons.email, const Color(0xFFEA4335), 22, 120, 210),
      _AppIcon(Icons.snapchat, const Color(0xFFFFFC00), 26, 145, 250),
      _AppIcon(Icons.music_note, const Color(0xFF1DB954), 22, 40, 130),
      _AppIcon(Icons.location_on, const Color(0xFFFF5722), 18, 165, 280),
      _AppIcon(Icons.shopping_bag, const Color(0xFF4CAF50), 18, 55, 270),
      // Small dots
      _AppIcon(Icons.circle, const Color(0xFF2196F3), 8, 100, 100),
      _AppIcon(Icons.circle, const Color(0xFFFF5722), 8, 200, 130),
      _AppIcon(Icons.circle, const Color(0xFF4CAF50), 8, 30, 200),
      _AppIcon(Icons.circle, const Color(0xFF9C27B0), 8, 210, 240),
    ];

    return icons
        .map(
          (icon) => Positioned(
            left: icon.x,
            top: icon.y,
            child: Container(
              width: icon.size + 10,
              height: icon.size + 10,
              decoration: BoxDecoration(
                color: icon.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: icon.color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                icon.icon,
                color: Colors.white,
                size: icon.size * 0.6,
              ),
            ),
          ),
        )
        .toList();
  }
}

class _AppIcon {
  final IconData icon;
  final Color color;
  final double size;
  final double x;
  final double y;

  const _AppIcon(this.icon, this.color, this.size, this.x, this.y);
}

// --- Page 2 Illustration: Stopwatch dial ---

class _StopwatchIllustration extends StatelessWidget {
  const _StopwatchIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 300,
      child: CustomPaint(painter: _StopwatchPainter()),
    );
  }
}

class _StopwatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Outer dark circle (dial background)
    final outerRadius = size.width * 0.45;
    final outerPaint = Paint()
      ..color = const Color(0xFF1A1E35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), outerRadius, outerPaint);

    // Outer ring shadow
    final outerRingPaint = Paint()
      ..color = const Color(0xFF252A45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(cx, cy), outerRadius, outerRingPaint);

    // Inner dark circle
    final innerRadius = outerRadius * 0.78;
    final innerPaint = Paint()
      ..color = const Color(0xFF0F1225)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), innerRadius, innerPaint);

    final innerRingPaint = Paint()
      ..color = const Color(0xFF2A2F50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), innerRadius, innerRingPaint);

    // Tick marks around the dial
    final tickPaint = Paint()
      ..color = const Color(0xFF3A3F60)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      final angle = (i * 6 - 90) * pi / 180;
      final isLarge = i % 5 == 0;
      final startR = innerRadius * (isLarge ? 0.85 : 0.9);
      final endR = innerRadius * 0.95;

      if (isLarge) {
        tickPaint.strokeWidth = 2.0;
        tickPaint.color = const Color(0xFF4A4F70);
      } else {
        tickPaint.strokeWidth = 1.0;
        tickPaint.color = const Color(0xFF2A2F50);
      }

      canvas.drawLine(
        Offset(cx + startR * cos(angle), cy + startR * sin(angle)),
        Offset(cx + endR * cos(angle), cy + endR * sin(angle)),
        tickPaint,
      );
    }

    // Center stopwatch body (blue lock icon area)
    final centerGlowRadius = outerRadius * 0.35;

    // Glow behind the icon
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF2244FF).withValues(alpha: 0.5),
              const Color(0xFF2244FF).withValues(alpha: 0.15),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromCircle(
              center: Offset(cx, cy),
              radius: centerGlowRadius * 2,
            ),
          );
    canvas.drawCircle(Offset(cx, cy), centerGlowRadius * 2, glowPaint);

    // Blue circle center
    final centerPaint = Paint()
      ..color = const Color(0xFF2244FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), centerGlowRadius, centerPaint);

    // Stopwatch button on top
    final buttonPaint = Paint()
      ..color = const Color(0xFF2244FF)
      ..style = PaintingStyle.fill;
    final buttonRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy - centerGlowRadius - 6),
        width: 14,
        height: 12,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(buttonRect, buttonPaint);

    // Lock icon in center
    _drawLockIcon(canvas, cx, cy, centerGlowRadius * 0.5);

    // Subtle outer glow effect
    final outerGlowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.transparent,
              const Color(0xFF2244FF).withValues(alpha: 0.05),
              const Color(0xFF2244FF).withValues(alpha: 0.02),
              Colors.transparent,
            ],
            stops: const [0.6, 0.75, 0.85, 1.0],
          ).createShader(
            Rect.fromCircle(center: Offset(cx, cy), radius: outerRadius * 1.3),
          );
    canvas.drawCircle(Offset(cx, cy), outerRadius * 1.3, outerGlowPaint);
  }

  void _drawLockIcon(Canvas canvas, double cx, double cy, double scale) {
    final paint = Paint()
      ..color = const Color(0xFF0A0E21)
      ..style = PaintingStyle.fill;

    // Lock body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy + scale * 0.3),
        width: scale * 1.6,
        height: scale * 1.3,
      ),
      Radius.circular(scale * 0.2),
    );
    canvas.drawRRect(bodyRect, paint);

    // Lock shackle
    final shacklePaint = Paint()
      ..color = const Color(0xFF0A0E21)
      ..style = PaintingStyle.stroke
      ..strokeWidth = scale * 0.25
      ..strokeCap = StrokeCap.round;

    final shackleRect = Rect.fromCenter(
      center: Offset(cx, cy - scale * 0.3),
      width: scale * 0.9,
      height: scale * 1.0,
    );
    canvas.drawArc(shackleRect, pi, pi, false, shacklePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- Page 3 Illustration: Clock and Lock ---

class _ClockAndLockIllustration extends StatelessWidget {
  const _ClockAndLockIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2A3642), Color(0xFF1E2830)],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Wooden surface at the bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 100,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF6B5740), Color(0xFF5A4835)],
                    ),
                  ),
                ),
              ),
              // Clock
              Positioned(
                left: 40,
                bottom: 60,
                child: SizedBox(
                  width: 150,
                  height: 160,
                  child: CustomPaint(painter: _AnalogClockPainter()),
                ),
              ),
              // Padlock
              Positioned(
                right: 50,
                bottom: 60,
                child: SizedBox(
                  width: 80,
                  height: 110,
                  child: CustomPaint(painter: _PadlockPainter()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalogClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width * 0.42;

    // Clock face (white/cream)
    final facePaint = Paint()
      ..color = const Color(0xFFF0EDE8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), radius, facePaint);

    // Chrome rim
    final rimPaint = Paint()
      ..color = const Color(0xFFC0C0C0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(Offset(cx, cy), radius, rimPaint);

    final outerRimPaint = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(cx, cy), radius + 3, outerRimPaint);

    // Hour markers
    final markerPaint = Paint()
      ..color = const Color(0xFF333333)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      final startR = radius * 0.82;
      final endR = radius * 0.92;

      canvas.drawLine(
        Offset(cx + startR * cos(angle), cy + startR * sin(angle)),
        Offset(cx + endR * cos(angle), cy + endR * sin(angle)),
        markerPaint,
      );
    }

    // Hour numbers
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final numbers = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      final numR = radius * 0.68;

      textPainter.text = TextSpan(
        text: '${numbers[i]}',
        style: const TextStyle(
          color: Color(0xFF333333),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          cx + numR * cos(angle) - textPainter.width / 2,
          cy + numR * sin(angle) - textPainter.height / 2,
        ),
      );
    }

    // Hour hand (10 o'clock position)
    final hourAngle = (10 * 30 - 90) * pi / 180;
    final hourHandPaint = Paint()
      ..color = const Color(0xFF222222)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(
        cx + radius * 0.45 * cos(hourAngle),
        cy + radius * 0.45 * sin(hourAngle),
      ),
      hourHandPaint,
    );

    // Minute hand (12 o'clock)
    final minuteAngle = (0 * 6 - 90) * pi / 180;
    final minuteHandPaint = Paint()
      ..color = const Color(0xFF222222)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(
        cx + radius * 0.6 * cos(minuteAngle),
        cy + radius * 0.6 * sin(minuteAngle),
      ),
      minuteHandPaint,
    );

    // Center dot
    final centerDotPaint = Paint()
      ..color = const Color(0xFF222222)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 3, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PadlockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final bodyTop = size.height * 0.4;
    final bodyBottom = size.height * 0.9;
    final bodyWidth = size.width * 0.75;

    // Padlock body (golden)
    final bodyPaint = Paint()
      ..shader =
          const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD4A843), Color(0xFFB8912E), Color(0xFFA07D25)],
          ).createShader(
            Rect.fromLTRB(
              cx - bodyWidth / 2,
              bodyTop,
              cx + bodyWidth / 2,
              bodyBottom,
            ),
          );

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        cx - bodyWidth / 2,
        bodyTop,
        cx + bodyWidth / 2,
        bodyBottom,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Highlight on body
    final highlightPaint = Paint()
      ..color = const Color(0xFFE0C060).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final highlightRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        cx - bodyWidth / 2 + 3,
        bodyTop + 3,
        cx - bodyWidth / 2 + bodyWidth * 0.3,
        bodyBottom - 3,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(highlightRect, highlightPaint);

    // Shackle (open - right side up)
    final shacklePaint = Paint()
      ..color = const Color(0xFFC0C0C0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final shackleRect = Rect.fromCenter(
      center: Offset(cx, bodyTop - 5),
      width: bodyWidth * 0.55,
      height: size.height * 0.35,
    );
    canvas.drawArc(shackleRect, pi, pi, false, shacklePaint);

    // Shackle legs
    canvas.drawLine(
      Offset(cx - bodyWidth * 0.275, bodyTop - 5),
      Offset(cx - bodyWidth * 0.275, bodyTop + 5),
      shacklePaint,
    );
    canvas.drawLine(
      Offset(cx + bodyWidth * 0.275, bodyTop - 5),
      Offset(cx + bodyWidth * 0.275, bodyTop + 5),
      shacklePaint,
    );

    // Keyhole
    final keyholePaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.fill;

    final keyholeY = (bodyTop + bodyBottom) / 2;
    canvas.drawCircle(Offset(cx, keyholeY - 3), 5, keyholePaint);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, keyholeY + 5), width: 4, height: 12),
      keyholePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
