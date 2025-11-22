import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _emailError; // Store email error message
  
  // Animation controllers
  late AnimationController _contentController;
  late AnimationController _buttonController;
  late AnimationController _fadeOutController;
  
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _inputFadeAnimation;
  late Animation<Offset> _inputSlideAnimation;
  late Animation<double> _socialFadeAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _fadeOutAnimation;

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
  
  @override
  void dispose() {
    _emailController.dispose();
    _contentController.dispose();
    _buttonController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Button press animation
    await _buttonController.forward();
    await _buttonController.reverse();
    
    // Fade out content before navigating
    await _fadeOutController.forward();
    
    if (!mounted) return;
    
    // Navigate to password screen
    await Navigator.pushNamed(
      context,
      '/password',
      arguments: {
        'email': _emailController.text.trim(),
      },
    );
    
    // When user comes back, fade content back in
    if (mounted) {
      await _fadeOutController.reverse();
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider login not implemented yet')),
    );
  }

  void _handleRegister() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Bubble 04 - Large Bottom Yellow (Static with rotation)
          Positioned(
            left: MediaQuery.of(context).size.width * 0.3,
            bottom: -250,
            child: Transform.rotate(
              angle: 0 * 3.14159 / 180, // 0 degrees for Login screen
              child: ClipPath(
                clipper: _Bubble04Clipper(),
                child: Container(
                  width: 500,
                  height: MediaQuery.of(context).size.height + 250, // Extend to screen bottom
                  color: const Color(0xFFFFD700),
                ),
              ),
            ),
          ),
          
          // Bubble 03 - Top Right Small Black Organic Shape (Static with rotation)
          Positioned(
            right: -20,
            top: 280,
            child: Transform.rotate(
              angle: 156 * 3.14159 / 180, // 156 degrees for Login screen
              child: ClipPath(
                clipper: _Bubble03Clipper(),
                child: Container(
                  width: 180,
                  height: 180,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          
          // Bubble 02 - Top Yellow Organic Shape (Static with rotation)
          Positioned(
            left: -200,
            top: -150,
            child: Transform.rotate(
              angle: 140 * 3.14159 / 180, // 140 degrees for Login screen
              child: ClipPath(
                clipper: _Bubble02Clipper(),
                child: Container(
                  width: 500,
                  height: 600,
                  color: const Color(0xFFFFD700),
                ),
              ),
            ),
          ),
          
          // Bubble 01 - Large Top Left Black Organic Shape (Static with rotation)
          Positioned(
            left: -250,
            top: -200,
            child: Transform.rotate(
              angle: 260 * 3.14159 / 180, // 260 degrees for Login screen
              child: ClipPath(
                clipper: _Bubble01Clipper(),
                child: Container(
                  width: 550,
                  height: 550,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          
          // Main Content Layer (with fade out animation)
          FadeTransition(
            opacity: _fadeOutAnimation,
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 35,
                  right: 35,
                  top: MediaQuery.of(context).size.height * 0.40,
                  bottom: MediaQuery.of(context).viewInsets.bottom > 0 
                      ? MediaQuery.of(context).viewInsets.bottom + 20 
                      : 0, // Only add padding when keyboard is visible
                ),
                child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        // Animated "Login" Title
                        SlideTransition(
                          position: _titleSlideAnimation,
                          child: FadeTransition(
                            opacity: _titleFadeAnimation,
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 52,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF202020),
                                letterSpacing: -0.52,
                                height: 1.17,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 5),
                        
                        // Animated subtitle
                        FadeTransition(
                          opacity: _titleFadeAnimation,
                          child: Text(
                            'Good to see you back!',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 19,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xFF202020),
                              height: 35 / 19,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Animated Email Input Field with fixed-height error container
                        SlideTransition(
                          position: _inputSlideAnimation,
                          child: FadeTransition(
                            opacity: _inputFadeAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofocus: false,
                                  validator: (value) {
                                    final error = Validators.validateEmail(value);
                                    setState(() {
                                      _emailError = error;
                                    });
                                    return error;
                                  },
                                  onChanged: (value) {
                                    // Clear error on typing
                                    if (_emailError != null) {
                                      setState(() {
                                        _emailError = null;
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
                                    hintText: 'Email',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontSize: 19,
                                      fontWeight: FontWeight.w300,
                                      color: const Color(0xFFD2D2D2), // Light gray hint
                                    ),
                                    filled: true,
                                    fillColor: Colors.black.withOpacity(0.4), // Black 40% opacity
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                                      borderSide: BorderSide.none, // No border
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none, // No border even when error and focused
                                    ),
                                    errorStyle: const TextStyle(
                                      height: 0, // Hide default error text
                                      fontSize: 0,
                                    ),
                                  ),
                                ),
                                // Fixed-height error container
                                const SizedBox(
                                  height: 24,
                                  child: SizedBox.shrink(),
                                ),
                                if (_emailError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 24, top: 4),
                                    child: Text(
                                      _emailError!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontFamily: 'Nunito Sans',
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Animated Next Button - Material Design
                        FadeTransition(
                          opacity: _inputFadeAnimation,
                          child: ScaleTransition(
                            scale: _buttonScaleAnimation,
                            child: SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: FilledButton(
                                onPressed: _isLoading ? null : _handleNext,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  elevation: 4,
                                  shadowColor: Colors.black.withOpacity(0.3),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Next',
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 19,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 18),
                        
                        // Animated Social Icons Row - Custom Icons
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
                                        width: 52,
                                        height: 52,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.28),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.asset(
                                          'assets/images/Google.png',
                                          width: 28,
                                          height: 28,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 24),
                              
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
                                        width: 52,
                                        height: 52,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.28),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.asset(
                                          'assets/images/apple.png',
                                          width: 26,
                                          height: 26,
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
                        
                        const SizedBox(height: 18),
                        
                        // Animated Register Button - Material Design
                        Center(
                          child: FadeTransition(
                            opacity: _socialFadeAnimation,
                            child: ElevatedButton.icon(
                              onPressed: _handleRegister,
                              icon: const Text(
                                'Register',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              label: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
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
