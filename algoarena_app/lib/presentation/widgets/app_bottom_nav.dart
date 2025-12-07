import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/colors.dart';
import '../../utils/responsive_utils.dart';

class AppBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onTabChanged;
  
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.onTabChanged,
  });

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> with SingleTickerProviderStateMixin {
  final int _tabCount = 5;
  AnimationController? _zoomController;
  Animation<double>? _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _zoomAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _zoomController!,
        curve: Curves.easeOutBack,
      ),
    );
    // Start animation if a tab is already selected
    if (widget.currentIndex >= 0) {
      _zoomController?.forward();
    }
  }

  @override
  void didUpdateWidget(AppBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Reset and animate when tab changes
      _zoomController?.reset();
      _zoomController?.forward();
    }
  }

  @override
  void dispose() {
    _zoomController?.dispose();
    super.dispose();
  }

  Widget _getInactiveIcon(int index, double size, Color color) {
    switch (index) {
      case 0:
        return SizedBox(
          width: size,
          height: size,
          child: SvgPicture.asset(
            'assets/images/icons/home.svg',
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            fit: BoxFit.contain,
          ),
        );
      case 1:
        return SizedBox(
          width: size,
          height: size,
          child: SvgPicture.asset(
            'assets/images/icons/search.svg',
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            fit: BoxFit.contain,
          ),
        );
      case 2:
        return SizedBox(
          width: size,
          height: size,
          child: SvgPicture.asset(
            'assets/images/icons/events.svg',
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            fit: BoxFit.contain,
          ),
        );
      case 3:
        return SizedBox(
          width: size,
          height: size,
          child: SvgPicture.asset(
            'assets/images/icons/pages.svg',
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            fit: BoxFit.contain,
          ),
        );
      case 4:
        return SizedBox(
          width: size,
          height: size,
          child: SvgPicture.asset(
            'assets/images/icons/user.svg',
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            fit: BoxFit.contain,
          ),
        );
      default:
        return SizedBox(
          width: size,
          height: size,
          child: SvgPicture.asset(
            'assets/images/icons/home.svg',
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            fit: BoxFit.contain,
          ),
        );
    }
  }

  Widget _getActiveIcon(int index, double size, Color color) {
    switch (index) {
      case 0:
        return SizedBox(
          width: size,
          height: size,
          child: SvgPicture.asset(
            'assets/images/icons/home.svg',
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            fit: BoxFit.contain,
          ),
        );
      case 1:
        return SizedBox(
          width: size,
          height: size,
          child: SvgPicture.asset(
            'assets/images/icons/search.svg',
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            fit: BoxFit.contain,
          ),
        );
      case 2:
        return SizedBox(
          width: size,
          height: size,
          child: SvgPicture.asset(
            'assets/images/icons/events.svg',
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            fit: BoxFit.contain,
          ),
        );
      case 3:
        return SizedBox(
          width: size,
          height: size,
          child: SvgPicture.asset(
            'assets/images/icons/pages.svg',
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            fit: BoxFit.contain,
        ),
      );
      case 4:
        return SizedBox(
          width: size,
          height: size,
          child: SvgPicture.asset(
            'assets/images/icons/user.svg',
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            fit: BoxFit.contain,
          ),
        );
      default:
        return SizedBox(
          width: size,
          height: size,
          child: SvgPicture.asset(
            'assets/images/icons/home.svg',
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            fit: BoxFit.contain,
          ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    
    final responsiveNavBarHeight = ResponsiveUtils.dp(kBottomNavigationBarHeight + 26);
    
    // Each icon has its own background that highlights when active
    return Container(
      height: responsiveNavBarHeight + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _tabCount,
            (index) => Expanded(
              child: InkWell(
                onTap: () => widget.onTabChanged?.call(index),
                child: Container(
                  height: responsiveNavBarHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Golden background under icon for active tab
                      if (widget.currentIndex == index)
                        _zoomAnimation != null
                            ? AnimatedBuilder(
                                animation: _zoomAnimation!,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _zoomAnimation!.value,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: ResponsiveUtils.iconSize + ResponsiveUtils.dp(28),
                                          height: ResponsiveUtils.iconSize + ResponsiveUtils.dp(28),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFB8860B).withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        // Dot indicator inside the background circle
                                        Positioned(
                                          bottom: ResponsiveUtils.dp(3),
                                          child: Container(
                                            width: ResponsiveUtils.dp(6),
                                            height: ResponsiveUtils.dp(6),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(255, 109, 78, 1),
                                              shape: BoxShape.circle,
        ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: ResponsiveUtils.iconSize + ResponsiveUtils.dp(28),
                                    height: ResponsiveUtils.iconSize + ResponsiveUtils.dp(28),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFB8860B).withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  // Dot indicator inside the background circle
                                  Positioned(
                                    bottom: ResponsiveUtils.dp(3),
                                    child: Container(
                                      width: ResponsiveUtils.dp(6),
                                      height: ResponsiveUtils.dp(6),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 109, 78, 1),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      // Icon stays centered
                      widget.currentIndex == index
                          ? _getActiveIcon(
                              index,
                              ResponsiveUtils.iconSize + ResponsiveUtils.dp(8),
                              const Color.fromARGB(255, 252, 197, 57),
                            )
                          : _getInactiveIcon(
                              index,
                              ResponsiveUtils.iconSize + ResponsiveUtils.dp(8),
                              AppColors.textHint,
          ),
                    ],
        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

