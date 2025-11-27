import 'package:flutter/material.dart';
import 'user_model.dart';

/// Side Menu Dropdown Widget
/// 
/// Features:
/// - Full-screen yellow background (90% opacity)
/// - Content slides 33% to the left when menu opens
/// - Menu slides up from the bottom with fade animation
/// - Menu items aligned to the right
/// - Transparent white background cards for menu items
/// - Gradient gold icon circles
/// - Smooth animations and transitions
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
  late Animation<Offset> _contentSlideAnimation;
  late Animation<Offset> _menuSlideAnimation;
  late Animation<double> _menuFadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Content slides to the left (partially visible on left side)
    _contentSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.33, 0), // Slide 33% to the left (showing on left side)
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Menu slides up from the bottom
    _menuSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0), // Start from bottom
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _menuFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    if (widget.isOpen) {
      _controller.forward();
      // Notify immediately and also after frame
      widget.onMenuStateChanged?.call(true);
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
        _controller.forward();
      } else {
        _controller.reverse();
      }
      // Always notify immediately and after frame
      widget.onMenuStateChanged?.call(widget.isOpen);
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
                  color: const Color(0xFFFFD700).withOpacity(_controller.value * 0.9), // 90% opacity (slightly transparent)
                ),
              ),
            );
          },
        ),
        
        // Main content that slides left (on top of yellow background)
        Positioned.fill(
          child: SlideTransition(
            position: _contentSlideAnimation,
            child: widget.child,
          ),
        ),
        
        // Menu content - positioned on top of everything (must be last in Stack)
        if (widget.isOpen || _controller.value > 0)
          SlideTransition(
            position: _menuSlideAnimation,
            child: FadeTransition(
              opacity: _menuFadeAnimation,
              child: IgnorePointer(
                ignoring: _controller.value == 0,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent, // Transparent so yellow background shows through
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Close button - top right
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0, right: 16.0),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.black, size: 24),
                                onPressed: widget.onClose,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Menu items - aligned to the right
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 24.0, left: 40.0, top: 40.0, bottom: 40.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildMenuItem(
                                  context,
                                  'About District 306',
                                  Icons.help_outline,
                                  () {
                                    if (context.mounted) {
                                      Navigator.pushNamed(context, '/about');
                                    }
                                  },
                                ),
                                const SizedBox(height: 24),
                                _buildMenuItem(
                                  context,
                                  'Executive Committee',
                                  Icons.people_outline,
                                  () {
                                    if (context.mounted) {
                                      Navigator.pushNamed(context, '/executive');
                                    }
                                  },
                                ),
                                const SizedBox(height: 24),
                                _buildMenuItem(
                                  context,
                                  'LeoAssist',
                                  Icons.chat_bubble_outline,
                                  () {
                                    if (context.mounted) {
                                      Navigator.pushNamed(context, '/leo-assist');
                                    }
                                  },
                                ),
                                const SizedBox(height: 24),
                                _buildMenuItem(
                                  context,
                                  'Contact Us',
                                  Icons.phone_outlined,
                                  () {
                                    if (context.mounted) {
                                      Navigator.pushNamed(context, '/contact');
                                    }
                                  },
                                ),
                                const SizedBox(height: 24),
                                _buildMenuItem(
                                  context,
                                  'Settings',
                                  Icons.settings_outlined,
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        onTap: () async {
          // Close menu first
          widget.onClose();
          // Wait for menu to close, then navigate
          await Future.delayed(const Duration(milliseconds: 300));
          // Ensure context is still valid before navigating
          if (context.mounted) {
            onTap();
          }
        },
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.black.withOpacity(0.15),
        highlightColor: Colors.black.withOpacity(0.08),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75), // More transparent white background
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'Nunito Sans',
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(width: 18),
              Container(
                width: 52,
                height: 52,
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
                child: Icon(
                  icon,
                  color: Colors.black,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

