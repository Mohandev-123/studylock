import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_lock/core/providers/providers.dart';
import 'package:study_lock/core/storage/storage_service.dart';
import 'package:study_lock/core/theme/app_colors.dart';
import 'package:study_lock/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive local storage
  await StorageService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(settingsProvider.select((s) => s.darkMode));
    return MaterialApp(
      title: 'Study Lock',
      debugShowCheckedModeBanner: false,
      theme: isDark ? AppColors.darkTheme : AppColors.lightTheme,
      home: const SplashScreen(),
    );
  }
}
