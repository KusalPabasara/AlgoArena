import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../data/repositories/auth_repository.dart';

class PasswordScreen extends StatefulWidget {
  final String email;
  final String? userName;
  final String? profileImageUrl;
  
  const PasswordScreen({
    Key? key,
    required this.email,
    this.userName,
    this.profileImageUrl,
  }) : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _passwordError; // Store password error message

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
    
    _bubble01RotationAnimation = Tween<double>(
      begin: 260.0, // Login angle
      end: 240.0,   // Password angle
    ).animate(rotationCurve);
    
    _bubble02RotationAnimation = Tween<double>(
      begin: 140.0, // Login angle
      end: 112.0,   // Password angle
    ).animate(rotationCurve);
    
    _bubble03RotationAnimation = Tween<double>(
      begin: 156.0, // Login angle
      end: 60.0,    // Password angle
    ).animate(rotationCurve);
    
    _bubble04RotationAnimation = Tween<double>(
      begin: 0.0,   // Login angle
      end: 90.0,    // Password angle
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
    super.dispose();
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

    setState(() => _isLoading = true);

    try {
      await _authRepository.login(
        email: widget.email,
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.loginSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleForgotPassword() {
    Navigator.pushNamed(
      context,
      '/password-recovery',
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Extract user name from email or use provided userName
    final displayName = widget.userName ?? widget.email.split('@')[0];
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Bubble 04 - Bottom Yellow (Animated rotation, SAME position as Login)
          AnimatedBuilder(
            animation: _bubble04RotationAnimation,
            builder: (context, child) {
              return Positioned(
                left: size.width * 0.3, // SAME as Login: 30%
                bottom: -250,
                child: Transform.rotate(
                  angle: _bubble04RotationAnimation.value * 3.14159 / 180,
                  child: child,
                ),
              );
            },
            child: ClipPath(
              clipper: _Bubble04Clipper(),
              child: Container(
                width: 500,
                height: 650,
                color: const Color(0xFFFFD700),
              ),
            ),
          ),

          // Bubble 03 - Top Right Black (Animated rotation, SAME position as Login)
          AnimatedBuilder(
            animation: _bubble03RotationAnimation,
            builder: (context, child) {
              return Positioned(
                right: -20, // SAME as Login
                top: 280,   // SAME as Login
                child: Transform.rotate(
                  angle: _bubble03RotationAnimation.value * 3.14159 / 180,
                  child: child,
                ),
              );
            },
            child: ClipPath(
              clipper: _Bubble03Clipper(),
              child: Container(
                width: 180,
                height: 180,
                color: Colors.black,
              ),
            ),
          ),

          // Bubble 02 - Top Yellow (Animated rotation, SAME position as Login)
          AnimatedBuilder(
            animation: _bubble02RotationAnimation,
            builder: (context, child) {
              return Positioned(
                left: -200, // SAME as Login
                top: -150,  // SAME as Login
                child: Transform.rotate(
                  angle: _bubble02RotationAnimation.value * 3.14159 / 180,
                  child: child,
                ),
              );
            },
            child: ClipPath(
              clipper: _Bubble02Clipper(),
              child: Container(
                width: 500,
                height: 600,
                color: const Color(0xFFFFD700),
              ),
            ),
          ),

          // Bubble 01 - Top Left Black (Animated rotation, SAME position as Login)
          AnimatedBuilder(
            animation: _bubble01RotationAnimation,
            builder: (context, child) {
              return Positioned(
                left: -250, // SAME as Login
                top: -200,  // SAME as Login
                child: Transform.rotate(
                  angle: _bubble01RotationAnimation.value * 3.14159 / 180,
                  child: child,
                ),
              );
            },
            child: ClipPath(
              clipper: _Bubble01Clipper(),
              child: Container(
                width: 550,
                height: 550,
                color: Colors.black,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: _handleBack,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.31), // Same as Login screen

                // Greeting and Avatar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Greeting
                      SlideTransition(
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
                                      fontSize: 52,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF202020),
                                      letterSpacing: -0.52,
                                      height: 1.17,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$displayName!',
                                style: const TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 19,
                                  fontWeight: FontWeight.w300,
                                  color: Color(0xFF202020),
                                  height: 35 / 19,
                                ),
                              ),
                            ],
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

                const SizedBox(height: 40), // Closer to content

                // Form inputs
                SlideTransition(
                  position: _inputSlideAnimation,
                  child: FadeTransition(
                    opacity: _inputFadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Password field with fixed-height error container
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
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
                                  style: const TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 19,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white, // White text
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFFD2D2D2), // Light gray hint
                                      fontFamily: 'Nunito Sans',
                                      fontSize: 19,
                                      fontWeight: FontWeight.w300,
                                      
                                    ),
                                    filled: true,
                                    fillColor: Colors.black.withOpacity(0.4), // Black 40% opacity
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none, // No border
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none, // No border
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none, // No border even when focused
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none,
                                    ),
                                    errorStyle: const TextStyle(
                                      height: 0, // Hide default error text
                                      fontSize: 0,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 18,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white70, // White icon
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                // Fixed-height error container
                                SizedBox(
                                  height: 24, // Fixed height always reserved
                                  child: _passwordError != null
                                      ? Padding(
                                          padding: const EdgeInsets.only(left: 24, top: 4),
                                          child: Text(
                                            _passwordError!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
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
                                height: 56,
                                child: FilledButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    elevation: 8,
                                    shadowColor: Colors.black.withOpacity(0.3),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Next',
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: 19,
                                            fontWeight: FontWeight.w500,
                                            height: 35 / 19,
                                            
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),  
                            // Forgot Password - Aligned to bottom
                            TextButton(
                              onPressed: _handleForgotPassword,
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
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

                const SizedBox(height: 40), // Bottom spacing instead of bar
              ],
            ),
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
