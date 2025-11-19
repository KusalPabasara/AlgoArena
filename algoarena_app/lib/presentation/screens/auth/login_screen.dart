import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) return;
    
    Navigator.pushNamed(
      context,
      '/password',
      arguments: {
        'email': _emailController.text.trim(),
      },
    );
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
    // Get screen size for responsive positioning
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Bubbles Background Layer - positioned exactly as Figma 69:53
          // Consolidated bubbles image: 1154.387x850.395px at -209.94, -186.48
          Positioned(
            left: -209.94,
            top: -186.48,
            child: Container(
              width: 1154.387,
              height: 850.395,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 0.8,
                  colors: [
                    const Color(0xFFFFD700).withOpacity(0.3), // Yellow bubble
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Black bubble overlay
          Positioned(
            right: -100,
            top: -50,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.15),
              ),
            ),
          ),
          
          // Yellow accent bubble bottom-right
          Positioned(
            right: -150,
            bottom: -200,
            child: Container(
              width: 550,
              height: 550,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD700).withOpacity(0.2),
              ),
            ),
          ),
          
          // Main Content Layer
          SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 360),
                        
                        // "Login" Title - Raleway Bold 52px, #202020, -0.52px tracking
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 52,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF202020),
                            letterSpacing: -0.52,
                            height: 1.17,
                          ),
                        ),
                        
                        const SizedBox(height: 5),
                        
                        // "Good to see you back!" subtitle - Nunito Sans Light 19px, 35px line height
                        const Text(
                          'Good to see you back!',
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 19,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF202020),
                            height: 35 / 19,
                          ),
                        ),
                        
                        const SizedBox(height: 50),
                        
                        // Email Input Field - 332x52px, rgba(0,0,0,0.4) bg, 60px radius
                        Container(
                          width: 332,
                          height: 52,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 19.705,
                            vertical: 15.764,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x66000000), // rgba(0,0,0,0.4)
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.validateEmail,
                            style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.79,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                                fontSize: 13.79,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFD2D2D2),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 23),
                        
                        // Next Button - 332x61px, black bg, 20px radius
                        GestureDetector(
                          onTap: _isLoading ? null : _handleNext,
                          child: Container(
                            width: 332,
                            height: 61,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  )
                                : const Text(
                                    'Next',
                                    style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFF3F3F3),
                                      height: 31 / 22,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 22),
                        
                        // Social Icons Row - Two 50px circles
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google Icon Circle
                            GestureDetector(
                              onTap: () => _handleSocialLogin('Google'),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x1A000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(9.5),
                                child: const Icon(
                                  Icons.g_mobiledata,
                                  size: 31,
                                  color: Color(0xFF4285F4),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Apple Icon Circle
                            GestureDetector(
                              onTap: () => _handleSocialLogin('Apple'),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x1A000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(8.5),
                                child: const Icon(
                                  Icons.apple,
                                  size: 33,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 22),
                        
                        // Register Button - 30px circle with arrow + text
                        GestureDetector(
                          onTap: _handleRegister,
                          child: Center(
                            child: Column(
                              children: [
                                // Circular arrow button
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFFD700), // Yellow background
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                
                                const SizedBox(height: 4),
                                
                                // "Register" text - Nunito Sans Bold 15px, 90% opacity
                                Text(
                                  'Register',
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Bottom Bar - 145.848x5.442px, 34px radius, centered
                        Center(
                          child: Container(
                            width: 145.848,
                            height: 5.442,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(34),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Status Bar Elements (Top) - matching Figma status bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 22.512),
              child: Row(
                children: [
                  // Time
                  Container(
                    width: 57.888,
                    height: 19.636,
                    alignment: Alignment.center,
                    child: const Text(
                      '9:41',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Status icons (cellular, wifi, battery)
                  const Icon(Icons.signal_cellular_4_bar, size: 16, color: Colors.black),
                  const SizedBox(width: 5),
                  const Icon(Icons.wifi, size: 16, color: Colors.black),
                  const SizedBox(width: 5),
                  const Icon(Icons.battery_full, size: 16, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
