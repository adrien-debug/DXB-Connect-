import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';

class ShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ShellScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: _GlassTabBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          HapticFeedback.lightImpact();
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _GlassTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GlassTabBar({required this.currentIndex, required this.onTap});

  static const _tabs = [
    _TabItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _TabItem(icon: Icons.sim_card_outlined, activeIcon: Icons.sim_card_rounded, label: 'eSIMs'),
    _TabItem(icon: Icons.star_outline_rounded, activeIcon: Icons.star_rounded, label: 'Rewards'),
    _TabItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.85),
            border: const Border(
              top: BorderSide(
                color: AppColors.surfaceBorder,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                10,
                AppSpacing.base,
                2,
              ),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final tab = _tabs[index];
                  final isSelected = index == currentIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(index),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              if (isSelected)
                                Container(
                                  width: 40,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: AppColors.accent.withValues(alpha: 0.12),
                                  ),
                                ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  isSelected ? tab.activeIcon : tab.icon,
                                  key: ValueKey('${index}_$isSelected'),
                                  size: 22,
                                  color: isSelected
                                      ? AppColors.accent
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.textTertiary,
                              fontFamily: '.SF Pro Text',
                            ),
                            child: Text(tab.label),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
