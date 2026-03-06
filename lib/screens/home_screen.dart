import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_lock/core/models/models.dart';
import 'package:study_lock/core/providers/providers.dart';
import 'package:study_lock/core/theme/app_colors.dart';
import 'package:study_lock/screens/app_locked_screen.dart';
import 'package:study_lock/screens/timer_setup_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final blockedApps = ref.watch(blockedAppsProvider);
    final stats = ref.watch(statsProvider);
    final colors = AppColors.of(context);

    final isTimerActive = timerState.isActive;
    final hours = isTimerActive ? timerState.remaining.inHours : 0;
    final minutes = isTimerActive ? timerState.remaining.inMinutes % 60 : 0;
    final seconds = isTimerActive ? timerState.remaining.inSeconds % 60 : 0;
    final progress = isTimerActive ? timerState.progress : 0.0;

    final lockedAppNames = blockedApps.map((a) => a.appName).toList();
    final lockedAppsText = lockedAppNames.isEmpty
        ? 'No apps selected'
        : lockedAppNames.take(3).join(', ') +
              (lockedAppNames.length > 3
                  ? ' +${lockedAppNames.length - 3} more'
                  : '');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildTopBar(context, ref, isTimerActive, colors),
              const SizedBox(height: 24),
              _TimerRing(
                hours: hours,
                minutes: minutes,
                seconds: seconds,
                progress: progress,
                isActive: isTimerActive,
              ),
              const SizedBox(height: 32),
              _buildLockedAppsCard(
                context,
                ref,
                lockedAppsText,
                blockedApps,
                colors,
              ),
              const SizedBox(height: 16),
              _buildActionButtons(
                context,
                ref,
                isTimerActive,
                blockedApps.isNotEmpty,
                colors,
              ),
              const SizedBox(height: 16),
              _buildFocusStreakCard(stats.streakDays, colors),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    WidgetRef ref,
    bool isTimerActive,
    AppColors colors,
  ) {
    return Center(
      child: Text(
        isTimerActive ? 'Focus Active' : 'Focus Mode',
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLockedAppsCard(
    BuildContext context,
    WidgetRef ref,
    String lockedAppsText,
    List<BlockedApp> blockedApps,
    AppColors colors,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(currentTabProvider.notifier).state = 1;
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: colors.surfaceHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.cardBorder),
          boxShadow: colors.isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blockedApps.isEmpty ? 'No Apps Locked' : 'Locked Apps',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    blockedApps.isEmpty
                        ? 'Tap to select apps to block'
                        : lockedAppsText,
                    style: TextStyle(color: colors.textTertiary, fontSize: 14),
                  ),
                ],
              ),
            ),
            if (blockedApps.isEmpty)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.iconPlaceholderBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: colors.textTertiary, size: 24),
              )
            else
              SizedBox(
                width: min(blockedApps.length * 26.0 + 12, 90),
                height: 40,
                child: Stack(
                  children: List.generate(
                    min(blockedApps.length, 3),
                    (index) => Positioned(
                      left: index * 26.0,
                      top: 0,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.avatarBorder,
                            width: 2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: blockedApps[index].appIcon != null
                            ? Image.memory(
                                blockedApps[index].appIcon!,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Text(
                                  blockedApps[index].appName.isNotEmpty
                                      ? blockedApps[index].appName[0]
                                            .toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: colors.textQuaternary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    bool isTimerActive,
    bool hasBlockedApps,
    AppColors colors,
  ) {
    if (isTimerActive) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppLockedScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'View Lock',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                ref.read(currentTabProvider.notifier).state = 1;
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textPrimary,
                side: BorderSide(color: colors.outlinedBtnBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: colors.outlinedBtnBg,
              ),
              child: const Text(
                'Select Apps',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (!hasBlockedApps) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please select apps to block first'),
                      backgroundColor: colors.snackBarBg,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      action: SnackBarAction(
                        label: 'Select',
                        textColor: AppColors.primaryLight,
                        onPressed: () {
                          ref.read(currentTabProvider.notifier).state = 1;
                        },
                      ),
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TimerSetupScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Set Timer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFocusStreakCard(int streakDays, AppColors colors) {
    final dayProgress = (streakDays % 7) / 7;
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
        boxShadow: colors.isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Focus Streak',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    streakDays > 0 ? 'Keep it up!' : 'Start focusing!',
                    style: TextStyle(color: colors.textTertiary, fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: AppColors.accent,
                    size: 22,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$streakDays Days',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: dayProgress,
              minHeight: 8,
              backgroundColor: colors.progressBarBg,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isActive = index == (streakDays % 7);
              return Text(
                days[index],
                style: TextStyle(
                  color: isActive ? AppColors.accent : colors.textTertiary,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// --- Circular Timer Ring ---

class _TimerRing extends StatelessWidget {
  final int hours;
  final int minutes;
  final int seconds;
  final double progress;
  final bool isActive;

  const _TimerRing({
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.progress,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      width: 260,
      height: 260,
      child: CustomPaint(
        painter: _TimerRingPainter(
          progress: progress,
          isActive: isActive,
          colors: colors,
        ),
        child: Center(
          child: isActive
              ? _buildActiveDisplay(colors)
              : _buildIdleDisplay(colors),
        ),
      ),
    );
  }

  Widget _buildActiveDisplay(AppColors colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$hours',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 56,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'h',
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              minutes.toString().padLeft(2, '0'),
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 56,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'm',
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Text(
          seconds.toString().padLeft(2, '0'),
          style: TextStyle(
            color: colors.textTertiary,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'REMAINING',
          style: TextStyle(
            color: colors.textTertiary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildIdleDisplay(AppColors colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock_open, color: colors.textQuaternary, size: 48),
        const SizedBox(height: 12),
        Text(
          'Ready to Focus',
          style: TextStyle(
            color: colors.textTertiary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Set a timer to begin',
          style: TextStyle(color: colors.textQuaternary, fontSize: 14),
        ),
      ],
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final bool isActive;
  final AppColors colors;

  _TimerRingPainter({
    required this.progress,
    required this.isActive,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background track
    final trackPaint = Paint()
      ..color = colors.timerTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, trackPaint);

    if (!isActive || progress <= 0) return;

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: const [Color(0xFF4466FF), Color(0xFF2244FF), Color(0xFF1133DD)],
        stops: const [0.0, 0.5, 1.0],
        transform: const GradientRotation(-pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );

    // Glow at the tip
    final tipAngle = -pi / 2 + 2 * pi * progress;
    final tipX = center.dx + radius * cos(tipAngle);
    final tipY = center.dy + radius * sin(tipAngle);
    final glowPaint = Paint()
      ..color = const Color(0xFF4466FF).withAlpha(128)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(tipX, tipY), 6, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isActive != isActive;
}
