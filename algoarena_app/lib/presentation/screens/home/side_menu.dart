import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/models/user.dart';
import '../../../utils/responsive_utils.dart';
import '../admin/leo_id_management_screen.dart';
import '../pages/create_page_screen.dart';

class SideMenu extends StatefulWidget {
  final User? user;
  final Widget child; // The content that will slide left
  final bool isOpen;
  final VoidCallback onClose;
  final ValueChanged<bool>? onMenuStateChanged; // Callback to notify parent about menu state
  
  const SideMenu({
    super.key,
    this.user,
    required this.child,
    required this.isOpen,
    required this.onClose,
    this.onMenuStateChanged,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _menuFadeAnimation;
  bool _isNavigating = false; // Prevent multiple navigation attempts

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Increased duration for smoother animation
    );

    _menuFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic, // Smoother curve for fade
      ),
    );

    // Reset navigation flag when menu animation completes (fully open)
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.isOpen) {
        // Menu is fully open, ensure navigation flag is reset
        if (mounted) {
          _isNavigating = false;
        }
      }
    });

    if (widget.isOpen) {
      _controller.forward();
      // Notify after frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onMenuStateChanged?.call(true);
      });
    }
  }

  @override
  void didUpdateWidget(SideMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        // Reset navigation flag immediately when menu opens to ensure tabs are always clickable
        _isNavigating = false;
        _controller.forward();
        // Also reset after animation starts to ensure it's definitely false
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.isOpen) {
            _isNavigating = false;
          }
        });
      } else {
        _controller.reverse();
      }
      // Always notify after frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onMenuStateChanged?.call(widget.isOpen);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    return Stack(
      clipBehavior: Clip.hardEdge, // Clip content that goes off-screen
      children: [
        // Yellow full-screen background layer (bottom layer) - slightly transparent
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return IgnorePointer(
              ignoring: _controller.value == 0,
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFFFFD700).withOpacity(_controller.value * 1), // 90% opacity (slightly transparent)
                ),
              ),
            );
          },
        ),
        
        // Main content that slides left AND down (on top of yellow background)
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Use smooth easing curve for content slide
              final easedValue = Curves.easeInOutCubic.transform(_controller.value);
              return Transform.translate(
                offset: Offset(
                  MediaQuery.of(context).size.width * -0.70 * easedValue,
                  MediaQuery.of(context).size.height * 0.25 * easedValue, // Smooth eased value
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.r(30)), // Rounded corners for home tab
            child: widget.child,
                ),
              );
            },
          ),
        ),
        
        // Menu content - positioned on top of everything (must be last in Stack)
        if (widget.isOpen || _controller.value > 0)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Calculate slide from right using eased value
              final easedValue = Curves.easeOutCubic.transform(_controller.value);
              final screenWidth = MediaQuery.of(context).size.width;
              return Transform.translate(
                offset: Offset(screenWidth * (1 - easedValue), 0), // Slide from right
                child: Opacity(
                  opacity: _menuFadeAnimation.value,
                  child: GestureDetector(
                    // Allow taps on menu items to pass through, but catch taps on empty space to close
                    onTap: () {
                      // Only close if tapping on empty space (not on menu items)
                      // Menu items will handle their own taps
                    },
                    behavior: HitTestBehavior.translucent,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent, // Transparent so yellow background shows through
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Close button - top right
                        Padding(
                              padding: EdgeInsets.only(
                                top: ResponsiveUtils.spacingM,
                                right: ResponsiveUtils.spacingM,
                              ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              width: ResponsiveUtils.dp(45),
                              height: ResponsiveUtils.dp(45),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
                              ),
                              child: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.black,
                                      size: ResponsiveUtils.iconSizeLarge,
                                    ),
                                onPressed: widget.onClose,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ),
                        ),

                            SizedBox(height: ResponsiveUtils.spacingL),

                        // Menu items - aligned to the right
                        Align(
                              alignment: Alignment.topRight,
                          child: Padding(
                                padding: EdgeInsets.only(
                                  right: ResponsiveUtils.spacingL,
                                  left: ResponsiveUtils.dp(40),
                                ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                            _buildMenuItem(
                              context,
                              'About District 306',
                              'assets/images/icons/about.svg',
                              () {
                                if (context.mounted) {
                                  Navigator.pushNamed(context, '/about');
                                }
                              },
                            ),
                            SizedBox(height: ResponsiveUtils.spacingL),
                            _buildMenuItem(
                              context,
                              'Executive Committee',
                              'assets/images/icons/executive_committee.svg',
                              () {
                                if (context.mounted) {
                                  Navigator.pushNamed(context, '/executive');
                                }
                              },
                            ),
                            SizedBox(height: ResponsiveUtils.spacingL),
                            _buildMenuItem(
                              context,
                              'LeoAssist',
                              'assets/images/icons/leo_assist.svg',
                              () {
                                if (context.mounted) {
                                  Navigator.pushNamed(context, '/leo-assist');
                                }
                              },
                            ),
                            SizedBox(height: ResponsiveUtils.spacingL),
                            _buildMenuItem(
                              context,
                              'Contact Us',
                              'assets/images/icons/contact_us.svg',
                              () {
                                if (context.mounted) {
                                  Navigator.pushNamed(context, '/contact');
                                }
                              },
                            ),
                            SizedBox(height: ResponsiveUtils.spacingL),
                            _buildMenuItem(
                              context,
                              'Settings',
                              'assets/images/icons/settings.svg',
                              () {
                                if (context.mounted) {
                                  Navigator.pushNamed(context, '/settings');
                                }
                              },
                            ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Admin menu items (only for super admin) pinned to bottom
                        if (widget.user?.isSuperAdmin == true)
                          Padding(
                            padding: EdgeInsets.only(
                              right: ResponsiveUtils.spacingL,
                              left: ResponsiveUtils.dp(40),
                              bottom: ResponsiveUtils.spacingL,
                            ),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildMenuItem(
                                    context,
                                    'Manage Leo IDs',
                                    'assets/images/icons/leo_id_management.svg',
                                    () {
                                      if (context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const LeoIdManagementScreen(),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  SizedBox(height: ResponsiveUtils.spacingL),
                                  _buildMenuItem(
                                    context,
                                    'Create Page',
                                    'assets/images/icons/create_page.svg',
                                    () {
                                      if (context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const CreatePageScreen(),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    String iconAsset,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        onTap: () {
          // Prevent rapid double-taps only (within 200ms)
          if (_isNavigating) {
            debugPrint('Navigation blocked: _isNavigating = $_isNavigating');
            return;
          }
          
          debugPrint('Menu item tapped: $title');
          
          // Set flag to prevent rapid double-taps
          _isNavigating = true;
          
          // Store the navigation callback
            final navigationCallback = onTap;
            
            // Close menu first
            widget.onClose();
            
          // Navigate immediately after a short delay to allow menu to start closing
          Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted && context.mounted) {
                  try {
                debugPrint('Navigating to: $title');
                    navigationCallback();
                  } catch (e) {
                    debugPrint('Navigation error: $e');
                  }
                }
            // Reset flag quickly to allow next navigation
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) {
                _isNavigating = false;
                debugPrint('Navigation flag reset');
              }
            });
          });
        },
        borderRadius: BorderRadius.circular(ResponsiveUtils.r(20)),
        splashColor: Colors.black.withOpacity(0.15),
        highlightColor: Colors.black.withOpacity(0.08),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.dp(1),
            vertical: 0,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.spacingM - 4,
            vertical: ResponsiveUtils.spacingS,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3), // More transparent white background
            borderRadius: BorderRadius.circular(ResponsiveUtils.r(20)),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.15),
            //     blurRadius: 12,
            //     offset: const Offset(0, 4),
            //     spreadRadius: 0,
            //   ),
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.08),
            //     blurRadius: 6,
            //     offset: const Offset(0, 2),
            //     spreadRadius: 0,
            //   ),
            // ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.bodyLarge,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'Nunito Sans',
                  letterSpacing: ResponsiveUtils.dp(0.5),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(width: ResponsiveUtils.spacingM + 2),
              Container(
                width: ResponsiveUtils.dp(52),
                height: ResponsiveUtils.dp(52),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFD700), // Gold
                      const Color(0xFFFFC107), // Amber
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 0),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconAsset,
                    width: iconAsset == 'assets/images/icons/contact_us.svg' 
                        ? ResponsiveUtils.iconSize + 3
                        : (iconAsset == 'assets/images/icons/leo_id_management.svg' || iconAsset == 'assets/images/icons/create_page.svg')
                            ? ResponsiveUtils.iconSize + 2
                            : ResponsiveUtils.iconSize + 6,
                    height: iconAsset == 'assets/images/icons/contact_us.svg'
                        ? ResponsiveUtils.iconSize + 3
                        : (iconAsset == 'assets/images/icons/leo_id_management.svg' || iconAsset == 'assets/images/icons/create_page.svg')
                            ? ResponsiveUtils.iconSize + 2
                            : ResponsiveUtils.iconSize + 6,
                    colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
