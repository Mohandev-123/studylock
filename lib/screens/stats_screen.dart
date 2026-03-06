import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_lock/core/models/models.dart';
import 'package:study_lock/core/providers/providers.dart';
import 'package:study_lock/core/theme/app_colors.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final blockedApps = ref.watch(blockedAppsProvider);
    final dailyHours = ref.read(statsProvider.notifier).getDailyFocusHours();
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildTopBar(ref, colors),
              const SizedBox(height: 20),
              _buildHoursSavedCard(stats.focusHours, dailyHours, colors),
              const SizedBox(height: 16),
              _buildStatsSummaryRow(
                appsBlocked: stats.blockedAppsCount,
                focusHours: stats.totalFocusMinutes ~/ 60,
                streakDays: stats.streakDays,
                colors: colors,
              ),
              const SizedBox(height: 16),
              _buildSessionsCard(stats.totalSessions, colors),
              const SizedBox(height: 16),
              _buildBlockedAppUsageCard(blockedApps, colors),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(WidgetRef ref, AppColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Text(
          'Focus Stats',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildHoursSavedCard(
    double focusHours,
    List<double> dailyHours,
    AppColors colors,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
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
                    'Hours Saved',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Past week',
                    style: TextStyle(color: colors.textTertiary, fontSize: 14),
                  ),
                ],
              ),
              Text(
                '+${focusHours.toStringAsFixed(1)}h',
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(painter: _ChartPainter(dailyHours: dailyHours)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map(
                  (day) => Text(
                    day,
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummaryRow({
    required int appsBlocked,
    required int focusHours,
    required int streakDays,
    required AppColors colors,
  }) {
    return Row(
      children: [
        _buildStatBox(
          icon: Icons.block,
          iconColor: AppColors.primaryLight,
          value: '$appsBlocked',
          label: 'APPS BLOCKED',
          colors: colors,
        ),
        const SizedBox(width: 10),
        _buildStatBox(
          icon: Icons.access_time_filled,
          iconColor: AppColors.success,
          value: '${focusHours}h',
          label: 'FOCUSED',
          colors: colors,
        ),
        const SizedBox(width: 10),
        _buildStatBox(
          icon: Icons.local_fire_department,
          iconColor: AppColors.accent,
          value: '$streakDays',
          label: 'DAY STREAK',
          colors: colors,
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required AppColors colors,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.cardBorder),
          boxShadow: colors.isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsCard(int totalSessions, AppColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withAlpha(38),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: AppColors.primaryLight,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$totalSessions',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Total Focus Sessions',
                style: TextStyle(color: colors.textTertiary, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedAppUsageCard(
    List<BlockedApp> blockedApps,
    AppColors colors,
  ) {
    if (blockedApps.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(Icons.block, color: colors.textQuaternary, size: 40),
            const SizedBox(height: 12),
            Text(
              'No blocked apps yet',
              style: TextStyle(color: colors.textTertiary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
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
          Text(
            'Blocked Apps',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${blockedApps.length} app${blockedApps.length == 1 ? '' : 's'} currently blocked',
            style: TextStyle(color: colors.textTertiary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: blockedApps.take(8).map<Widget>((app) {
              final name = app.appName.isNotEmpty
                  ? app.appName
                  : (app.packageName.isNotEmpty ? app.packageName : 'App');
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withAlpha(38),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: app.appIcon != null
                        ? Image.memory(app.appIcon!, fit: BoxFit.cover)
                        : Center(
                            child: Text(
                              name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 56,
                    child: Text(
                      name,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// --- Line chart painter ---

class _ChartPainter extends CustomPainter {
  final List<double> dailyHours;

  _ChartPainter({required this.dailyHours});

  @override
  void paint(Canvas canvas, Size size) {
    if (dailyHours.isEmpty) return;

    final maxH = dailyHours.reduce(max);
    final ceiling = maxH > 0 ? maxH : 1.0;

    final points = <Offset>[];
    for (int i = 0; i < dailyHours.length; i++) {
      final x = dailyHours.length == 1
          ? size.width / 2
          : (size.width * i / (dailyHours.length - 1));
      final y = size.height - (dailyHours[i] / ceiling) * size.height * 0.9;
      points.add(Offset(x, y));
    }

    // Create smooth path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    // Draw filled area
    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.lineTo(points.first.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF4466FF).withValues(alpha: 0.3),
          const Color(0xFF4466FF).withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = const Color(0xFF4466FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Glow effect on line
    final glowPaint = Paint()
      ..color = const Color(0xFF4466FF).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.dailyHours != dailyHours;
  }
}
