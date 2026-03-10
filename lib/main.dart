import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_lock/core/providers/providers.dart';
import 'package:study_lock/core/services/ad_service.dart';
import 'package:study_lock/core/storage/storage_service.dart';
import 'package:study_lock/core/theme/app_colors.dart';
import 'package:study_lock/screens/main_shell.dart';
import 'package:study_lock/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive local storage
  await StorageService.init();

  // Initialize Google Mobile Ads
  await AdService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(settingsProvider.select((s) => s.darkMode));
    final isFirstLaunch = ref.watch(
      settingsProvider.select((s) => s.isFirstLaunch),
    );
    return MaterialApp(
      title: 'Study Lock',
      debugShowCheckedModeBanner: false,
      theme: isDark ? AppColors.darkTheme : AppColors.lightTheme,
      home: isFirstLaunch ? const OnboardingScreen() : const MainShell(),
    );
  }
}
