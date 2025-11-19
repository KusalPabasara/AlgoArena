import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import 'custom_icons.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  
  const AppBottomNav({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (currentIndex == index) return; // Don't navigate if already on the tab
        
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/search');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/pages');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      items: [
        BottomNavigationBarItem(
          icon: CustomIcons.calendar(
            size: 24,
            color: currentIndex == 0 ? AppColors.primary : AppColors.textHint,
          ),
          label: AppStrings.home,
        ),
        BottomNavigationBarItem(
          icon: CustomIcons.search(
            size: 24,
            color: currentIndex == 1 ? AppColors.primary : AppColors.textHint,
          ),
          label: AppStrings.search,
        ),
        BottomNavigationBarItem(
          icon: CustomIcons.pages(
            size: 28,
            color: currentIndex == 2 ? AppColors.primary : const Color(0xFF141B34),
          ),
          label: AppStrings.pages,
        ),
        BottomNavigationBarItem(
          icon: CustomIcons.profile(
            size: 24,
            color: currentIndex == 3 ? AppColors.primary : AppColors.textHint,
          ),
          label: AppStrings.profile,
        ),
      ],
    );
  }
}
