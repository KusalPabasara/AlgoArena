import 'package:flutter/material.dart';
import '../../widgets/forgot_password_widgets.dart';
import '../../../data/repositories/password_recovery_repository.dart';
import '../../../utils/responsive_utils.dart';
import 'password_reset_success_screen.dart';

/// New Password Entry Screen
/// Allows user to enter and confirm new password
class NewPasswordScreen extends StatefulWidget {
  final String email;

  const NewPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen>
    with TickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _repository = PasswordRecoveryRepository();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _avatarController;
  late AnimationController _contentController;

  late Animation<double> _avatarScaleAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _avatarScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.elasticOut),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _avatarController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _avatarController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please enter a password';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleResetPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate password
    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      setState(() => _errorMessage = passwordError);
      return;
    }

    // Check passwords match
    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.resetPassword(widget.email, password);

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const PasswordResetSuccessScreen(),
          ),
          (route) => false,
        );
      }
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  void _handleCancel() {
    // Go back to login
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive utilities
    ResponsiveUtils.init(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Bubble decorations
          const ForgotPasswordBubbles(),

          // Main content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.adaptiveHorizontalPadding,
                        ),
                        child: Column(
                          children: [
                            // Back button
                            Padding(
                              padding: EdgeInsets.only(
                                left: ResponsiveUtils.spacingS,
                                top: ResponsiveUtils.spacingS,
                              ),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: ForgotPasswordBackButton(
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),

                            SizedBox(height: ResponsiveUtils.dp(60)),

                            // Avatar - animated
                            ScaleTransition(
                              scale: _avatarScaleAnimation,
                              child: const ForgotPasswordAvatar(),
                            ),

                            SizedBox(height: ResponsiveUtils.spacingXL),

                            // Title - animated
                            FadeTransition(
                              opacity: _contentFadeAnimation,
                              child: Text(
                                'Password Recovery',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: ResponsiveUtils.titleLarge,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF202020),
                                  letterSpacing: -0.22,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: ResponsiveUtils.spacingXL),

                            // Password input fields - animated
                            FadeTransition(
                              opacity: _contentFadeAnimation,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUtils.spacingM,
                                ),
                                child: Column(
                                  children: [
                                    // New Password field
                                    SizedBox(
                                      height: ResponsiveUtils.inputHeight,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF9E6),
                                          borderRadius: BorderRadius.circular(
                                            ResponsiveUtils.buttonRadius,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFE0D5B5),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: _passwordController,
                                          obscureText: _obscurePassword,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: ResponsiveUtils.bodyMedium,
                                            color: const Color(0xFF202020),
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Enter New Password',
                                            hintStyle: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: ResponsiveUtils.bodyMedium,
                                              color: const Color(0xFF999999),
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: ResponsiveUtils.spacingL,
                                              vertical: ResponsiveUtils.spacingM,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: const Color(0xFFD2D2D2),
                                                size: ResponsiveUtils.iconSizeSmall,
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
                                    ),

                                    SizedBox(height: ResponsiveUtils.spacingS),

                                    // Confirm Password field
                                    SizedBox(
                                      height: ResponsiveUtils.inputHeight,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF9E6),
                                          borderRadius: BorderRadius.circular(
                                            ResponsiveUtils.buttonRadius,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFE0D5B5),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: _confirmPasswordController,
                                          obscureText: _obscureConfirmPassword,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: ResponsiveUtils.bodyMedium,
                                            color: const Color(0xFF202020),
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Confirm New Password',
                                            hintStyle: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: ResponsiveUtils.bodyMedium,
                                              color: const Color(0xFF999999),
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: ResponsiveUtils.spacingL,
                                              vertical: ResponsiveUtils.spacingM,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscureConfirmPassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: const Color(0xFFD2D2D2),
                                                size: ResponsiveUtils.iconSizeSmall,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscureConfirmPassword =
                                                      !_obscureConfirmPassword;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Error message
                            if (_errorMessage != null)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: ResponsiveUtils.spacingM,
                                  left: ResponsiveUtils.spacingM,
                                  right: ResponsiveUtils.spacingM,
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: ResponsiveUtils.bodySmall,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                            const Spacer(),

                            // Reset Password button
                            FadeTransition(
                              opacity: _contentFadeAnimation,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUtils.spacingM,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: ResponsiveUtils.buttonHeight,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleResetPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          ResponsiveUtils.inputRadius * 2,
                                        ),
                                      ),
                                      disabledBackgroundColor: Colors.grey[400],
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            width: ResponsiveUtils.iconSize,
                                            height: ResponsiveUtils.iconSize,
                                            child: const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'Reset Password',
                                            style: TextStyle(
                                              fontFamily: 'Nunito Sans',
                                              fontSize: ResponsiveUtils.bodyLarge + 2,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: ResponsiveUtils.spacingM),

                            // Cancel button
                            FadeTransition(
                              opacity: _contentFadeAnimation,
                              child: TextButton(
                                onPressed: _handleCancel,
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: ResponsiveUtils.bodyLarge,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: ResponsiveUtils.spacingL),

                            // Bottom bar indicator
                            Container(
                              width: ResponsiveUtils.dp(134),
                              height: ResponsiveUtils.dp(5),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(
                                  ResponsiveUtils.dp(3),
                                ),
                              ),
                            ),

                            SizedBox(height: ResponsiveUtils.spacingS),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
