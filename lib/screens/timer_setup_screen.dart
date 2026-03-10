import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_lock/core/providers/providers.dart';
import 'package:study_lock/core/theme/app_colors.dart';
import 'package:study_lock/screens/app_locked_screen.dart';

class TimerSetupScreen extends ConsumerStatefulWidget {
  const TimerSetupScreen({super.key});

  @override
  ConsumerState<TimerSetupScreen> createState() => _TimerSetupScreenState();
}

class _TimerSetupScreenState extends ConsumerState<TimerSetupScreen> {
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;
  int _selectedHours = 1;
  int _selectedMinutes = 0;
  bool _isStarting = false;

  final List<int> _presetHours = [1, 2, 4, 8];

  @override
  void initState() {
    super.initState();
    _hoursController = FixedExtentScrollController(initialItem: _selectedHours);
    _minutesController = FixedExtentScrollController(
      initialItem: _selectedMinutes,
    );
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _selectPreset(int hours) {
    setState(() {
      _selectedHours = hours;
      _selectedMinutes = 0;
    });
    _hoursController.animateToItem(
      hours,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _minutesController.animateToItem(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onStartFocusLock() async {
    final colors = AppColors.of(context);
    // Validate timer is not zero
    if (_selectedHours == 0 && _selectedMinutes == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please set a duration greater than 0'),
          backgroundColor: colors.snackBarBg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Check if blocked apps exist
    final blockedApps = ref.read(blockedAppsProvider);
    if (blockedApps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No apps selected to block'),
          backgroundColor: colors.snackBarBg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isStarting = true);

    // Check accessibility permission
    final channel = ref.read(methodChannelServiceProvider);
    final isAccessibilityEnabled = await channel.isAccessibilityEnabled();

    if (!isAccessibilityEnabled) {
      if (mounted) {
        setState(() => _isStarting = false);
        _showAccessibilityDialog(context);
      }
      return;
    }

    // Start the actual timer via provider
    await ref
        .read(timerProvider.notifier)
        .startTimer(hours: _selectedHours, minutes: _selectedMinutes);

    if (mounted) {
      // Navigate to locked screen, replacing this screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppLockedScreen()),
      );
    }
  }

  void _showAccessibilityDialog(BuildContext context) {
    final colors = AppColors.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Permission Required',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Study Lock needs the Accessibility Service enabled to block apps. '
          'Please enable it in Settings to start a focus session.',
          style: TextStyle(color: colors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: colors.textTertiary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final channel = ref.read(methodChannelServiceProvider);
              await channel.openAccessibilitySettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: colors.scaffoldGradientDecoration,
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              _buildAppBar(),
              const SizedBox(height: 16),
              // Clock icon
              _buildClockIcon(),
              const SizedBox(height: 20),
              // Scroll pickers
              _buildScrollPickers(),
              const SizedBox(height: 8),
              // Labels
              _buildLabels(),
              const SizedBox(height: 24),
              // Preset buttons
              _buildPresetButtons(),
              const Spacer(),
              // Start Focus Lock button
              _buildStartButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.of(context).textPrimary,
              size: 26,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Set Lock Duration',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.of(context).textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildClockIcon() {
    final colors = AppColors.of(context);
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors.searchBorder, width: 2.5),
            ),
          ),
          // Blue clock circle
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.access_time, color: Colors.white, size: 34),
          ),
          // Small lock badge
          Positioned(
            right: 20,
            bottom: 20,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withAlpha(153),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.lock, color: AppColors.primary, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollPickers() {
    final colors = AppColors.of(context);
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          // Selection highlight
          Center(
            child: Container(
              height: 64,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: colors.selectionHighlight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.searchBorder),
              ),
            ),
          ),
          // Colon separator
          Center(
            child: Text(
              ':',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 40,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          // Pickers
          Row(
            children: [
              // Hours picker
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: _hoursController,
                  itemExtent: 60,
                  perspective: 0.003,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() => _selectedHours = index);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 25,
                    builder: (context, index) {
                      final isSelected = index == _selectedHours;
                      return Center(
                        child: Text(
                          index.toString().padLeft(2, '0'),
                          style: TextStyle(
                            color: isSelected
                                ? colors.textPrimary
                                : colors.textTertiary.withValues(
                                    alpha: _getOpacity(index, _selectedHours),
                                  ),
                            fontSize: isSelected ? 48 : 30,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Minutes picker
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: _minutesController,
                  itemExtent: 60,
                  perspective: 0.003,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() => _selectedMinutes = index);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 60,
                    builder: (context, index) {
                      final isSelected = index == _selectedMinutes;
                      return Center(
                        child: Text(
                          index.toString().padLeft(2, '0'),
                          style: TextStyle(
                            color: isSelected
                                ? colors.textPrimary
                                : colors.textTertiary.withValues(
                                    alpha: _getOpacity(index, _selectedMinutes),
                                  ),
                            fontSize: isSelected ? 48 : 30,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _getOpacity(int index, int selected) {
    final diff = (index - selected).abs();
    if (diff == 0) return 1.0;
    if (diff == 1) return 0.5;
    return 0.25;
  }

  Widget _buildLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'HOURS',
                style: TextStyle(
                  color: AppColors.of(context).textTertiary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'MINUTES',
                style: TextStyle(
                  color: AppColors.of(context).textTertiary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButtons() {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _presetHours.map((hours) {
          final isSelected = _selectedHours == hours && _selectedMinutes == 0;
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 52) / 2,
            height: 48,
            child: OutlinedButton(
              onPressed: () => _selectPreset(hours),
              style: OutlinedButton.styleFrom(
                backgroundColor: isSelected
                    ? AppColors.primary
                    : colors.outlinedBtnBg,
                foregroundColor: isSelected ? Colors.white : colors.textPrimary,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : colors.outlinedBtnBorder,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                '$hours hour${hours == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStartButton() {
    final isDisabled = _selectedHours == 0 && _selectedMinutes == 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isStarting || isDisabled ? null : _onStartFocusLock,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withAlpha(102),
            disabledForegroundColor: Colors.white54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: _isStarting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  isDisabled
                      ? 'Select Duration'
                      : 'Start Focus Lock'
                            ' (${_selectedHours}h ${_selectedMinutes.toString().padLeft(2, '0')}m)',
                ),
        ),
      ),
    );
  }
}
