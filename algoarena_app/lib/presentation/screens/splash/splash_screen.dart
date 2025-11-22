import 'package:flutter/material.dart';
import 'dart:async';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/utils/animation_lifecycle_mixin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin, AnimationLifecycleMixin {
  late AnimationController _phase1Controller; // Lion only - left aligned
  late AnimationController _phase2Controller; // Lion moves to center + logo appears
  late AnimationController _dotsController;
  late AnimationController _transitionController;
  
  late Animation<double> _phase1FadeAnimation;
  late Animation<double> _phase2FadeAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _dotsPulseAnimation;
  late Animation<double> _screenFadeAnimation;
  
  final _authRepository = AuthRepository();
  
  @override
  List<AnimationController> get animationControllers => [
    _dotsController,
  ];

  @override
  void initState() {
    super.initState();
    
    // Phase 1: Lion appears on left (like Frame 1)
    _phase1Controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _phase1FadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _phase1Controller,
        curve: Curves.easeIn,
      ),
    );
    
    // Phase 2: Lion moves to center and logo appears (Frame 1 -> Frame 2)
    _phase2Controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _phase2FadeAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _phase2Controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _phase2Controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );
    
    // Dots pulse animation
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _dotsPulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _dotsController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Transition controller for fade out to login
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _screenFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: Curves.easeInOut,
      ),
    );
    
    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    // Phase 1: Show lion on left (Frame 1 - node-id=43-247)
    await _phase1Controller.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Phase 2: Smooth transition to centered layout with logo (Frame 2 - node-id=11-41)
    await _phase2Controller.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Check authentication - verify token is valid by trying to get user
    bool isAuthenticated = false;
    try {
      if (await _authRepository.isAuthenticated()) {
        // Token exists, but verify it's valid
        await _authRepository.getCurrentUser();
        isAuthenticated = true;
      }
    } catch (e) {
      // Token invalid or server unreachable, clear it and go to login
      await _authRepository.logout();
      isAuthenticated = false;
    }
    
    if (mounted) {
      // Fade out to login/home
      await _transitionController.forward();
      
      Navigator.pushReplacementNamed(
        context,
        isAuthenticated ? '/home' : '/login',
      );
    }
  }

  @override
  void dispose() {
    _phase1Controller.dispose();
    _phase2Controller.dispose();
    _dotsController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F8), // Frame 1 background color from Figma
      body: FadeTransition(
        opacity: _screenFadeAnimation,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([_phase1Controller, _phase2Controller]),
            builder: (context, child) {
              // Calculate if we're in phase 1 (lion left) or phase 2 (lion center + logo)
              final showPhase2 = _phase2Controller.value > 0;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                color: showPhase2 ? const Color(0xFFFFFFFF) : const Color(0xFFFAF8F8), // Transition from Frame 1 to Frame 2 background
                child: Stack(
                  children: [
                    // FRAME 1: Lion on left (initial state - Figma node-id=43-247)
                    if (!showPhase2)
                      Positioned.fill(
                        child: FadeTransition(
                          opacity: _phase1FadeAnimation,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Image.asset(
                                'assets/images/lion_frame1.png',
                                height: screenHeight * 0.75,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // FRAME 2: Lion centered at top + Logo below + Dots (Figma node-id=11-41)
                    if (showPhase2)
                      Positioned.fill(
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            
                            // Lion head at top center (from Figma Frame 2)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 50),
                              child: FadeTransition(
                                opacity: _phase2FadeAnimation,
                                child: Image.asset(
                                  'assets/images/lion_frame2.png',
                                  height: screenHeight * 0.48,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 10),
                            
                            // Logo section - text and icon side by side
                            FadeTransition(
                              opacity: _logoFadeAnimation,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
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
                            
                            const Spacer(),
                            
                            // Animated dots at bottom (matching Figma colors)
                            FadeTransition(
                              opacity: _logoFadeAnimation,
                              child: AnimatedBuilder(
                                animation: _dotsPulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _dotsPulseAnimation.value,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildDot(const Color(0xFFE91E63)), // Pink
                                        const SizedBox(width: 8),
                                        _buildDot(const Color(0xFF00BCD4)), // Cyan
                                        const SizedBox(width: 8),
                                        _buildDot(const Color(0xFF2196F3)), // Blue
                                        const SizedBox(width: 8),
                                        _buildDot(const Color(0xFFFFC107)), // Amber
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            
                            SizedBox(height: screenHeight * 0.15),
                          ],
                        ),
                      ),
                    
                    // Dots always visible at bottom during Frame 1
                    if (!showPhase2)
                      Positioned(
                        bottom: screenHeight * 0.18,
                        left: 0,
                        right: 0,
                        child: AnimatedBuilder(
                          animation: _dotsPulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _dotsPulseAnimation.value,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildDot(const Color(0xFFE91E63)), // Pink
                                  const SizedBox(width: 8),
                                  _buildDot(const Color(0xFF00BCD4)), // Cyan
                                  const SizedBox(width: 8),
                                  _buildDot(const Color(0xFF2196F3)), // Blue
                                  const SizedBox(width: 8),
                                  _buildDot(const Color(0xFFFFC107)), // Amber
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
