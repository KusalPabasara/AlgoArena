import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../../../utils/responsive_utils.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/custom_back_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _emailError; // Store email error message
  bool _showPasswordContent = false; // Track if showing password screen content
  bool _obscurePassword = true;
  String? _passwordError;
  String? _userName;
  String? _profilePhoto;
  
  // Animation controllers
  late AnimationController _contentController;
  late AnimationController _buttonController;
  late AnimationController _fadeOutController;
  AnimationController? _bubbleRotationController;
  // Password screen content animations
  AnimationController? _greetingController;
  AnimationController? _inputController;
  AnimationController? _passwordButtonController;
  
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _inputFadeAnimation;
  late Animation<Offset> _inputSlideAnimation;
  late Animation<double> _socialFadeAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _fadeOutAnimation;
  
  // Bubble rotation animations (for smooth transition to password screen)
  Animation<double>? _bubble01RotationAnimation;
  Animation<double>? _bubble02RotationAnimation;
  Animation<double>? _bubble03RotationAnimation;
  Animation<double>? _bubble04RotationAnimation;
  
  // Password screen content animations
  Animation<Offset>? _passwordGreetingSlideAnimation;
  Animation<double>? _passwordGreetingFadeAnimation;
  Animation<Offset>? _passwordInputSlideAnimation;
  Animation<double>? _passwordInputFadeAnimation;
  Animation<double>? _passwordButtonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }
  
  void _setupAnimations() {
    // Content entrance animations
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Fade out animation for when leaving screen
    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeIn),
    );
    
    // Bubble rotation animation controller (starts when next button is clicked)
    _bubbleRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Bubble rotation animations (from Login screen angles to Password screen angles)
    // Using exact angles from login screen (start) and password screen animation end (target)
    final rotationCurve = CurvedAnimation(
      parent: _bubbleRotationController!,
      curve: Curves.easeInOutCubic,
    );
    
    // Calculate login screen starting angles (from actual render formulas):
    // Bubble 01: 260 * 3.14159 / 180 = 260 degrees
    // Bubble 02: 350 * 5.123/290 ≈ 6.18 radians ≈ 354.2 degrees
    // Bubble 03: 156 * 3.14159 / 5000 ≈ 0.098 radians ≈ 5.6 degrees
    // Bubble 04: -600*3.14159 / 1450 ≈ -1.3 radians ≈ -74.5 degrees
    
    // Rotate anticlockwise from login screen angles to password screen end angles
    // Using exact end angles from password screen (from static render formulas):
    // Bubble 01: 260*3.14159/200 ≈ 234 degrees
    // Bubble 02: 350*5.123/320 ≈ 321 degrees  
    // Bubble 03: 200*3.14159/170 ≈ 212 degrees
    // Bubble 04: -600*3.14159/1500 ≈ -72 degrees
    _bubble01RotationAnimation = Tween<double>(
      begin: 260.0, // Login screen angle (degrees)
      end: 234.0,   // Password screen end angle (exact from password screen)
    ).animate(rotationCurve);
    
    _bubble02RotationAnimation = Tween<double>(
      begin: 354.2, // Login screen angle (degrees)
      end: 321.0,   // Password screen end angle (exact from password screen)
    ).animate(rotationCurve);
    
    _bubble03RotationAnimation = Tween<double>(
      begin: 5.6,   // Login screen angle (degrees)
      end: 212.0,   // Password screen end angle (exact from password screen)
    ).animate(rotationCurve);
    
    _bubble04RotationAnimation = Tween<double>(
      begin: -74.5, // Login screen angle (degrees)
      end: -72.0,   // Password screen end angle (exact from password screen)
    ).animate(rotationCurve);
    
    // Title animations
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    
    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    // Input field animations
    _inputFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
      ),
    );
    
    _inputSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );
    
    // Social icons animation
    _socialFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );
    
    // Button press animation
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }
  
  void _startAnimations() {
    _contentController.forward();
  }
  
  void _setupPasswordAnimations() {
    // Password screen content animation controllers
    _greetingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _inputController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _passwordButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _passwordGreetingSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _greetingController!, curve: Curves.easeOutCubic));

    _passwordGreetingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _greetingController!, curve: Curves.easeIn),
    );

    _passwordInputSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _inputController!, curve: Curves.easeOutCubic));

    _passwordInputFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _inputController!, curve: Curves.easeIn),
    );

    _passwordButtonScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _passwordButtonController!, curve: Curves.easeOutBack),
    );
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _contentController.dispose();
    _buttonController.dispose();
    _fadeOutController.dispose();
    _bubbleRotationController?.dispose();
    _greetingController?.dispose();
    _inputController?.dispose();
    _passwordButtonController?.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _emailError = null;
    });
    
    // Button press animation
    await _buttonController.forward();
    await _buttonController.reverse();
    
    try {
      // Check if user exists and get their name
      final email = _emailController.text.trim();
      final result = await _authRepository.checkUser(email);
      
      if (!mounted) return;
      
      if (result['exists'] != true) {
        setState(() {
          _isLoading = false;
          _emailError = 'No account found with this email';
        });
        return;
      }
      
      // Get user info
      final userInfo = result['user'] as Map<String, dynamic>?;
      final userName = userInfo?['fullName'] as String?;
      final profilePhoto = userInfo?['profilePhoto'] as String?;
      
      // Store user info and show password content on same page
      setState(() {
        _userName = userName;
        _profilePhoto = profilePhoto;
        _showPasswordContent = true;
        _isLoading = false;
      });
      
      // Start bubble rotation animation
      _bubbleRotationController?.forward();
      
      // Setup and start password screen content animations
      _setupPasswordAnimations();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _greetingController?.forward();
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _inputController?.forward();
      });
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) _passwordButtonController?.forward();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _emailError = 'Failed to check user';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    if (provider == 'Google') {
      await _handleGoogleSignIn();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$provider login not implemented yet')),
      );
    }
  }
  
  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;
    
    setState(() {
      _isGoogleLoading = true;
    });
    
    try {
      final result = await _authRepository.googleSignIn();
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        // Navigate to home screen on successful login
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = e.toString();
      // Clean up error message
      if (errorMessage.contains('cancelled')) {
        // User cancelled, don't show error
        return;
      }
      
      errorMessage = errorMessage.replaceAll('Exception: ', '');
      errorMessage = errorMessage.replaceAll('Google Sign-In failed: ', '');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _handleRegister() {
    Navigator.pushNamed(context, '/register');
  }

  void _handleForgotPassword() {
    Navigator.pushNamed(
      context,
      '/forgot-password',
      arguments: {'email': _emailController.text.trim()},
    );
  }
  
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _passwordError = null;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (!mounted) return;
      
      if (authProvider.isAuthenticated) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _passwordError = 'Invalid email or password';
        _isLoading = false;
      });
    }
  }
  
  void _handleBack() {
    if (_showPasswordContent) {
      // Reverse bubble rotation animation
      _bubbleRotationController?.reverse();
      
      // Reverse password content animations
      _passwordButtonController?.reverse();
      _inputController?.reverse();
      _greetingController?.reverse();
      
      // Wait for animations to complete, then hide password content
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _showPasswordContent = false;
          });
        }
      });
    } else {
      Navigator.pop(context);
    }
  }
  
  Widget _buildLoginContent() {
    return SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  ResponsiveUtils.init(context);
                  
                  return SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.adaptiveHorizontalPadding),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.38),
                              // Animated "Login" Title
                              SlideTransition(
                                position: _titleSlideAnimation,
                                child: FadeTransition(
                                  opacity: _titleFadeAnimation,
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: ResponsiveUtils.sp(48),
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF202020),
                                      letterSpacing: -0.52,
                                      height: 1.17,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: ResponsiveUtils.spacingXS),
                              // Animated subtitle
                              FadeTransition(
                                opacity: _titleFadeAnimation,
                                child: Text(
                                  'Good to see you back!',
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: ResponsiveUtils.bodyLarge,
                                    fontWeight: FontWeight.w300,
                                    color: const Color(0xFF202020),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: ResponsiveUtils.spacingL),
                      // Animated Email Input Field
                              SlideTransition(
                                position: _inputSlideAnimation,
                                child: FadeTransition(
                                  opacity: _inputFadeAnimation,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: ResponsiveUtils.inputHeight,
                                        child: TextFormField(
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          validator: (value) {
                                            final error = Validators.validateEmail(value);
                                    setState(() => _emailError = error);
                                            return error;
                                          },
                                          onChanged: (value) {
                                            if (_emailError != null) {
                                      setState(() => _emailError = null);
                                            }
                                          },
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: ResponsiveUtils.bodyLarge,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Email',
                                            hintStyle: TextStyle(
                                              fontFamily: 'Nunito Sans',
                                              fontSize: ResponsiveUtils.bodyLarge,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFFD2D2D2),
                                            ),
                                            filled: true,
                                            fillColor: Colors.black.withOpacity(0.4),
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: ResponsiveUtils.spacingL,
                                              vertical: ResponsiveUtils.spacingM,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                              borderSide: BorderSide.none,
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                              borderSide: BorderSide.none,
                                            ),
                                    errorStyle: const TextStyle(height: 0, fontSize: 0),
                                            ),
                                          ),
                                        ),
                                      SizedBox(
                                        height: ResponsiveUtils.spacingL,
                                        child: _emailError != null
                                            ? Padding(
                                                padding: EdgeInsets.only(
                                                  left: ResponsiveUtils.spacingL,
                                                  top: ResponsiveUtils.spacingXS,
                                                ),
                                                child: Text(
                                                  _emailError!,
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: ResponsiveUtils.bodySmall,
                                                    fontFamily: 'Nunito Sans',
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      // Animated Next Button
                              FadeTransition(
                                opacity: _inputFadeAnimation,
                                child: ScaleTransition(
                                  scale: _buttonScaleAnimation,
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: ResponsiveUtils.buttonHeight,
                                    child: FilledButton(
                                      onPressed: _isLoading ? null : _handleNext,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                        ),
                                        elevation: 4,
                                        shadowColor: Colors.black.withOpacity(0.3),
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                              width: ResponsiveUtils.iconSize,
                                              height: ResponsiveUtils.iconSize,
                                              child: const CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : Text(
                                              'Next',
                                              style: TextStyle(
                                                fontFamily: 'Nunito Sans',
                                                fontSize: ResponsiveUtils.bodyLarge,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: ResponsiveUtils.spacingM),
                      // Animated Social Icons Row
                              FadeTransition(
                                opacity: _socialFadeAnimation,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Google IconButton with custom image and blur
                                    Material(
                                      elevation: 4,
                                      shape: const CircleBorder(),
                                      shadowColor: Colors.black26,
                                      child: InkWell(
                                        onTap: () => _handleSocialLogin('Google'),
                                        customBorder: const CircleBorder(),
                                        child: ClipOval(
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                            child: Container(
                                              width: ResponsiveUtils.dp(52),
                                              height: ResponsiveUtils.dp(52),
                                              padding: EdgeInsets.all(ResponsiveUtils.spacingS + 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.28),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Image.asset(
                                                'assets/images/Google.png',
                                                width: ResponsiveUtils.iconSize,
                                                height: ResponsiveUtils.iconSize,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    SizedBox(width: ResponsiveUtils.spacingL),
                                    
                                    // Apple IconButton with custom image and blur
                                    Material(
                                      elevation: 4,
                                      shape: const CircleBorder(),
                                      shadowColor: Colors.black26,
                                      child: InkWell(
                                        onTap: () => _handleSocialLogin('Apple'),
                                        customBorder: const CircleBorder(),
                                        child: ClipOval(
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                            child: Container(
                                              width: ResponsiveUtils.dp(52),
                                              height: ResponsiveUtils.dp(52),
                                              padding: EdgeInsets.all(ResponsiveUtils.spacingS + 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.28),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Image.asset(
                                                'assets/images/apple.png',
                                                width: ResponsiveUtils.iconSize,
                                                height: ResponsiveUtils.iconSize,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: ResponsiveUtils.spacingM),
                      // Animated Register Button
                              Center(
                                child: FadeTransition(
                                  opacity: _socialFadeAnimation,
                                  child: _RegisterButton(onTap: _handleRegister),
                                ),
                              ),
                      SizedBox(height: ResponsiveUtils.spacingXL),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPasswordContent() {
    final displayName = _userName ?? _emailController.text.trim().split('@')[0];
    
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          ResponsiveUtils.init(context);
          
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  SizedBox(height: ResponsiveUtils.spacingM + MediaQuery.of(context).padding.top + 48),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.28),
                  // Greeting and Avatar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.adaptiveHorizontalPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _passwordGreetingSlideAnimation != null && _passwordGreetingFadeAnimation != null
                              ? SlideTransition(
                                  position: _passwordGreetingSlideAnimation!,
                                  child: FadeTransition(
                                    opacity: _passwordGreetingFadeAnimation!,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hello,',
                                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                                fontFamily: 'Raleway',
                                                fontSize: ResponsiveUtils.sp(48),
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF202020),
                                                letterSpacing: -0.52,
                                                height: 1.17,
                                              ),
                                        ),
                                        SizedBox(height: ResponsiveUtils.spacingXS),
                                        Text(
                                          '$displayName!',
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: ResponsiveUtils.bodyLarge,
                                            fontWeight: FontWeight.w300,
                                            color: const Color(0xFF202020),
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hello,',
                                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                            fontFamily: 'Raleway',
                                            fontSize: ResponsiveUtils.sp(48),
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF202020),
                                            letterSpacing: -0.52,
                                            height: 1.17,
                                          ),
                                    ),
                                    SizedBox(height: ResponsiveUtils.spacingXS),
                                    Text(
                                      '$displayName!',
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: ResponsiveUtils.bodyLarge,
                                        fontWeight: FontWeight.w300,
                                        color: const Color(0xFF202020),
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFB8860B),
                              width: 4,
                            ),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/avatar.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                              SizedBox(height: ResponsiveUtils.spacingXL),
                  // Form inputs
                  _passwordInputSlideAnimation != null && _passwordInputFadeAnimation != null
                      ? SlideTransition(
                          position: _passwordInputSlideAnimation!,
                          child: FadeTransition(
                            opacity: _passwordInputFadeAnimation!,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.adaptiveHorizontalPadding),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: ResponsiveUtils.inputHeight,
                                          child: TextFormField(
                                            controller: _passwordController,
                                            obscureText: _obscurePassword,
                                            validator: (value) {
                                              String? error;
                                              if (value == null || value.isEmpty) {
                                                error = 'Password is required';
                                              }
                                              setState(() => _passwordError = error);
                                              return error;
                                            },
                                            onChanged: (value) {
                                              if (_passwordError != null) {
                                                setState(() => _passwordError = null);
                                              }
                                            },
                                            style: TextStyle(
                                              fontFamily: 'Nunito Sans',
                                              fontSize: ResponsiveUtils.bodyLarge,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Password',
                                              hintStyle: TextStyle(
                                                color: const Color(0xFFD2D2D2),
                                                fontFamily: 'Nunito Sans',
                                                fontSize: ResponsiveUtils.bodyLarge,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              filled: true,
                                              fillColor: Colors.black.withOpacity(0.4),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                                borderSide: BorderSide.none,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                                borderSide: BorderSide.none,
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                                borderSide: BorderSide.none,
                                              ),
                                              focusedErrorBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                                borderSide: BorderSide.none,
                                              ),
                                              errorStyle: const TextStyle(height: 0, fontSize: 0),
                                              contentPadding: EdgeInsets.symmetric(
                                                horizontal: ResponsiveUtils.spacingL,
                                                vertical: ResponsiveUtils.spacingM,
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                                  color: Colors.white70,
                                                  size: ResponsiveUtils.iconSize,
                                                ),
                                                onPressed: () {
                                                  setState(() => _obscurePassword = !_obscurePassword);
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: ResponsiveUtils.spacingL,
                                          child: _passwordError != null
                                              ? Padding(
                                                  padding: EdgeInsets.only(
                                                    left: ResponsiveUtils.spacingL,
                                                    top: ResponsiveUtils.spacingXS,
                                                  ),
                                                  child: Text(
                                                    _passwordError!,
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: ResponsiveUtils.bodySmall,
                                                      fontFamily: 'Nunito Sans',
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                            ],
                          ),
                                    _passwordButtonScaleAnimation != null
                                        ? ScaleTransition(
                                            scale: _passwordButtonScaleAnimation!,
                                            child: SizedBox(
                                              width: double.infinity,
                                              height: ResponsiveUtils.buttonHeight,
                                              child: FilledButton(
                                                onPressed: _isLoading ? null : _handleLogin,
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: Colors.black,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                                  ),
                                                  elevation: 8,
                                                  shadowColor: Colors.black.withOpacity(0.3),
                                                ),
                                                child: _isLoading
                                                    ? SizedBox(
                                                        width: ResponsiveUtils.iconSize,
                                                        height: ResponsiveUtils.iconSize,
                                                        child: const CircularProgressIndicator(
                                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                          strokeWidth: 2,
                                                        ),
                                                      )
                                                    : Text(
                                                        'Next',
                                                        style: TextStyle(
                                                          fontFamily: 'Nunito Sans',
                                                          fontSize: ResponsiveUtils.bodyLarge,
                                                          fontWeight: FontWeight.w500,
                                                          height: 1.5,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            width: double.infinity,
                                            height: ResponsiveUtils.buttonHeight,
                                            child: FilledButton(
                                              onPressed: _isLoading ? null : _handleLogin,
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                                ),
                                                elevation: 8,
                                                shadowColor: Colors.black.withOpacity(0.3),
                                              ),
                                              child: _isLoading
                                                  ? SizedBox(
                                                      width: ResponsiveUtils.iconSize,
                                                      height: ResponsiveUtils.iconSize,
                                                      child: const CircularProgressIndicator(
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : Text(
                                                      'Next',
                                                      style: TextStyle(
                                                        fontFamily: 'Nunito Sans',
                                                        fontSize: ResponsiveUtils.bodyLarge,
                                                        fontWeight: FontWeight.w500,
                                                        height: 1.5,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                    SizedBox(height: ResponsiveUtils.spacingS),
                                    TextButton(
                                      onPressed: _handleForgotPassword,
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: ResponsiveUtils.bodyMedium,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  SizedBox(height: ResponsiveUtils.spacingXL),
                ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive utilities at the start of build
    ResponsiveUtils.init(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Bubble 04 - Large Bottom Yellow (Animated rotation starts on next button click)
          // Using top positioning so it doesn't move with keyboard
          AnimatedBuilder(
            animation: _bubbleRotationController ?? _contentController,
            builder: (context, child) {
              final angle = _bubble04RotationAnimation != null
                  ? _bubble04RotationAnimation!.value * 3.14159 / 180
                  : -74.5 * 3.14159 / 180;
              return Positioned(
                left: ResponsiveUtils.bw(206),
                top: ResponsiveUtils.screenHeight - ResponsiveUtils.bs(650) + ResponsiveUtils.bh(70),
                child: Transform.rotate(
                  angle: angle,
                  child: ClipPath(
                    clipper: _Bubble04Clipper(),
                    child: Container(
                      width: ResponsiveUtils.bs(500),
                      height: ResponsiveUtils.bs(650),
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Bubble 03 - Top Right Small Black Organic Shape (Animated rotation)
          AnimatedBuilder(
            animation: _bubbleRotationController ?? _contentController,
            builder: (context, child) {
              final angle = _bubble03RotationAnimation != null
                  ? _bubble03RotationAnimation!.value * 3.14159 / 180
                  : 5.6 * 3.14159 / 180;
              return Positioned(
                right: ResponsiveUtils.bw(-70),
                top: ResponsiveUtils.bh(280),
                child: Transform.rotate(
                  angle: angle,
                  child: ClipPath(
                    clipper: _Bubble03Clipper(),
                    child: Container(
                      width: ResponsiveUtils.bs(180),
                      height: ResponsiveUtils.bs(180),
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Bubble 02 - Top Yellow Organic Shape (Animated rotation)
          AnimatedBuilder(
            animation: _bubbleRotationController ?? _contentController,
            builder: (context, child) {
              final angle = _bubble02RotationAnimation != null
                  ? _bubble02RotationAnimation!.value * 3.14159 / 180
                  : 354.2 * 3.14159 / 180;
              return Positioned(
                left: ResponsiveUtils.bw(-190),
                top: ResponsiveUtils.bh(-210),
                child: Transform.rotate(
                  angle: angle,
                  child: ClipPath(
                    clipper: _Bubble02Clipper(),
                    child: Container(
                      width: ResponsiveUtils.bs(500),
                      height: ResponsiveUtils.bs(600),
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Bubble 01 - Large Top Left Black Organic Shape (Animated rotation)
          AnimatedBuilder(
            animation: _bubbleRotationController ?? _contentController,
            builder: (context, child) {
              final angle = _bubble01RotationAnimation != null
                  ? _bubble01RotationAnimation!.value * 3.14159 / 180
                  : 260.0 * 3.14159 / 180;
              return Positioned(
                left: ResponsiveUtils.bw(-300),
                top: ResponsiveUtils.bh(-250),
                child: Transform.rotate(
                  angle: angle,
                  child: ClipPath(
                    clipper: _Bubble01Clipper(),
                    child: Container(
                      width: ResponsiveUtils.bs(550),
                      height: ResponsiveUtils.bs(550),
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Main Content Layer - conditionally show login or password content
          _showPasswordContent
              ? _buildPasswordContent()
              : _buildLoginContent(),
          
          // Back button - top left (only show in password phase, not email phase)
          if (_showPasswordContent)
            CustomBackButton(
              backgroundColor: Colors.black,
              iconSize: 24,
              onPressed: _handleBack,
          ),
        ],
      ),
    );
  }
}

// Custom Clippers for SVG Bubble Shapes (from Figma)

// Bubble 01 - Black organic shape
class _Bubble01Clipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final scaleX = size.width / 403;
    final scaleY = size.height / 443;
    
    path.moveTo(201.436 * scaleX, 39.7783 * scaleY);
    path.cubicTo(
      296.874 * scaleX, -90.0363 * scaleY,
      402.871 * scaleX, 129.964 * scaleY,
      402.871 * scaleX, 241.214 * scaleY,
    );
    path.cubicTo(
      402.871 * scaleX, 352.464 * scaleY,
      312.686 * scaleX, 442.65 * scaleY,
      201.436 * scaleX, 442.65 * scaleY,
    );
    path.cubicTo(
      90.1858 * scaleX, 442.65 * scaleY,
      0, 352.464 * scaleY,
      0, 241.214 * scaleY,
    );
    path.cubicTo(
      0, 129.964 * scaleY,
      105.998 * scaleX, 169.593 * scaleY,
      201.436 * scaleX, 39.7783 * scaleY,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Bubble 02 - Yellow organic shape
class _Bubble02Clipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final scaleX = size.width / 372;
    final scaleY = size.height / 451;
    
    path.moveTo(276.948 * scaleX, 385.957 * scaleY);
    path.cubicTo(
      237.089 * scaleX, 542.071 * scaleY,
      56.396 * scaleX, 377.797 * scaleY,
      14.7211 * scaleX, 274.648 * scaleY,
    );
    path.cubicTo(
      -26.9538 * scaleX, 171.499 * scaleY,
      22.8808 * scaleX, 54.0961 * scaleY,
      126.03 * scaleX, 12.4212 * scaleY,
    );
    path.cubicTo(
      229.179 * scaleX, -29.2537 * scaleY,
      313.438 * scaleX, 39.9252 * scaleY,
      358.938 * scaleX, 130.925 * scaleY,
    );
    path.cubicTo(
      404.438 * scaleX, 221.925 * scaleY,
      316.807 * scaleX, 229.843 * scaleY,
      276.948 * scaleX, 385.957 * scaleY,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Bubble 03 - Small black organic shape
class _Bubble03Clipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final scaleX = size.width / 141;
    final scaleY = size.height / 137;
    
    path.moveTo(43.3153 * scaleX, 131.631 * scaleY);
    path.cubicTo(
      -4.48347 * scaleX, 158.87 * scaleY,
      -6.99358 * scaleX, 75.5242 * scaleY,
      8.45684 * scaleX, 40.822 * scaleY,
    );
    path.cubicTo(
      23.9072 * scaleX, 6.11976 * scaleY,
      64.564 * scaleX, -9.48691 * scaleY,
      99.2662 * scaleX, 5.96351 * scaleY,
    );
    path.cubicTo(
      133.968 * scaleX, 21.4139 * scaleY,
      149.575 * scaleX, 62.0707 * scaleY,
      134.125 * scaleX, 96.7729 * scaleY,
    );
    path.cubicTo(
      118.674 * scaleX, 131.475 * scaleY,
      91.114 * scaleX, 104.393 * scaleY,
      43.3153 * scaleX, 131.631 * scaleY,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Bubble 04 - Large yellow organic shape
class _Bubble04Clipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final scaleX = size.width / 415;
    final scaleY = size.height / 378;
    
    path.moveTo(393.067 * scaleX, 235.624 * scaleY);
    path.cubicTo(
      487.036 * scaleX, 366.506 * scaleY,
      245.048 * scaleX, 399.332 * scaleY,
      139.243 * scaleX, 364.954 * scaleY,
    );
    path.cubicTo(
      33.4381 * scaleX, 330.576 * scaleY,
      -24.4647 * scaleX, 216.935 * scaleY,
      9.91336 * scaleX, 111.13 * scaleY,
    );
    path.cubicTo(
      44.2915 * scaleX, 5.32546 * scaleY,
      151.446 * scaleX, -14.7531 * scaleY,
      250.403 * scaleX, 8.88553 * scaleY,
    );
    path.cubicTo(
      349.36 * scaleX, 32.5242 * scaleY,
      299.098 * scaleX, 104.743 * scaleY,
      393.067 * scaleX, 235.624 * scaleY,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Register button with press animation effect
class _RegisterButton extends StatefulWidget {
  final VoidCallback onTap;
  
  const _RegisterButton({required this.onTap});
  
  @override
  State<_RegisterButton> createState() => _RegisterButtonState();
}

class _RegisterButtonState extends State<_RegisterButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }
  
  void _onTapUp(TapUpDetails details) {
    _controller.reverse().then((_) {
      widget.onTap();
    });
  }
  
  void _onTapCancel() {
    _controller.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Register',
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: ResponsiveUtils.bodyLarge,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withOpacity(0.9),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacingS),
                Container(
                  width: ResponsiveUtils.dp(30),
                  height: ResponsiveUtils.dp(30),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: ResponsiveUtils.iconSizeSmall - 4,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
