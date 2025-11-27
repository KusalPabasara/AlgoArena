import 'package:flutter/material.dart';
import 'colors.dart';

/// Bottom Navigation Bar Widget
/// 
/// Features:
/// - Active tab has a yellow circle with gold icon and black bar
/// - Inactive tabs show outlined icons
/// - Smooth animation when switching tabs
/// - No text labels under icons
/// - Static navbar that stays in place
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTabChanged;
  
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.onTabChanged,
  });

  // Build icon with highlight circle for active tab
  Widget _buildIconWithHighlight(IconData icon, IconData activeIcon, bool isActive) {
    if (isActive) {
      // Active state: circle with icon and bar inside
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFFF9C4), // Light yellow background
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              activeIcon,
              size: 28,
              color: const Color(0xFFFFD700), // Gold color
            ),
            const SizedBox(height: 4),
            // Small black bar inside the circle, below the icon (shorter length)
            Container(
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.black, // Black color
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ),
      );
    } else {
      // Inactive state: just the icon
      return Icon(
        icon,
        size: 30,
        color: AppColors.textHint,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (currentIndex == index) return; // Don't navigate if already on the tab
        onTabChanged?.call(index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
          icon: _buildIconWithHighlight(
            Icons.home_rounded,
            Icons.home_rounded,
            currentIndex == 0,
          ),
          activeIcon: _buildIconWithHighlight(
            Icons.home_rounded,
            Icons.home_rounded,
            true,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: _buildIconWithHighlight(
            Icons.explore_outlined,
            Icons.explore,
            currentIndex == 1,
          ),
          activeIcon: _buildIconWithHighlight(
            Icons.explore_outlined,
            Icons.explore,
            true,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: _buildIconWithHighlight(
            Icons.calendar_today_outlined,
            Icons.calendar_today,
            currentIndex == 2,
          ),
          activeIcon: _buildIconWithHighlight(
            Icons.calendar_today_outlined,
            Icons.calendar_today,
            true,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: _buildIconWithHighlight(
            Icons.dashboard_outlined,
            Icons.dashboard,
            currentIndex == 3,
          ),
          activeIcon: _buildIconWithHighlight(
            Icons.dashboard_outlined,
            Icons.dashboard,
            true,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: _buildIconWithHighlight(
            Icons.account_circle_outlined,
            Icons.account_circle,
            currentIndex == 4,
          ),
          activeIcon: _buildIconWithHighlight(
            Icons.account_circle_outlined,
            Icons.account_circle,
            true,
          ),
          label: '',
        ),
      ],
    );
  }
}

