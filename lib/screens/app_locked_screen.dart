import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_lock/core/providers/providers.dart';
import 'package:study_lock/core/theme/app_colors.dart';
import 'package:study_lock/screens/main_shell.dart';

class AppLockedScreen extends ConsumerWidget {
  final int hours;
  final int minutes;

  const AppLockedScreen({super.key, this.hours = 0, this.minutes = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final displayHours = timerState.isActive
        ? timerState.remaining.inHours
        : hours;
    final displayMinutes = timerState.isActive
        ? timerState.remaining.inMinutes % 60
        : minutes;
    final displaySeconds = timerState.isActive
        ? timerState.remaining.inSeconds % 60
        : 0;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppColors.of(context).scaffoldGradientDecoration,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Lock icon with glow
              _buildLockIcon(),
              const SizedBox(height: 28),
              // Title
              const Text(
                'App Locked',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Subtitle
              Text(
                'You can open this app after the timer\nends.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              // Timer display
              _buildTimerDisplay(displayHours, displayMinutes, displaySeconds),
              const SizedBox(height: 8),
              // REMAINING label
              Text(
                'REMAINING',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 48),
              // Stay focused text
              Text(
                'Stay focused.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Spacer(flex: 3),
              // View Focus Dashboard button
              _buildDashboardButton(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockIcon() {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6B5B95).withValues(alpha: 0.2),
                  const Color(0xFF6B5B95).withValues(alpha: 0.08),
                  Colors.transparent,
                ],
                stops: const [0.3, 0.7, 1.0],
              ),
            ),
          ),
          // Inner circle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1E35).withValues(alpha: 0.8),
              border: Border.all(
                color: const Color(0xFF3A3555).withValues(alpha: 0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B5B95).withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          // Lock icon container (square with rounded corners)
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Icon(
              Icons.lock,
              color: Colors.white.withValues(alpha: 0.85),
              size: 50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(int h, int m, int s) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$h',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'h',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 28,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              m.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'm',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 28,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Text(
          '${s.toString().padLeft(2, '0')}s',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainShell()),
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0A0E21),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('View Focus Dashboard'),
        ),
      ),
    );
  }
}
