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
      title: 'Take Back Your\nTime',
      subtitle: 'Block distracting apps and focus on what\nmatters.',
      icon: Icons.shield_moon_rounded,
      buttonText: 'Next',
    ),
    OnboardingPageData(
      topTitle: 'Set Long Lock Timers',
      title: 'Lock apps for hours so\nyou cannot open them.',
      subtitle:
          'Set a customized duration to\ncompletely block access to\ndistracting applications.',
      icon: Icons.timer_outlined,
      buttonText: 'Next',
      showArrow: true,
      showTimer: true,
    ),
    OnboardingPageData(
      topTitle: '',
      title: 'Unlock When Time Ends',
      subtitle: 'Apps automatically unlock when\nthe timer ends.',
      icon: Icons.lock_clock_rounded,
      buttonText: 'Get Started',
      showArrow: true,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF2FAFF), Color(0xFFE6F4FF), Color(0xFFF8FCFF)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) => _buildPage(_pages[index]),
                ),
              ),
              _buildPageIndicator(),
              const SizedBox(height: 20),
              _buildBottomButton(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final page = _pages[_currentPage];
    final heading = page.topTitle.isEmpty ? 'Study Lock' : page.topTitle;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              heading,
              style: const TextStyle(
                color: Color(0xFF153A60),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: _onSkip,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2D9CFF),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPageData page) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildIllustration(page),
          const SizedBox(height: 28),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF153A60),
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF5A7EA3),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          if (page.showTimer) ...[
            const SizedBox(height: 28),
            _buildTimerDisplay(),
          ],
        ],
      ),
    );
  }

  Widget _buildIllustration(OnboardingPageData page) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF2D9CFF).withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D9CFF).withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 30,
            left: 26,
            child: _bubble(const Color(0xFFD9EEFF), 62),
          ),
          Positioned(
            top: 52,
            right: 38,
            child: _bubble(const Color(0xFFC9E7FF), 34),
          ),
          Positioned(
            bottom: 26,
            left: 44,
            child: _bubble(const Color(0xFFEAF6FF), 28),
          ),
          Positioned(
            bottom: 34,
            right: 24,
            child: _bubble(const Color(0xFFDBF0FF), 52),
          ),
          Container(
            width: 106,
            height: 106,
            decoration: BoxDecoration(
              color: const Color(0xFF2D9CFF),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D9CFF).withValues(alpha: 0.38),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(page.icon, color: Colors.white, size: 54),
          ),
        ],
      ),
    );
  }

  Widget _bubble(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildTimerDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimerBox('20', 'HOURS'),
        const SizedBox(width: 12),
        _buildTimerBox('00', 'MINUTES'),
        const SizedBox(width: 12),
        _buildTimerBox('00', 'SECONDS'),
      ],
    );
  }

  Widget _buildTimerBox(String value, String label) {
    return Column(
      children: [
        Container(
          width: 86,
          height: 78,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF2D9CFF).withValues(alpha: 0.22),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF153A60),
              fontSize: 36,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B8DAF),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
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
          duration: const Duration(milliseconds: 240),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isActive
                ? const Color(0xFF2D9CFF)
                : const Color(0xFF2D9CFF).withValues(alpha: 0.24),
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
            backgroundColor: const Color(0xFF2D9CFF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
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

class OnboardingPageData {
  final String topTitle;
  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonText;
  final bool showArrow;
  final bool showTimer;

  const OnboardingPageData({
    required this.topTitle,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonText,
    this.showArrow = false,
    this.showTimer = false,
  });
}
