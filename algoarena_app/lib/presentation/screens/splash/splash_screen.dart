import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../data/repositories/auth_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Single smooth animation controller
  late AnimationController _morphController;
  late AnimationController _dotsRotationController;
  late AnimationController _fadeOutController;
  
  // Smooth interpolation animations for exact Figma positions
  late Animation<double> _lionLeftAnimation;    // -310 -> 101 (Figma px)
  late Animation<double> _lionTopAnimation;     // -5 -> 0 (Figma px)
  late Animation<double> _lionWidthAnimation;   // 736 -> 353 (Figma px)
  late Animation<double> _lionHeightAnimation;  // 884 -> 424 (Figma px)
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _dotsRotationAnimation;
  late Animation<double> _screenFadeAnimation;
  
  final _authRepository = AuthRepository();

  // Figma exact colors for the 4 dots
  static const Color _blueColor = Color(0xFF004CFF);
  static const Color _yellowColor = Color(0xFFFCB700);
  static const Color _greenColor = Color(0xFF00D390);
  static const Color _pinkColor = Color(0xFFF43098);
  
  // Figma design dimensions (based on 402px width screen)
  static const double _figmaScreenWidth = 402.0;
  static const double _figmaScreenHeight = 874.0;

  @override
  void initState() {
    super.initState();
    
    // Main morph controller - smooth continuous transition
    _morphController = AnimationController(
      duration: const Duration(milliseconds: 2500), // 2.5 seconds smooth morph
      vsync: this,
    );
    
    // EXACT Figma positions - smooth interpolation
    // Frame 1: left=-310, top=-5, width=736, height=884
    // Frame 2: left=101, top=0, width=353, height=424
    
    _lionLeftAnimation = Tween<double>(
      begin: -310.0,  // Frame 1: left=-310px
      end: 101.0,     // Frame 2: left=101px
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOutCubic,
    ));
    
    _lionTopAnimation = Tween<double>(
      begin: -5.0,    // Frame 1: top=-5px
      end: 0.0,       // Frame 2: top=0px
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOutCubic,
    ));
    
    _lionWidthAnimation = Tween<double>(
      begin: 736.0,   // Frame 1: width=736px
      end: 353.0,     // Frame 2: width=353px
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOutCubic,
    ));
    
    _lionHeightAnimation = Tween<double>(
      begin: 884.0,   // Frame 1: height=884px
      end: 424.0,     // Frame 2: height=424px
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOutCubic,
    ));
    
    // Logo opacity: hidden while lion moves, then fades in
    _logoOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.0), weight: 70),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_morphController);
    
    // Dots rotation - continuous buffering
    _dotsRotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    
    _dotsRotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _dotsRotationController, curve: Curves.linear),
    );
    
    // Screen fade out
    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _screenFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeInOut),
    );
    
    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    // Brief pause before starting
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Smooth morph from Frame 1 to Frame 2
    await _morphController.forward();
    
    // Stay at Frame 2 for a moment
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Check authentication
    bool isAuthenticated = false;
    try {
      if (await _authRepository.isAuthenticated()) {
        await _authRepository.getCurrentUser();
        isAuthenticated = true;
      }
    } catch (e) {
      await _authRepository.logout();
      isAuthenticated = false;
    }
    
    if (mounted) {
      await _fadeOutController.forward();
      Navigator.pushReplacementNamed(
        context,
        isAuthenticated ? '/home' : '/login',
      );
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    _dotsRotationController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Scale factor to convert Figma px to device px
    final scaleX = screenWidth / _figmaScreenWidth;
    final scaleY = screenHeight / _figmaScreenHeight;
    
    return Scaffold(
      body: FadeTransition(
        opacity: _screenFadeAnimation,
        child: AnimatedBuilder(
          animation: _morphController,
          builder: (context, child) {
            final progress = _morphController.value;
            
            // Background smoothly transitions from Frame 1 gray to Frame 2 white
            final backgroundColor = Color.lerp(
              const Color(0xFFF8F8F8), // Frame 1: rgba(248,248,248,0.98)
              Colors.white,            // Frame 2: white
              progress,
            )!;
            
            // Calculate exact positions scaled to device
            final lionLeft = _lionLeftAnimation.value * scaleX;
            final lionTop = _lionTopAnimation.value * scaleY;
            final lionWidth = _lionWidthAnimation.value * scaleX;
            final lionHeight = _lionHeightAnimation.value * scaleY;
            
            return Container(
              color: backgroundColor,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Lion Image - exact Figma positions smoothly interpolated
                  Positioned(
                    left: lionLeft,
                    top: lionTop,
                    width: lionWidth,
                    height: lionHeight,
                    child: Image.asset(
                      'assets/images/lion_frame1.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  // Logos - appear after lion reaches Frame 2
                  Positioned(
                    left: 0,
                    right: 0,
                    top: screenHeight * 0.54,
                    child: Opacity(
                      opacity: _logoOpacityAnimation.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logo_text.png',
                            height: 64,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            'assets/images/logo_icon.png',
                            height: 64,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 4-Color Dots - Continuous buffering rotation
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: screenHeight * 0.12,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _dotsRotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _dotsRotationAnimation.value,
                            child: _buildFourColorDots(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  /// Builds the 4-color dots grid exactly as in Figma
  Widget _buildFourColorDots() {
    const double dotSize = 13.0;
    const double spacing = 7.0;
    
    return SizedBox(
      width: dotSize * 2 + spacing,
      height: dotSize * 2 + spacing,
      child: Stack(
        children: [
          Positioned(left: 0, top: 0, child: _buildDot(_blueColor, dotSize)),
          Positioned(right: 0, top: 0, child: _buildDot(_pinkColor, dotSize)),
          Positioned(left: 0, bottom: 0, child: _buildDot(_yellowColor, dotSize)),
          Positioned(right: 0, bottom: 0, child: _buildDot(_greenColor, dotSize)),
        ],
      ),
    );
  }
  
  Widget _buildDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
