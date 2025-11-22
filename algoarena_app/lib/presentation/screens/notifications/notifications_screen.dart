import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/utils/animation_lifecycle_mixin.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin, AnimationLifecycleMixin {
  late AnimationController _bubblesController;
  late AnimationController _listController;
  late AnimationController _headerController;
  
  @override
  List<AnimationController> get animationControllers => [
    _bubblesController,
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Animated bubbles in background
    _bubblesController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    // Staggered list animation
    _listController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Header slide animation
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _headerController.forward();
    _listController.forward();
  }
  
  @override
  void dispose() {
    _bubblesController.dispose();
    _listController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated Bubbles Background - matching Figma (377:1466)
          AnimatedBuilder(
            animation: _bubblesController,
            builder: (context, child) {
              return Stack(
                children: [
                  // Large yellow bubble - top left with floating animation
                  Positioned(
                    left: -179.79 + math.sin(_bubblesController.value * 2 * math.pi) * 20,
                    top: -276.58 + math.cos(_bubblesController.value * 2 * math.pi) * 15,
                    child: Transform.rotate(
                      angle: _bubblesController.value * 2 * math.pi * 0.5,
                      child: Container(
                        width: 550.345,
                        height: 512.152,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFFD700).withOpacity(0.25),
                              const Color(0xFFFFD700).withOpacity(0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Black/dark bubble - rotating with breathing effect
                  Positioned(
                    left: -97.03,
                    top: -298.88 + math.sin(_bubblesController.value * 2 * math.pi * 0.7) * 25,
                    child: Transform.rotate(
                      angle: 232 * math.pi / 180 + _bubblesController.value * 2 * math.pi * 0.3,
                      child: Transform.scale(
                        scale: 1.0 + math.sin(_bubblesController.value * 2 * math.pi) * 0.05,
                        child: Container(
                          width: 442.65,
                          height: 402.871,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated Header with back button and title
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _headerController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.black, Color(0xFFFFD700)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Back button with ripple effect
                        Positioned(
                          left: 10,
                          top: 20,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => Navigator.pop(context),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Title - "Notifications"
                        const Positioned(
                          left: 67,
                          top: 58,
                          child: Text(
                            'Notifications',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Raleway',
                              fontSize: 50,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.52,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Scrollable content with sections
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Announcement Section
                        _buildSectionHeader('Announcement :', 0),
                        const SizedBox(height: 11),
                        _buildNotificationsList([
                          'Monthly meeting schedule for November is now available.',
                          'Attendance policy updated — please read the new guidelines.',
                        ], 0),
                        
                        const SizedBox(height: 10),
                        _buildSeeMoreButton(2),
                        
                        const SizedBox(height: 20),
                        
                        // News Section  
                        _buildSectionHeader('News :', 3),
                        const SizedBox(height: 11),
                        _buildNotificationsList([
                          'Leo Club of Colombo recognized as Best Community Service Club 2025!',
                        ], 3),
                        
                        const SizedBox(height: 10),
                        _buildSeeMoreButton(4),
                        
                        const SizedBox(height: 20),
                        
                        // Notifications Section
                        _buildSectionHeader('Notifications :', 5),
                        const SizedBox(height: 11),
                        _buildNotificationsList([
                          'Membership renewal due soon. Don\'t forget to renew before Nov 15',
                          'New message from Club President.',
                        ], 5),
                        
                        const SizedBox(height: 10),
                        _buildSeeMoreButton(7),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Bar Indicator
                Center(
                  child: Container(
                    width: 145.848,
                    height: 5.442,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(34),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, int animationIndex) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _listController,
        curve: Interval(
          animationIndex * 0.08,
          animationIndex * 0.08 + 0.3,
          curve: Curves.easeOut,
        ),
      ),
    );
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-30 * (1 - animation.value), 0),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Raleway',
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          height: 32 / 26,
        ),
      ),
    );
  }
  
  Widget _buildNotificationsList(List<String> items, int startIndex) {
    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final text = entry.value;
        final overallIndex = startIndex + index;
        
        // Staggered animation for each item
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _listController,
            curve: Interval(
              overallIndex * 0.08,
              overallIndex * 0.08 + 0.4,
              curve: Curves.easeOut,
            ),
          ),
        );
        
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - animation.value)),
              child: Opacity(
                opacity: animation.value,
                child: child,
              ),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Handle notification tap
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(text),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 332,
                height: 66,
                margin: const EdgeInsets.only(bottom: 11),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0x1A000000), // rgba(0,0,0,0.1)
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    // Avatar circle with Leo logo
                    Hero(
                      tag: 'notification_avatar_$overallIndex',
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFD700).withOpacity(0.3),
                          border: Border.all(
                            color: const Color(0xFFFFD700),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          size: 24,
                          color: Color(0xFF8F7902),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 15),
                    
                    // Notification text
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 12 / 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildSeeMoreButton(int animationIndex) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _listController,
        curve: Interval(
          animationIndex * 0.08,
          animationIndex * 0.08 + 0.3,
          curve: Curves.easeOut,
        ),
      ),
    );
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: Material(
        color: const Color(0xFFE6E6E6),
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          onTap: () {
            // Animate and show more notifications
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Loading more...'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          splashColor: const Color(0xFFFFD700).withOpacity(0.3),
          highlightColor: const Color(0xFFFFD700).withOpacity(0.1),
          child: Container(
            width: 332,
            height: 39,
            alignment: Alignment.center,
            child: const Text(
              'See more...',
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 31 / 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
