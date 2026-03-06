import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_lock/core/providers/providers.dart';
import 'package:study_lock/core/theme/app_colors.dart';
import 'package:study_lock/screens/home_screen.dart';
import 'package:study_lock/screens/app_selection_screen.dart';
import 'package:study_lock/screens/settings_screen.dart';
import 'package:study_lock/screens/stats_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  void initState() {
    super.initState();
    // Resume any active timer from previous session / reboot
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(timerServiceProvider).resumeIfActive();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentTabProvider);
    final colors = AppColors.of(context);

    final screens = <Widget>[
      const HomeScreen(),
      const AppSelectionScreen(isTab: true),
      const StatsScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: Container(
        decoration: colors.scaffoldGradientDecoration,
        child: IndexedStack(index: currentIndex, children: screens),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.bottomNavBg,
          border: Border(top: BorderSide(color: colors.bottomNavBorder)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => ref.read(currentTabProvider.notifier).state = index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: colors.unselectedNavItem,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Apps'),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
