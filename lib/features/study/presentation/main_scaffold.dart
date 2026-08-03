import 'package:flutter/material.dart';

import 'package:voca_app/app/theme/app_icon.dart';
import 'package:voca_app/app/theme/app_theme.dart';

import 'home_screen.dart';
import 'progress_screen.dart';

/// Khung chính sau onboarding: bottom navigation 3 tab theo wireframe.
/// - Khám phá → [HomeScreen] (topic browser)
/// - Tiến độ → [ProgressScreen] (streak + stats)
/// - Cá nhân → placeholder (chưa có trong phạm vi hiện tại)
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;

  static const _screens = [HomeScreen(), ProgressScreen(), _ProfilePlaceholder()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: AppIcon('home', size: 24),
            selectedIcon: AppIcon('home', size: 24, color: AppColors.accent),
            label: 'Khám phá',
          ),
          NavigationDestination(
            icon: AppIcon('chart-bar', size: 24),
            selectedIcon: AppIcon('chart-bar', size: 24, color: AppColors.accent),
            label: 'Tiến độ',
          ),
          NavigationDestination(
            icon: AppIcon('user', size: 24),
            selectedIcon: AppIcon('user', size: 24, color: AppColors.accent),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cá nhân')),
      body: const Center(child: Text('Sắp ra mắt')),
    );
  }
}
