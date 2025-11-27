import 'package:flutter/material.dart';
import '../../widgets/forgot_password_widgets.dart';
import '../../../data/repositories/password_recovery_repository.dart';
import '../../../utils/responsive_utils.dart';
import 'verify_email_otp_screen.dart';

/// Password Recovery Screen - Email Only (SMS not working)
/// With bubble decorations at the top like the Figma design
class ForgotPasswordScreen extends StatefulWidget {
  final String? email;

  const ForgotPasswordScreen({
    super.key,
    this.email,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _repository = PasswordRecoveryRepository();
  bool _isLoading = false;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _avatarController;
  late AnimationController _contentController;
  late AnimationController _buttonController;

  late Animation<double> _avatarScaleAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<double> _buttonFadeAnimation;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email ?? '';
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

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _avatarScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.elasticOut),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeIn),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _avatarController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _avatarController.dispose();
    _contentController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOTP() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.sendOTP(email);

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyEmailOTPScreen(
              email: email,
              devOtp: result['otp'], // Only for development
            ),
          ),
        );
      }
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  void _handleCancel() {
    Navigator.pop(context);
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

                            SizedBox(height: ResponsiveUtils.spacingM),

                            // Subtitle - animated
                            FadeTransition(
                              opacity: _contentFadeAnimation,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUtils.spacingM,
                                ),
                                child: Text(
                                  'Enter your email address and we\'ll send you a 4-digit code to reset your password',
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: ResponsiveUtils.bodyMedium,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF666666),
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                            SizedBox(height: ResponsiveUtils.spacingXL),

                            // Email input field - animated
                            FadeTransition(
                              opacity: _contentFadeAnimation,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUtils.spacingM,
                                ),
                                child: SizedBox(
                                  height: ResponsiveUtils.inputHeight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(
                                        ResponsiveUtils.inputRadius * 2,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: ResponsiveUtils.bodyLarge,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Enter your email',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: ResponsiveUtils.bodyLarge,
                                          color: Colors.grey[400],
                                        ),
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: const Color(0xFFB8860B),
                                          size: ResponsiveUtils.iconSize,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: ResponsiveUtils.spacingL,
                                          vertical: ResponsiveUtils.spacingM,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Error message
                            if (_errorMessage != null)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: ResponsiveUtils.spacingS,
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

                            // Send OTP button - animated
                            FadeTransition(
                              opacity: _buttonFadeAnimation,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUtils.spacingM,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: ResponsiveUtils.buttonHeight,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleSendOTP,
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
                                            'Send Code',
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

                            // Cancel button - animated
                            FadeTransition(
                              opacity: _buttonFadeAnimation,
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
