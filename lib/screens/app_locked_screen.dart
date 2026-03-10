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
    final colors = AppColors.of(context);
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
        decoration: colors.scaffoldGradientDecoration,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildLockIcon(colors),
                const SizedBox(height: 24),
                Text(
                  'App Locked',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You can open this app after the timer\nends.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                _buildTimerDisplay(
                  displayHours,
                  displayMinutes,
                  displaySeconds,
                  colors,
                ),
                const SizedBox(height: 10),
                Text(
                  'REMAINING',
                  style: TextStyle(
                    color: colors.textTertiary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Stay focused.',
                  style: TextStyle(
                    color: colors.textTertiary,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Spacer(flex: 3),
                _buildDashboardButton(context),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockIcon(AppColors colors) {
    return Container(
      width: 168,
      height: 168,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.24),
            AppColors.primary.withValues(alpha: 0.08),
            Colors.transparent,
          ],
          stops: const [0.34, 0.68, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: colors.card,
            shape: BoxShape.circle,
            border: Border.all(color: colors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 22,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(Icons.lock, color: AppColors.primary, size: 54),
        ),
      ),
    );
  }

  Widget _buildTimerDisplay(int h, int m, int s, AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$h',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 62,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'h',
                style: TextStyle(
                  color: colors.textTertiary,
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                m.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 62,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'm',
                style: TextStyle(
                  color: colors.textTertiary,
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            '${s.toString().padLeft(2, '0')}s',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context) {
    return SizedBox(
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
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        child: const Text('View Focus Dashboard'),
      ),
    );
  }
}
