import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authRepository = AuthRepository();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  File? _profileImage;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authRepository.register(
        fullName: 'User', // Default name for now
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim().isNotEmpty 
            ? _phoneController.text.trim() 
            : null,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.registrationSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms and Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            'By registering, you agree to our terms of service and privacy policy...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Bubbles Background - Figma 75:115 positioning
          // Container for bubbles at -131.97, -205.67
          Positioned(
            left: -131.97,
            top: -205.67,
            child: Stack(
              children: [
                // Bubble 02 - 367.298x311.014px rotated 158deg
                Transform.rotate(
                  angle: 158 * 3.14159 / 180,
                  child: Container(
                    width: 367.298,
                    height: 311.014,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD700).withOpacity(0.25),
                    ),
                  ),
                ),
                // Bubble 01 - 266.77x243.628px at 534.7px left, 246.67px top
                Positioned(
                  left: 534.7,
                  top: 246.67,
                  child: Container(
                    width: 266.77,
                    height: 243.628,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content Layer
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35.5),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 619),
                      
                      // "Create Account" Title - Raleway Bold 50px, -0.5px tracking, two lines
                      const Text(
                        'Create\nAccount',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 50,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF202020),
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      
                      const SizedBox(height: 137),
                      
                      // Upload Photo Area - 82x92px with user icon
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 82,
                          height: 92,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _profileImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _profileImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person_outline,
                                  size: 40,
                                  color: Color(0xFF202020),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 121),
                      
                      // Four Input Fields stacked vertically with 7.906px gap
                      // Email Input - 331x52px
                      Container(
                        width: 331,
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 19.705),
                        decoration: BoxDecoration(
                          color: const Color(0x66000000),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.835,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.835,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFD2D2D2),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 15.764),
                            isDense: true,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 7.906),
                      
                      // Password Input - 331x52px with eye-slash icon
                      Container(
                        width: 331,
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 19.705),
                        decoration: BoxDecoration(
                          color: const Color(0x66000000),
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
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.835,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13.835,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFD2D2D2),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 15.764),
                                  isDense: true,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                              child: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                size: 10.541,
                                color: const Color(0xFFD2D2D2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 7.906),
                      
                      // Confirm Password Input - 331x52px with eye-slash icon
                      Container(
                        width: 331,
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 19.705),
                        decoration: BoxDecoration(
                          color: const Color(0x66000000),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.835,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Confirm Password',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13.835,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFD2D2D2),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 15.764),
                                  isDense: true,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              child: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                size: 10.541,
                                color: const Color(0xFFD2D2D2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 7.906),
                      
                      // Phone Number Input - 331x55px with flag dropdown
                      Container(
                        width: 331,
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 19.705),
                        decoration: BoxDecoration(
                          color: const Color(0x66000000),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Row(
                          children: [
                            // England flag placeholder (23.717x17.788px)
                            Container(
                              width: 23.717,
                              height: 17.788,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: const Center(
                                child: Text(
                                  '',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Arrow-down icon (16px)
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 16,
                              color: Color(0xFFD2D2D2),
                            ),
                            const SizedBox(width: 8),
                            // Vertical separator
                            Container(
                              width: 1,
                              height: 24,
                              color: const Color(0xFFD2D2D2),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.835,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Your number',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13.835,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFD2D2D2),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 115),
                      
                      // Checkbox - 22x22px with Terms and Conditions link
                      Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreeToTerms = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF0088FF),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: _showTermsAndConditions,
                              child: RichText(
                                text: const TextSpan(
                                  text: 'I agree All ',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13.835,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF202020),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Terms and Conditions',
                                      style: TextStyle(
                                        color: Color(0xFF0088FF),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 38),
                      
                      // Register Button - 331x61px, #1B1B1C bg, 16px radius
                      GestureDetector(
                        onTap: _isLoading ? null : _handleRegister,
                        child: Container(
                          width: 331,
                          height: 61,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B1B1C),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x40000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Color(0x40000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 17),
                      
                      // Cancel Button - Nunito Sans Bold 15px, centered
                      Center(
                        child: GestureDetector(
                          onTap: _handleCancel,
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 95),
                      
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
