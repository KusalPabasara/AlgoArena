import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/custom_back_button.dart';

class PasswordScreen extends StatefulWidget {
  final String email;
  final String? userName;
  final String? profileImageUrl;
  
  const PasswordScreen({
    super.key,
    required this.email,
    this.userName,
    this.profileImageUrl,
  });

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _passwordError; // Store password error message
  bool _isLoginInProgress = false; // Track if login is in progress

  late AnimationController _greetingController;
  late AnimationController _inputController;
  late AnimationController _buttonController;
  late AnimationController _bubbleRotationController;

  late Animation<Offset> _greetingSlideAnimation;
  late Animation<double> _greetingFadeAnimation;
  late Animation<Offset> _inputSlideAnimation;
  late Animation<double> _inputFadeAnimation;
  late Animation<double> _buttonScaleAnimation;
  
  // Bubble rotation animations (from Login angles to Password angles)
  late Animation<double> _bubble01RotationAnimation;
  late Animation<double> _bubble02RotationAnimation;
  late Animation<double> _bubble03RotationAnimation;
  late Animation<double> _bubble04RotationAnimation;

  @override
  void initState() {
    super.initState();

    _greetingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _inputController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    // Bubble rotation animation controller (smooth rotation transition)
    _bubbleRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _greetingSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5), // Slide up from bottom
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _greetingController, curve: Curves.easeOutCubic));

    _greetingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _greetingController, curve: Curves.easeIn),
    );

    _inputSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2), // Slide up from bottom
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _inputController, curve: Curves.easeOutCubic));

    _inputFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _inputController, curve: Curves.easeIn),
    );

    _buttonScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutBack),
    );
    
    // Bubble rotation animations (from Login angles to Password angles)
    final rotationCurve = CurvedAnimation(
      parent: _bubbleRotationController,
      curve: Curves.easeInOutCubic,
    );
    
    // Continue rotation from where login screen ends (seamless anticlockwise transition)
    // Login screen animation ends at: (600.0, 472.0, 60.0, 90.0) - normalized to (240.0, 112.0, 60.0, 90.0)
    // Password screen final angles (from static render formulas converted to degrees):
    // Bubble 01: 260*3.14159/200 ≈ 4.08 radians ≈ 234 degrees
    // Bubble 02: 350*5.123/320 ≈ 5.6 radians ≈ 321 degrees  
    // Bubble 03: 200*3.14159/170 ≈ 3.7 radians ≈ 212 degrees
    // Bubble 04: -600*3.14159/1500 ≈ -1.26 radians ≈ -72 degrees
    
    // Continue anticlockwise rotation from normalized end angles
    _bubble01RotationAnimation = Tween<double>(
      begin: 240.0, // Where login screen animation ends (normalized from 600°)
      end: 234.0 + 360.0,   // Counterclockwise: 240° -> 360° -> 234° (594° total)
    ).animate(rotationCurve);
    
    _bubble02RotationAnimation = Tween<double>(
      begin: 112.0, // Where login screen animation ends (normalized from 472°)
      end: 321.0,   // Counterclockwise: 112° -> 321° (direct path, already counterclockwise)
    ).animate(rotationCurve);
    
    _bubble03RotationAnimation = Tween<double>(
      begin: 60.0,  // Where login screen animation ends
      end: 212.0,   // Counterclockwise: 60° -> 212° (direct path, already counterclockwise)
    ).animate(rotationCurve);
    
    _bubble04RotationAnimation = Tween<double>(
      begin: 90.0,  // Where login screen animation ends
      end: -72.0 + 360.0,   // Counterclockwise: 90° -> 360° -> -72° (288° total, normalized to 288°)
    ).animate(rotationCurve);

    // Start bubble rotation animation immediately
    _bubbleRotationController.forward();
    
    // Content slides up from bottom after bubbles start rotating
    Future.delayed(const Duration(milliseconds: 300), () {
      _greetingController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _inputController.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _greetingController.dispose();
    _inputController.dispose();
    _buttonController.dispose();
    _bubbleRotationController.dispose();
    // Remove listener if it was added
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.removeListener(_onAuthProviderChanged);
    super.dispose();
  }
  
  // Listener for AuthProvider changes
  void _onAuthProviderChanged() {
    if (!_isLoginInProgress) return; // Only handle if login is in progress
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // If loading is done, handle the result
    if (!authProvider.isLoading && _isLoginInProgress) {
      _isLoginInProgress = false;
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (authProvider.isAuthenticated) {
          // Login successful
          Navigator.pushReplacementNamed(context, '/home');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.isSuperAdmin 
                  ? 'Welcome, Super Administrator!' 
                  : AppStrings.loginSuccess),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          // Login failed - show error
          String errorMessage = authProvider.error ?? 'Invalid email or password';
          errorMessage = errorMessage.replaceAll('Exception: ', '');
          errorMessage = errorMessage.replaceAll('Login failed: ', '');
          errorMessage = errorMessage.replaceAll('INVALID_LOGIN_CREDENTIALS', 'Invalid email or password');
          if (errorMessage.isEmpty || errorMessage == 'null' || errorMessage.trim().isEmpty) {
            errorMessage = 'Invalid email or password';
          }
          
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
          _passwordController.clear();
        }
      }
    }
  }

  Future<void> _handleBack() async {
    // Reverse bubble rotation before going back
    await _bubbleRotationController.reverse();
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _isLoginInProgress = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Add listener to detect when login completes
    authProvider.addListener(_onAuthProviderChanged);
    
    // Start login
    try {
      final success = await authProvider.login(
        widget.email,
        _passwordController.text,
      );
      
      // Remove listener
      authProvider.removeListener(_onAuthProviderChanged);
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _isLoginInProgress = false;
      });
      
      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.isSuperAdmin 
                ? 'Welcome, Super Administrator!' 
                : AppStrings.loginSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        // Login failed - show error
        String errorMessage = authProvider.error ?? 'Invalid email or password';
        errorMessage = errorMessage.replaceAll('Exception: ', '');
        errorMessage = errorMessage.replaceAll('Login failed: ', '');
        errorMessage = errorMessage.replaceAll('INVALID_LOGIN_CREDENTIALS', 'Invalid email or password');
        if (errorMessage.isEmpty || errorMessage == 'null' || errorMessage.trim().isEmpty) {
          errorMessage = 'Invalid email or password';
        }
        
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
        _passwordController.clear();
      }
    } catch (e) {
      // Remove listener on error
      authProvider.removeListener(_onAuthProviderChanged);
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _isLoginInProgress = false;
      });
      
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.isEmpty || errorMessage == 'null') {
        errorMessage = 'Invalid email or password';
      }
      
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      _passwordController.clear();
    }
  }

  void _handleForgotPassword() {
    Navigator.pushNamed(
      context,
      '/forgot-password',
      arguments: {'email': widget.email},
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive utilities at the start of build
    ResponsiveUtils.init(context);
    
    // Extract user name from email or use provided userName
    final displayName = widget.userName ?? widget.email.split('@')[0];
    
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Bubble 04 - Bottom Yellow (Animated rotation, SAME position as Login)
          // Using top positioning so it doesn't move with keyboard
          AnimatedBuilder(
            animation: _bubble04RotationAnimation,
            builder: (context, child) {
              return Positioned(
                left: ResponsiveUtils.bw(206), // 50% of 412 reference width
                top: ResponsiveUtils.screenHeight - ResponsiveUtils.bs(650) + ResponsiveUtils.bh(70),
                child: Transform.rotate(
                  angle: _bubble04RotationAnimation.value * 3.14159 / 180, // Use animation value, convert degrees to radians
                  child: child,
                ),
              );
            },
            child: ClipPath(
              clipper: _Bubble04Clipper(),
              child: Container(
                width: ResponsiveUtils.bs(500),
                height: ResponsiveUtils.bs(650),
                color: const Color(0xFFFFD700),
              ),
            ),
          ),

          // Bubble 03 - Top Right Black (Animated rotation, SAME position as Login)
          AnimatedBuilder(
            animation: _bubble03RotationAnimation,
            builder: (context, child) {
              return Positioned(
                right: ResponsiveUtils.bw(-70),
                top: ResponsiveUtils.bh(280),
                child: Transform.rotate(
                  angle: _bubble03RotationAnimation.value * 3.14159 / 180, // Use animation value, convert degrees to radians
                  child: child,
                ),
              );
            },
            child: ClipPath(
              clipper: _Bubble03Clipper(),
              child: Container(
                width: ResponsiveUtils.bs(180),
                height: ResponsiveUtils.bs(180),
                color: Colors.black,
              ),
            ),
          ),

          // Bubble 02 - Top Yellow (Animated rotation, SAME position as Login)
          AnimatedBuilder(
            animation: _bubble02RotationAnimation,
            builder: (context, child) {
              return Positioned(
                left: ResponsiveUtils.bw(-190),
                top: ResponsiveUtils.bh(-210),
                child: Transform.rotate(
                  angle: _bubble02RotationAnimation.value * 3.14159 / 180, // Use animation value, convert degrees to radians
                  child: child,
                ),
              );
            },
            child: ClipPath(
              clipper: _Bubble02Clipper(),
              child: Container(
                width: ResponsiveUtils.bs(500),
                height: ResponsiveUtils.bs(600),
                color: const Color(0xFFFFD700),
              ),
            ),
          ),

          // Bubble 01 - Top Left Black (Animated rotation, SAME position as Login)
          AnimatedBuilder(
            animation: _bubble01RotationAnimation,
            builder: (context, child) {
              return Positioned(
                left: ResponsiveUtils.bw(-300),
                top: ResponsiveUtils.bh(-250),
                child: Transform.rotate(
                  angle: _bubble01RotationAnimation.value * 3.14159 / 180, // Use animation value, convert degrees to radians
                  child: child,
                ),
              );
            },
            child: ClipPath(
              clipper: _Bubble01Clipper(),
              child: Container(
                width: ResponsiveUtils.bs(550),
                height: ResponsiveUtils.bs(550),
                color: Colors.black,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                ResponsiveUtils.init(context);
                
                return SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        // Back button - handled by CustomBackButton in Stack
                        SizedBox(height: ResponsiveUtils.spacingM + MediaQuery.of(context).padding.top + 48),

                        SizedBox(height: MediaQuery.of(context).size.height * 0.28),

                        // Greeting and Avatar
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.adaptiveHorizontalPadding),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Greeting
                              Expanded(
                                child: SlideTransition(
                                  position: _greetingSlideAnimation,
                                  child: FadeTransition(
                                    opacity: _greetingFadeAnimation,
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
                                ),
                              ),

                              // Avatar with gold border
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
                SlideTransition(
                  position: _inputSlideAnimation,
                  child: FadeTransition(
                    opacity: _inputFadeAnimation,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.adaptiveHorizontalPadding),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Password field with fixed-height error container
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
                                      setState(() {
                                        _passwordError = error;
                                      });
                                      return error;
                                    },
                                    onChanged: (value) {
                                      // Clear error on typing
                                      if (_passwordError != null) {
                                        setState(() {
                                          _passwordError = null;
                                        });
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
                                      errorStyle: const TextStyle(
                                        height: 0,
                                        fontSize: 0,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: ResponsiveUtils.spacingL,
                                        vertical: ResponsiveUtils.spacingM,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.white70,
                                          size: ResponsiveUtils.iconSize,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                // Fixed-height error container
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
                        
                            // Next button - Material Design
                            ScaleTransition(
                              scale: _buttonScaleAnimation,
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
                            ),
                            SizedBox(height: ResponsiveUtils.spacingS),
                            // Forgot Password - Aligned to bottom
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
                ),

                SizedBox(height: ResponsiveUtils.spacingXL), // Bottom spacing
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Back button - top left
          CustomBackButton(
            backgroundColor: Colors.black, // Black bubble background
            iconSize: 24, // Consistent size
            onPressed: _handleBack,
          ),
        ],
      ),
    );
  }
}

// Custom Clippers for SVG Bubble Shapes

// Bubble 01 - Black organic shape (top left)
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

// Bubble 03 - Small black organic shape (top right)
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

// Bubble 02 - Yellow organic shape (middle right)
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

// Bubble 04 - Large yellow organic shape (bottom right)
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
