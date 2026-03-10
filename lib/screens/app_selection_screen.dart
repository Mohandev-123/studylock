import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_lock/core/models/models.dart';
import 'package:study_lock/core/providers/providers.dart';
import 'package:study_lock/core/theme/app_colors.dart';

class AppSelectionScreen extends ConsumerStatefulWidget {
  /// When true, shown as a tab in MainShell (no back button, no pop on confirm)
  final bool isTab;

  const AppSelectionScreen({super.key, this.isTab = false});

  @override
  ConsumerState<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends ConsumerState<AppSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  /// Tracks which package names are toggled on
  final Set<String> _selectedPackages = {};

  /// Whether changes have been made since last save
  bool _hasChanges = false;

  /// Theme colors, set in build()
  late AppColors colors;

  @override
  void initState() {
    super.initState();
    // Pre-select currently blocked apps
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final blocked = ref.read(blockedAppsProvider);
      setState(() {
        _selectedPackages.addAll(blocked.map((a) => a.packageName));
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onConfirm(List<InstalledApp> allApps) {
    // Build BlockedApp list from selected packages
    final blockedApps = allApps
        .where((app) => _selectedPackages.contains(app.packageName))
        .map(
          (app) => BlockedApp(
            appName: app.appName,
            packageName: app.packageName,
            appIcon: app.appIcon,
          ),
        )
        .toList();

    ref.read(blockedAppsProvider.notifier).saveBlockedApps(blockedApps);
    _hasChanges = false;

    if (widget.isTab) {
      // In tab mode - show confirmation snackbar and switch to Home tab
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            blockedApps.isEmpty
                ? 'All apps unblocked'
                : '${blockedApps.length} app${blockedApps.length == 1 ? '' : 's'} selected',
          ),
          backgroundColor: AppColors.of(context).snackBarBg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      // Switch to Home tab
      ref.read(currentTabProvider.notifier).state = 0;
    } else {
      // In pushed mode - pop back
      Navigator.pop(context);
    }
  }

  void _toggleApp(String packageName, bool selected) {
    setState(() {
      if (selected) {
        _selectedPackages.add(packageName);
      } else {
        _selectedPackages.remove(packageName);
      }
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(installedAppsProvider);
    colors = AppColors.of(context);

    // When in tab mode, the gradient background is provided by MainShell
    final content = SafeArea(
      child: Column(
        children: [
          _buildAppBar(),
          const SizedBox(height: 4),
          // Selected count chip
          if (_selectedPackages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.chipBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_selectedPackages.length} selected',
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_hasChanges) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Unsaved',
                      style: TextStyle(
                        color: AppColors.accent.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 8),
          _buildSearchBar(),
          const SizedBox(height: 8),
          Expanded(
            child: appsAsync.when(
              data: (apps) {
                final filtered = _searchQuery.isEmpty
                    ? apps
                    : apps
                          .where(
                            (a) => a.appName.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                          )
                          .toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          color: colors.textQuaternary,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No apps found'
                              : 'No apps match "$_searchQuery"',
                          style: TextStyle(
                            color: colors.textTertiary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _buildAppTile(filtered[index]),
                );
              },
              loading: () => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Loading installed apps...',
                      style: TextStyle(color: colors.textTertiary),
                    ),
                  ],
                ),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Error loading apps',
                      style: TextStyle(color: colors.textPrimary, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$e',
                      style: TextStyle(
                        color: colors.textTertiary,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(installedAppsProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildConfirmButton(appsAsync.valueOrNull ?? []),
        ],
      ),
    );

    if (widget.isTab) {
      // Tab mode - no Scaffold, MainShell provides it
      return content;
    }

    // Pushed mode - own Scaffold with gradient
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: colors.scaffoldGradientDecoration,
        child: content,
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          if (!widget.isTab)
            IconButton(
              icon: Icon(Icons.arrow_back, color: colors.textPrimary),
              onPressed: () => Navigator.pop(context),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              'Choose Apps to Lock',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: colors.searchFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.searchBorder),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: TextStyle(color: colors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Search apps...',
            hintStyle: TextStyle(color: colors.textTertiary, fontSize: 15),
            prefixIcon: Icon(
              Icons.search,
              color: colors.textTertiary,
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildAppTile(InstalledApp app) {
    final isSelected = _selectedPackages.contains(app.packageName);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Row(
          children: [
            // App icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: app.appIcon != null
                  ? Image.memory(app.appIcon!, fit: BoxFit.cover)
                  : Icon(Icons.apps, color: colors.textPrimary, size: 22),
            ),
            const SizedBox(width: 14),
            // App name
            Expanded(
              child: Text(
                app.appName,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Toggle switch
            Switch(
              value: isSelected,
              onChanged: (value) => _toggleApp(app.packageName, value),
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary,
              inactiveThumbColor: colors.switchInactiveThumb,
              inactiveTrackColor: colors.switchInactiveTrack,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(List<InstalledApp> allApps) {
    final count = _selectedPackages.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: colors.bottomNavBg,
        border: Border(top: BorderSide(color: colors.bottomNavBorder)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => _onConfirm(allApps),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
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
          child: Text(
            count == 0
                ? 'Save Selection'
                : 'Save $count App${count == 1 ? '' : 's'}',
          ),
        ),
      ),
    );
  }
}
