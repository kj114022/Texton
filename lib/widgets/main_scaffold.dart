import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';

/// Main scaffold with Twitter-style bottom navigation
class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(child: navigationShell),
          _buildBottomNavBar(context),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: CupertinoIcons.chat_bubble_2,
                activeIcon: CupertinoIcons.chat_bubble_2_fill,
                label: 'Feed',
                isSelected: navigationShell.currentIndex == 0,
                onTap: () => _onTap(0),
              ),
              _NavItem(
                icon: CupertinoIcons.search,
                activeIcon: CupertinoIcons.search,
                label: 'Search',
                isSelected: navigationShell.currentIndex == 1,
                onTap: () => _onTap(1),
              ),
              _NavItem(
                icon: CupertinoIcons.arrow_2_squarepath,
                activeIcon: CupertinoIcons.arrow_2_squarepath,
                label: 'Convert',
                isSelected: navigationShell.currentIndex == 2,
                onTap: () => _onTap(2),
              ),
              _NavItem(
                icon: CupertinoIcons.folder,
                activeIcon: CupertinoIcons.folder_fill,
                label: 'Library',
                isSelected: navigationShell.currentIndex == 3,
                onTap: () => _onTap(3),
              ),
              _NavItem(
                icon: CupertinoIcons.gear,
                activeIcon: CupertinoIcons.gear_solid,
                label: 'Settings',
                isSelected: navigationShell.currentIndex == 4,
                onTap: () => _onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.xBlue : AppColors.textSecondary,
              size: 26,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.xBlue : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
