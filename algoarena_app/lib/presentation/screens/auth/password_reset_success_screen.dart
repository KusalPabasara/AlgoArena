import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../utils/responsive_utils.dart';

/// Password Reset Success Screen
/// Uses the same design as register success popup
class PasswordResetSuccessScreen extends StatefulWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  State<PasswordResetSuccessScreen> createState() =>
      _PasswordResetSuccessScreenState();
}

class _PasswordResetSuccessScreenState extends State<PasswordResetSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _cardController;
  late AnimationController _glowController;
  late AnimationController _bubbleController;

  late Animation<double> _checkScaleAnimation;
  late Animation<double> _checkFadeAnimation;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _cardFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _bubble1RotationAnimation;
  late Animation<double> _bubble2RotationAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Check icon controller
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Card controller
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Glow controller - continuous
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Bubble controller
    _bubbleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    // Animations
    _checkScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    _checkFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeIn),
    );

    _cardScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );

    _cardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeIn),
    );

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _bubble1RotationAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.linear),
    );

    _bubble2RotationAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.linear),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _checkController.forward();
        _glowController.repeat(reverse: true);
        _bubbleController.repeat();
      }
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _cardController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _cardController.dispose();
    _glowController.dispose();
    _bubbleController.dispose();
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
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          // Animated bubbles
          SafeArea(
            child: Stack(
              children: [
                // Yellow bubble (top-left)
                AnimatedBuilder(
                  animation: _bubble1RotationAnimation,
                  builder: (context, child) {
                    return Positioned(
                      left: ResponsiveUtils.bw(-100),
                      top: ResponsiveUtils.bh(-60),
                      child: Transform.rotate(
                        angle: _bubble1RotationAnimation.value * (3.14159 / 180),
                        child: Container(
                          width: ResponsiveUtils.bs(320),
                          height: ResponsiveUtils.bs(380),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(ResponsiveUtils.bs(200)),
                              topRight: Radius.circular(ResponsiveUtils.bs(200)),
                              bottomLeft: Radius.circular(ResponsiveUtils.bs(200)),
                              bottomRight: Radius.circular(ResponsiveUtils.bs(100)),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Black bubble (top-right)
                AnimatedBuilder(
                  animation: _bubble2RotationAnimation,
                  builder: (context, child) {
                    return Positioned(
                      right: ResponsiveUtils.bw(-150),
                      top: 0,
                      child: Transform.rotate(
                        angle: _bubble2RotationAnimation.value * (3.14159 / 180),
                        child: Container(
                          width: ResponsiveUtils.bs(320),
                          height: ResponsiveUtils.bs(380),
                          decoration: BoxDecoration(
                            color: const Color(0xFF02091A),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(ResponsiveUtils.bs(200)),
                              topRight: Radius.circular(ResponsiveUtils.bs(200)),
                              bottomLeft: Radius.circular(ResponsiveUtils.bs(100)),
                              bottomRight: Radius.circular(ResponsiveUtils.bs(200)),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated checkmark icon with glow
                      FadeTransition(
                        opacity: _checkFadeAnimation,
                        child: ScaleTransition(
                          scale: _checkScaleAnimation,
                          child: AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              final checkCircleSize = ResponsiveUtils.dp(120);
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Ripple effects
                                  ...List.generate(2, (index) {
                                    final delay = index * 0.5;
                                    final rippleValue = ((_glowAnimation.value + delay) % 1.0);
                                    final scale = 1.0 + (rippleValue * 0.3);
                                    final opacity = (1.0 - rippleValue).clamp(0.0, 0.3);

                                    return Transform.scale(
                                      scale: scale,
                                      child: Container(
                                        width: checkCircleSize,
                                        height: checkCircleSize,
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
                                  // Pulsing glow
                                  Container(
                                    width: ResponsiveUtils.dp(140) + (_glowAnimation.value * ResponsiveUtils.dp(20)),
                                    height: ResponsiveUtils.dp(140) + (_glowAnimation.value * ResponsiveUtils.dp(20)),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          const Color(0xFF4CAF50).withOpacity(_glowAnimation.value * 0.2),
                                          const Color(0xFF4CAF50).withOpacity(0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Main checkmark circle
                                  Container(
                                    width: checkCircleSize,
                                    height: checkCircleSize,
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
                                          color: const Color(0xFF4CAF50).withOpacity(0.3 + _glowAnimation.value * 0.2),
                                          blurRadius: 25 + (_glowAnimation.value * 10),
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.check_rounded,
                                      size: ResponsiveUtils.dp(70),
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: ResponsiveUtils.spacingXXL),

                      // Success card
                      SlideTransition(
                        position: _cardSlideAnimation,
                        child: ScaleTransition(
                          scale: _cardScaleAnimation,
                          child: FadeTransition(
                            opacity: _cardFadeAnimation,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUtils.spacingXL,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveUtils.buttonRadius,
                                  ),
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
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveUtils.buttonRadius,
                                  ),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      padding: EdgeInsets.all(
                                        ResponsiveUtils.spacingXL + ResponsiveUtils.spacingXS,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          ResponsiveUtils.buttonRadius,
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Title
                                          Text(
                                            'Password Reset\nSuccessfully!',
                                            style: TextStyle(
                                              fontFamily: 'Raleway',
                                              fontSize: ResponsiveUtils.headlineLarge,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF1A1A1A),
                                              letterSpacing: -0.5,
                                              height: 1.2,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),

                                          SizedBox(height: ResponsiveUtils.spacingM),

                                          // Animated gradient line
                                          AnimatedBuilder(
                                            animation: _cardController,
                                            builder: (context, child) {
                                              final width = ResponsiveUtils.dp(80) * _cardFadeAnimation.value;
                                              return Container(
                                                height: ResponsiveUtils.dp(5),
                                                width: width,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(
                                                    ResponsiveUtils.dp(3),
                                                  ),
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

                                          SizedBox(height: ResponsiveUtils.spacingL),

                                          // Subtitle
                                          Text(
                                            'Your password has been\nchanged successfully.',
                                            style: TextStyle(
                                              fontFamily: 'Nunito Sans',
                                              fontSize: ResponsiveUtils.bodyLarge + 2,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF666666),
                                              height: 1.5,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),

                                          SizedBox(height: ResponsiveUtils.spacingXL),

                                          // Login button
                                          SizedBox(
                                            width: double.infinity,
                                            height: ResponsiveUtils.buttonHeight,
                                            child: ElevatedButton(
                                              onPressed: _navigateToLogin,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF1A1A1A),
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(
                                                    ResponsiveUtils.inputRadius * 2,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                'Login',
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: ResponsiveUtils.bodyLarge + 2,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
