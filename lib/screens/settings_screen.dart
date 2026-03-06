import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_lock/core/providers/providers.dart';
import 'package:study_lock/core/theme/app_colors.dart';
import 'package:study_lock/screens/timer_setup_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Title
              Center(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // PREFERENCES section
              _buildSectionLabel('PREFERENCES', colors),
              const SizedBox(height: 12),
              _buildSectionCard([
                _SettingsTileData(
                  icon: Icons.access_time_filled,
                  iconColor: AppColors.primaryLight,
                  title: 'Change Timer Limits',
                  trailing: _SettingsTrailing.chevron,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TimerSetupScreen(),
                      ),
                    );
                  },
                ),
                _SettingsTileData(
                  icon: Icons.dark_mode,
                  iconColor: const Color(0xFF9C6ADE),
                  title: 'Dark Mode',
                  trailing: _SettingsTrailing.toggle,
                  toggleValue: settings.darkMode,
                  onToggle: (val) =>
                      ref.read(settingsProvider.notifier).setDarkMode(val),
                ),
                _SettingsTileData(
                  icon: Icons.notifications,
                  iconColor: AppColors.accent,
                  title: 'Notification Reminders',
                  trailing: _SettingsTrailing.toggle,
                  toggleValue: settings.notifications,
                  onToggle: (val) =>
                      ref.read(settingsProvider.notifier).setNotifications(val),
                ),
              ], colors),
              const SizedBox(height: 28),
              // DATA & SUPPORT section
              _buildSectionLabel('DATA & SUPPORT', colors),
              const SizedBox(height: 12),
              _buildSectionCard([
                _SettingsTileData(
                  icon: Icons.bar_chart,
                  iconColor: AppColors.success,
                  title: 'App Usage History',
                  trailing: _SettingsTrailing.chevron,
                  onTap: () {
                    // Switch to Stats tab (index 2)
                    ref.read(currentTabProvider.notifier).state = 2;
                  },
                ),
                _SettingsTileData(
                  icon: Icons.info,
                  iconColor: AppColors.primaryLight,
                  title: 'About Study Lock',
                  trailing: _SettingsTrailing.chevron,
                  onTap: () => _showAboutDialog(context, colors),
                  isLast: true,
                ),
              ], colors),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'About Study Lock',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Study Lock v1.0.0',
              style: TextStyle(color: colors.textPrimary, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Study Lock helps you stay focused by blocking distracting apps for a set period of time. Take control of your screen time and build better habits',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Made with ❤️ for productivity',
              style: TextStyle(color: colors.textTertiary, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, AppColors colors) {
    return Text(
      label,
      style: TextStyle(
        color: colors.textTertiary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildSectionCard(List<_SettingsTileData> tiles, AppColors colors) {
    return Container(
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
        children: tiles.asMap().entries.map((entry) {
          final index = entry.key;
          final tile = entry.value;
          final isLast = tile.isLast || index == tiles.length - 1;
          return _buildSettingsTile(tile, isLast, colors);
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsTile(
    _SettingsTileData tile,
    bool isLast,
    AppColors colors,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: tile.trailing == _SettingsTrailing.toggle
              ? () => tile.onToggle?.call(!(tile.toggleValue ?? false))
              : tile.onTap,
          borderRadius: isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(20))
              : BorderRadius.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tile.iconColor.withAlpha(38),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(tile.icon, color: tile.iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                // Title
                Expanded(
                  child: Text(
                    tile.title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Trailing
                if (tile.trailing == _SettingsTrailing.chevron)
                  Icon(
                    Icons.chevron_right,
                    color: colors.textQuaternary,
                    size: 24,
                  )
                else if (tile.trailing == _SettingsTrailing.toggle)
                  Switch(
                    value: tile.toggleValue ?? false,
                    onChanged: tile.onToggle,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primary,
                    inactiveThumbColor: colors.switchInactiveThumb,
                    inactiveTrackColor: colors.switchInactiveTrack,
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 70),
            child: Divider(height: 1, color: colors.cardBorder),
          ),
      ],
    );
  }
}

enum _SettingsTrailing { chevron, toggle }

class _SettingsTileData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final _SettingsTrailing trailing;
  final VoidCallback? onTap;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
  final bool isLast;

  const _SettingsTileData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trailing,
    this.onTap,
    this.toggleValue,
    this.onToggle,
    this.isLast = false,
  });
}
