import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/forgot_password_widgets.dart';

/// Password Reset Success Screen
/// Uses the same design as Account Created success screen
class PasswordResetSuccessScreen extends StatefulWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  State<PasswordResetSuccessScreen> createState() =>
      _PasswordResetSuccessScreenState();
}

class _PasswordResetSuccessScreenState extends State<PasswordResetSuccessScreen>
    with TickerProviderStateMixin {
  // Success content staggered slide up animations
  late AnimationController _successIconController;
  late AnimationController _successTextController;
  late AnimationController _successCheckController;
  late AnimationController _successGlowController;
  late AnimationController _successTitleController;
  late AnimationController _successBubbleRotationController;

  late Animation<Offset> _successIconSlideAnimation;
  late Animation<double> _successTextFadeAnimation;
  late Animation<double> _successCheckScaleAnimation;
  late Animation<double> _successCheckFadeAnimation;
  late Animation<double> _successCheckRotationAnimation;
  late Animation<double> _successGlowAnimation;
  late Animation<double> _successTitleFadeAnimation;
  late Animation<Offset> _successTitleSlideAnimation;
  late Animation<double> _successSubtitleFadeAnimation;
  late Animation<double> _successBubble1RotationAnimation;
  late Animation<double> _successBubble2RotationAnimation;
  late Animation<Offset> _successCardSlideAnimation;
  late Animation<double> _successCardScaleAnimation;

  @override
  void initState() {
    super.initState();
    // Hide status bar to remove white bar at top
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ));
    
    _setupAnimations();
    _startAnimations();
    _autoRedirectToLogin();
  }

  void _setupAnimations() {
    // Success content staggered slide up animations
    _successIconController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _successIconSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5), // Slide up from bottom
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _successIconController, curve: Curves.easeOutCubic),
    );

    _successTextController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _successTextFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successTextController, curve: Curves.easeIn),
    );

    // Success check mark animation (modern with bounce)
    _successCheckController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _successCheckScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_successCheckController);

    _successCheckFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successCheckController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _successCheckRotationAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _successCheckController,
        curve: Curves.easeOut,
      ),
    );

    // Success glow animation
    _successGlowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _successGlowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _successGlowController, curve: Curves.easeInOut),
    );

    // Success title animation
    _successTitleController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _successTitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successTitleController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _successTitleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _successTitleController,
        curve: Curves.easeOutCubic,
      ),
    );

    _successSubtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successTitleController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    // Success bubble rotation animation
    _successBubbleRotationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Success bubbles use the same bubbles as forgot password screen
    // Start from password state angles and rotate slightly
    // Yellow bubble: -0.5 + 1.9 = 1.4 radians (from password state)
    // Black bubble: 0.3 - 1.8 = -1.5 radians (from password state)
    _successBubble1RotationAnimation = Tween<double>(
      begin: -0.5 + 1.9, // Yellow bubble from password state
      end: -0.5 + 1.9 + 0.2, // Rotate slightly more
    ).animate(
      CurvedAnimation(parent: _successBubbleRotationController, curve: Curves.easeInOutCubic),
    );

    _successBubble2RotationAnimation = Tween<double>(
      begin: 0.3 - 1.8, // Black bubble from password state
      end: 0.3 - 1.8 - 0.2, // Rotate slightly more
    ).animate(
      CurvedAnimation(parent: _successBubbleRotationController, curve: Curves.easeInOutCubic),
    );

    // Success card slide animation with scale
    _successCardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _successTextController,
        curve: Curves.easeOutCubic,
      ),
    );

    _successCardScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.02)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.02, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_successTextController);
  }

  void _startAnimations() {
    // Start success bubble rotation
    _successBubbleRotationController.forward();

    // Modern staggered animations
    _successIconController.forward();
    _successCheckController.forward();
    _successTextController.forward();
    _successTitleController.forward();
    _successGlowController.repeat();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _successTextController.forward();
      }
    });
  }

  void _autoRedirectToLogin() {
    // Wait 2 seconds before automatically navigating to login (like registration)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _navigateToLogin();
      }
    });
  }

  @override
  void dispose() {
    // Restore system UI
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ));
    _successIconController.dispose();
    _successTextController.dispose();
    _successCheckController.dispose();
    _successBubbleRotationController.dispose();
    _successTitleController.dispose();
    _successGlowController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive utilities
    ResponsiveUtils.init(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Blurred background with dark overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF5F5F5),
                    Color(0xFFFFFFFF),
                    Color(0xFFF0F9FF),
                  ],
                ),
              ),
            ),
          ),
          // Dark overlay for darker blur effect
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          // Content
          SafeArea(
            bottom: false,
            top: false,
            child: Stack(
              children: [
                // Success Screen Bubbles with rotation animation (using forgot password bubbles)
                AnimatedBuilder(
                  animation: _successBubble1RotationAnimation,
                  builder: (context, child) {
                    return Positioned(
                      left: ResponsiveUtils.bw(-50),
                      top: ResponsiveUtils.bh(-180),
                      child: Transform.rotate(
                        angle: _successBubble1RotationAnimation.value,
                        child: CustomPaint(
                          size: Size(ResponsiveUtils.bs(500), ResponsiveUtils.bs(550)),
                          painter: YellowBubblePainter(),
                        ),
                      ),
                    );
                  },
                ),

                AnimatedBuilder(
                  animation: _successBubble2RotationAnimation,
                  builder: (context, child) {
                    return Positioned(
                      left: ResponsiveUtils.bw(-80),
                      top: ResponsiveUtils.bh(-120),
                      child: Transform.rotate(
                        angle: _successBubble2RotationAnimation.value,
                        child: CustomPaint(
                          size: Size(ResponsiveUtils.bs(380), ResponsiveUtils.bs(420)),
                          painter: BlackBubblePainter(),
                        ),
                      ),
                    );
                  },
                ),

                // Main content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Modern check icon with glow animation
                    SlideTransition(
                      position: _successIconSlideAnimation,
                      child: FadeTransition(
                        opacity: _successCheckFadeAnimation,
                        child: AnimatedBuilder(
                          animation: _successGlowController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _successCheckRotationAnimation.value,
                              child: Transform.scale(
                                scale: _successCheckScaleAnimation.value,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Subtle ripple effect
                                    ...List.generate(2, (index) {
                                      final delay = index * 0.5;
                                      final rippleValue = ((_successGlowAnimation.value + delay) % 1.0);
                                      final scale = 1.0 + (rippleValue * 0.3);
                                      final opacity = (1.0 - rippleValue).clamp(0.0, 0.3);

                                      return Transform.scale(
                                        scale: scale,
                                        child: Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFF4CAF50).withOpacity(opacity),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                    // Pulsing glow effect
                                    Container(
                                      width: 140 + (_successGlowAnimation.value * 20),
                                      height: 140 + (_successGlowAnimation.value * 20),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            const Color(0xFF4CAF50).withOpacity(_successGlowAnimation.value * 0.2),
                                            const Color(0xFF4CAF50).withOpacity(0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Main checkmark circle
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF66BB6A),
                                            Color(0xFF4CAF50),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF4CAF50).withOpacity(0.3 + _successGlowAnimation.value * 0.2),
                                            blurRadius: 25 + (_successGlowAnimation.value * 10),
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        size: 70,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Modern success card with enhanced design
                    SlideTransition(
                      position: _successCardSlideAnimation,
                      child: ScaleTransition(
                        scale: _successCardScaleAnimation,
                        child: FadeTransition(
                          opacity: _successTextFadeAnimation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Color(0xFFFAFAFA),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 30,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                                    blurRadius: 20,
                                    spreadRadius: -5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: const EdgeInsets.all(36),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Animated title
                                        SlideTransition(
                                          position: _successTitleSlideAnimation,
                                          child: FadeTransition(
                                            opacity: _successTitleFadeAnimation,
                                            child: const Text(
                                              'Password Reset\nSuccessfully!',
                                              style: TextStyle(
                                                fontFamily: 'Raleway',
                                                fontSize: 42,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF1A1A1A),
                                                letterSpacing: -1,
                                                height: 1.2,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 16),

                                        // Animated gradient line
                                        AnimatedBuilder(
                                          animation: _successTitleController,
                                          builder: (context, child) {
                                            final width = 80 * _successTitleFadeAnimation.value;
                                            return Container(
                                              height: 5,
                                              width: width,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(3),
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFF4CAF50),
                                                    Color(0xFF66BB6A),
                                                    Color(0xFF81C784),
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF4CAF50).withOpacity(0.4),
                                                    blurRadius: 8,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),

                                        const SizedBox(height: 24),

                                        // Animated welcome message
                                        FadeTransition(
                                          opacity: _successSubtitleFadeAnimation,
                                          child: Column(
                                            children: [
                                              const Text(
                                                'Welcome to',
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF666666),
                                                  letterSpacing: 0.5,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 4),
                                              ShaderMask(
                                                shaderCallback: (bounds) => const LinearGradient(
                                                  colors: [
                                                    Color(0xFF4CAF50),
                                                    Color(0xFF66BB6A),
                                                  ],
                                                ).createShader(bounds),
                                                child: const Text(
                                                  'Leo Connect',
                                                  style: TextStyle(
                                                    fontFamily: 'Nunito Sans',
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                    letterSpacing: 0.5,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 16),

                                        // Animated description
                                        FadeTransition(
                                          opacity: _successSubtitleFadeAnimation,
                                          child: const Text(
                                            'Your password has been changed\nsuccessfully.',
                                            style: TextStyle(
                                              fontFamily: 'Nunito Sans',
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF666666),
                                              height: 1.6,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),

                                        const SizedBox(height: 32),

                                        // Modern loading indicator
                                        FadeTransition(
                                          opacity: _successSubtitleFadeAnimation,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      Color(0xFF4CAF50),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Redirecting to login...',
                                                  style: TextStyle(
                                                    fontFamily: 'Nunito Sans',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF4CAF50),
                                                    letterSpacing: 0.3,
                                                  ),
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
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

