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

class _PasswordScreenState extends State<PasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
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
      '/forgot-password',
      arguments: widget.email,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    
    // Extract user name from email or use provided userName
    final displayName = widget.userName ?? widget.email.split('@')[0];
    final firstName = displayName.split(' ')[0];
    final capitalizedName = firstName[0].toUpperCase() + firstName.substring(1);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Bubbles Background - Figma 101:276 positioning
          // Large bubble background: 1104.969x816.332px at -249.39, -234.79
          Positioned(
            left: -249.39,
            top: -234.79,
            child: Container(
              width: 1104.969,
              height: 816.332,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 0.8,
                  colors: [
                    const Color(0xFFFFD700).withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Black bubble overlay
          Positioned(
            right: -120,
            top: -80,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.12),
              ),
            ),
          ),
          
          // Yellow accent bubble bottom
          Positioned(
            right: -180,
            bottom: -250,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD700).withOpacity(0.18),
              ),
            ),
          ),
          
          // User Avatar on Right Edge - Ellipse with artist image
          Positioned(
            right: -30, // Extends off-screen right as per Figma
            top: 354,
            child: Container(
              width: 127.2,
              height: 127.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(-2, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: widget.profileImageUrl != null
                    ? Image.network(
                        widget.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
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
                        
                        // Personalized Greeting - "Hello, " part
                        // Split into two text elements as per Figma
                        Row(
                          children: [
                            const Text(
                              'Hello, ',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 52,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF202020),
                                letterSpacing: -0.52,
                                height: 1.17,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 5),
                        
                        // User name part - Nunito Sans Light 19px
                        Text(
                          '$capitalizedName!',
                          style: const TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 19,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF202020),
                            height: 35 / 19,
                          ),
                        ),
                        
                        const SizedBox(height: 50),
                        
                        // Password Input Field - 332x52px, rgba(0,0,0,0.4) bg, 60px radius
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
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    return null;
                                  },
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13.79,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Password',
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
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 18,
                                  color: const Color(0xFFD2D2D2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 23),
                        
                        // Next Button - 332x61px, black bg, 20px radius
                        GestureDetector(
                          onTap: _isLoading ? null : _handleLogin,
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
                        
                        const SizedBox(height: 16),
                        
                        // "Forgot Password?" Link - Nunito Sans Bold 15px, 90% opacity, right aligned
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _handleForgotPassword,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black.withOpacity(0.9),
                                ),
                              ),
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
          
          // Status Bar Elements (Top)
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
                  // Status icons
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
