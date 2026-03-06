import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_lock/core/providers/providers.dart';
import 'package:study_lock/screens/main_shell.dart';

class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen>
    with WidgetsBindingObserver {
  bool _settingsOpened = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When user returns from accessibility settings, check if enabled
    if (state == AppLifecycleState.resumed && _settingsOpened) {
      _checkPermissionAndProceed();
    }
  }

  Future<void> _checkPermissionAndProceed() async {
    setState(() => _checking = true);
    final channel = ref.read(methodChannelServiceProvider);
    final isEnabled = await channel.isAccessibilityEnabled();
    setState(() => _checking = false);

    if (isEnabled) {
      ref.read(settingsProvider.notifier).markPermissionGranted();
      ref.read(settingsProvider.notifier).markLaunched();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please enable Study Lock in Accessibility settings to continue',
          ),
          backgroundColor: const Color(0xFF1A1E35),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onGrantPermission() async {
    final channel = ref.read(methodChannelServiceProvider);
    await channel.openAccessibilitySettings();
    _settingsOpened = true;
  }

  void _onSkip() {
    // Allow skipping — mark launched but not permission granted
    ref.read(settingsProvider.notifier).markLaunched();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  void _onWhyNeeded() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why is this needed?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A0E21),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Study Lock uses the Accessibility Service to detect when you open a blocked app and redirect you back. '
              'This is required for the app-blocking feature to work.\n\n'
              'We do not collect, store, or share any personal data through this service.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0A0E21)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Enable App Control',
          style: TextStyle(
            color: Color(0xFF0A0E21),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _onSkip,
            child: const Text(
              'Skip',
              style: TextStyle(color: Color(0xFF2244FF), fontSize: 15),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Illustration
              _buildIllustration(),
              const SizedBox(height: 40),
              // Title
              const Text(
                'Study Lock needs accessibility\npermission',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0A0E21),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'To monitor and block distracting apps\nduring your focus sessions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              // Grant Permission button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _checking ? null : _onGrantPermission,
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
                  child: _checking
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _settingsOpened
                              ? 'Open Settings Again'
                              : 'Grant Permission',
                        ),
                ),
              ),
              if (_settingsOpened) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _checking ? null : _checkPermissionAndProceed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2244FF),
                      side: const BorderSide(color: Color(0xFF2244FF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'I\'ve enabled it — Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Why this is needed link
              GestureDetector(
                onTap: _onWhyNeeded,
                child: const Text(
                  'Why this is needed?',
                  style: TextStyle(
                    color: Color(0xFF2244FF),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Top-left pink circle
          Positioned(
            left: 28,
            top: 30,
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFFF2B5B5).withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Top-right blue circle
          Positioned(
            right: 28,
            top: 30,
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFFB5C8E8).withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Bottom-left yellow circle
          Positioned(
            left: 28,
            bottom: 30,
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFFE8DDB5).withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Bottom-right green circle
          Positioned(
            right: 28,
            bottom: 30,
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFFB5E8C0).withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Center lock icon
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF2244FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}
