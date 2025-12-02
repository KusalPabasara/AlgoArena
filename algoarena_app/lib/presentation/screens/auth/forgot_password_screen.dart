import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/forgot_password_widgets.dart';
import '../../../data/repositories/password_recovery_repository.dart';
import '../../../utils/responsive_utils.dart';
import 'password_reset_success_screen.dart';
import '../../widgets/custom_back_button.dart';
import 'dart:ui';

/// Unified Password Recovery Screen
/// Combines email entry, OTP verification, and password reset in one screen
/// With animated bubble rotations on state transitions
enum ForgotPasswordState {
  email,
  otp,
  password,
}

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
  // State management
  ForgotPasswordState _currentState = ForgotPasswordState.email;
  String _email = '';
  
  // Controllers
  final _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(4, (index) => FocusNode());
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  
  final _repository = PasswordRecoveryRepository();
  
  // Loading and error states
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  int _resendCooldown = 0;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Animation controllers
  AnimationController? _bubbleRotationController;
  AnimationController? _avatarController;
  AnimationController? _contentController;
  AnimationController? _buttonController;
  AnimationController? _passwordBorderController;
  AnimationController? _confirmPasswordBorderController;
  
  // Bubble rotation animations
  Animation<double>? _yellowBubbleRotationAnimation;
  Animation<double>? _blackBubbleRotationAnimation;
  
  // Current bubble rotation angles (in radians)
  double _yellowBubbleAngle = -0.5; // Initial angle from ForgotPasswordBubbles
  double _blackBubbleAngle = 0.3; // Initial angle from ForgotPasswordBubbles
  
  // Content animations
  Animation<double>? _avatarScaleAnimation;
  Animation<double>? _contentFadeAnimation;
  Animation<double>? _buttonFadeAnimation;
  Animation<double>? _passwordBorderAnimation;
  Animation<double>? _confirmPasswordBorderAnimation;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email ?? '';
    _email = widget.email ?? '';
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Bubble rotation controller
    _bubbleRotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Initial bubble angles (from ForgotPasswordBubbles static angles)
    // Yellow bubble: -0.5 radians ≈ -28.6 degrees
    // Black bubble: 0.3 radians ≈ 17.2 degrees
    
    _updateBubbleAnimations();
    
    // Content animation controllers
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
    
    _passwordBorderController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _confirmPasswordBorderController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _avatarScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController!, curve: Curves.elasticOut),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController!, curve: Curves.easeIn),
    );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController!, curve: Curves.easeIn),
    );
    
    _passwordBorderAnimation = Tween<double>(begin: 1.5, end: 2.5).animate(
      CurvedAnimation(parent: _passwordBorderController!, curve: Curves.easeInOut),
    );
    
    _confirmPasswordBorderAnimation = Tween<double>(begin: 1.5, end: 2.5).animate(
      CurvedAnimation(parent: _confirmPasswordBorderController!, curve: Curves.easeInOut),
    );
    
    // Listen to password field changes for border animation
    _passwordController.addListener(() {
      if (_passwordFocusNode.hasFocus && _passwordController.text.isNotEmpty) {
        _passwordBorderController?.forward();
      } else {
        _passwordBorderController?.reverse();
      }
    });
    
    _confirmPasswordController.addListener(() {
      if (_confirmPasswordFocusNode.hasFocus && _confirmPasswordController.text.isNotEmpty) {
        _confirmPasswordBorderController?.forward();
      } else {
        _confirmPasswordBorderController?.reverse();
      }
    });
    
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus && _passwordController.text.isNotEmpty) {
        _passwordBorderController?.forward();
      } else {
        _passwordBorderController?.reverse();
      }
    });
    
    _confirmPasswordFocusNode.addListener(() {
      if (_confirmPasswordFocusNode.hasFocus && _confirmPasswordController.text.isNotEmpty) {
        _confirmPasswordBorderController?.forward();
      } else {
        _confirmPasswordBorderController?.reverse();
      }
    });
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _avatarController?.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentController?.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _buttonController?.forward();
    });
  }
  
  void _updateBubbleAnimations() {
    if (_bubbleRotationController == null) return;
    
    final rotationCurve = CurvedAnimation(
      parent: _bubbleRotationController!,
      curve: Curves.easeInOutCubic,
    );
    
    // Determine target angles based on current state
    double yellowTarget, blackTarget;
    
    switch (_currentState) {
      case ForgotPasswordState.email:
        // Email state: initial angles
        yellowTarget = -0.5;
        blackTarget = 0.3;
        break;
      case ForgotPasswordState.otp:
        // OTP state: rotate yellow +0.4, black -0.3
        yellowTarget = -0.5 + 0.9; // -0.1 radians ≈ -5.7 degrees
        blackTarget = 0.3 - 0.9; // 0.0 radians
        break;
      case ForgotPasswordState.password:
        // Password state: rotate yellow +1.4, black -1.2 (different from OTP)
        yellowTarget = -0.5 + 1.4; // 0.9 radians ≈ 51.6 degrees
        blackTarget = 0.3 - 1.2; // -0.9 radians ≈ -51.6 degrees
        break;
    }
    
    // Create animations from current angles to target angles
    _yellowBubbleRotationAnimation = Tween<double>(
      begin: _yellowBubbleAngle,
      end: yellowTarget,
    ).animate(rotationCurve);
    
    _blackBubbleRotationAnimation = Tween<double>(
      begin: _blackBubbleAngle,
      end: blackTarget,
    ).animate(rotationCurve);
    
    // Update current angles to target for next transition
    _yellowBubbleAngle = yellowTarget;
    _blackBubbleAngle = blackTarget;
  }
  
  void _updateBubbleAnimationsForState(ForgotPasswordState targetState) {
    if (_bubbleRotationController == null) return;
    
    final rotationCurve = CurvedAnimation(
      parent: _bubbleRotationController!,
      curve: Curves.easeInOutCubic,
    );
    
    // Determine target angles based on target state
    double yellowTarget, blackTarget;
    
    switch (targetState) {
      case ForgotPasswordState.email:
        // Email state: initial angles
        yellowTarget = -0.5;
        blackTarget = 0.3;
        break;
      case ForgotPasswordState.otp:
        // OTP state: rotate yellow +0.4, black -0.3
        yellowTarget = -0.5 + 0.9; // -0.1 radians ≈ -5.7 degrees
        blackTarget = 0.3 - 0.9; // 0.0 radians
        break;
      case ForgotPasswordState.password:
        // Password state: rotate yellow +1.4, black -1.2 (different from OTP)
        yellowTarget = -0.5 + 1.9; // 0.9 radians ≈ 51.6 degrees
        blackTarget = 0.3 - 1.8; // -0.9 radians ≈ -51.6 degrees
        break;
    }
    
    // Create animations from current angles to target angles
    _yellowBubbleRotationAnimation = Tween<double>(
      begin: _yellowBubbleAngle,
      end: yellowTarget,
    ).animate(rotationCurve);
    
    _blackBubbleRotationAnimation = Tween<double>(
      begin: _blackBubbleAngle,
      end: blackTarget,
    ).animate(rotationCurve);
    
    // Update current angles to target for next transition
    _yellowBubbleAngle = yellowTarget;
    _blackBubbleAngle = blackTarget;
  }
  
  void _transitionToState(ForgotPasswordState newState) {
    // Update bubble animations for the new state
    _updateBubbleAnimationsForState(newState);
    
    // Start bubble rotation animation
    _bubbleRotationController?.reset();
    _bubbleRotationController?.forward();
    
    // Reset content animations
    _contentController?.reset();
    _buttonController?.reset();
    
    // Update state
    setState(() {
      _currentState = newState;
      _errorMessage = null;
    });
    
    // Restart content animations
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentController?.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _buttonController?.forward();
    });
  }
  
  void _handleBack() {
    if (_currentState == ForgotPasswordState.email) {
      Navigator.pop(context);
    } else if (_currentState == ForgotPasswordState.otp) {
      _transitionToState(ForgotPasswordState.email);
    } else if (_currentState == ForgotPasswordState.password) {
      _transitionToState(ForgotPasswordState.otp);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _bubbleRotationController?.dispose();
    _avatarController?.dispose();
    _contentController?.dispose();
    _buttonController?.dispose();
    _passwordBorderController?.dispose();
    _confirmPasswordBorderController?.dispose();
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

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      setState(() {
        _email = email;
      });
      _transitionToState(ForgotPasswordState.otp);
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1) {
      if (index < 3) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    
    if (otp.length != 4) {
      setState(() => _errorMessage = 'Please enter all 4 digits');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.verifyOTP(_email, otp);

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      _transitionToState(ForgotPasswordState.password);
    } else {
      setState(() => _errorMessage = result['message']);
      // Clear OTP fields on error
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _otpFocusNodes[0].requestFocus();
    }
  }

  Future<void> _resendOTP() async {
    if (_resendCooldown > 0) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    await _repository.resendOTP(_email);

    setState(() {
      _isResending = false;
      _resendCooldown = 60;
    });

    // Start cooldown timer
    _startCooldownTimer();
    
    // Clear OTP fields
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _otpFocusNodes[0].requestFocus();
  }

  void _startCooldownTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
        _startCooldownTimer();
      }
    });
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please enter a password';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
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

    final result = await _repository.resetPassword(_email, password);

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

  String get _maskedEmail {
    if (_email.isEmpty) return '';
    final parts = _email.split('@');
    if (parts.length != 2) return _email;
    final username = parts[0];
    final domain = parts[1];
    if (username.length <= 2) {
      return '${username[0]}***@$domain';
    }
    return '${username.substring(0, 2)}***@$domain';
  }

  Widget _buildAnimatedBubbles() {
    if (_yellowBubbleRotationAnimation == null || _blackBubbleRotationAnimation == null) {
      return const ForgotPasswordBubbles();
    }
    
    return AnimatedBuilder(
      animation: _bubbleRotationController!,
      builder: (context, child) {
        return Stack(
        children: [
            // Yellow bubble - larger, positioned more to the right
            Positioned(
              left: ResponsiveUtils.bw(-50),
              top: ResponsiveUtils.bh(-180),
              child: Transform.rotate(
                angle: _yellowBubbleRotationAnimation!.value,
                child: CustomPaint(
                  size: Size(ResponsiveUtils.bs(500), ResponsiveUtils.bs(550)),
                  painter: YellowBubblePainter(),
                        ),
              ),
            ),
            
            // Black bubble - smaller, positioned at top left
            Positioned(
              left: ResponsiveUtils.bw(-80),
              top: ResponsiveUtils.bh(-120),
              child: Transform.rotate(
                angle: _blackBubbleRotationAnimation!.value,
                child: CustomPaint(
                  size: Size(ResponsiveUtils.bs(380), ResponsiveUtils.bs(420)),
                  painter: BlackBubblePainter(),
                                ),
                              ),
                            ),
          ],
        );
      },
    );
  }

  Widget _buildEmailContent() {
    return Column(
      children: [
        SizedBox(height: ResponsiveUtils.dp(100)),

                            // Avatar - animated
        _avatarScaleAnimation != null
            ? ScaleTransition(
                scale: _avatarScaleAnimation!,
                              child: const ForgotPasswordAvatar(),
              )
            : const ForgotPasswordAvatar(),

                            SizedBox(height: ResponsiveUtils.spacingXL),

                            // Title - animated
        _contentFadeAnimation != null
            ? FadeTransition(
                opacity: _contentFadeAnimation!,
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
              )
            : Text(
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

                            SizedBox(height: ResponsiveUtils.spacingM),

                            // Subtitle - animated
        _contentFadeAnimation != null
            ? FadeTransition(
                opacity: _contentFadeAnimation!,
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
              )
            : Padding(
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

                            SizedBox(height: ResponsiveUtils.spacingXL),

                            // Email input field - animated
        _contentFadeAnimation != null
            ? FadeTransition(
                opacity: _contentFadeAnimation!,
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
                            Icons.send_rounded,
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
              )
            : const SizedBox(),

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
        _buttonFadeAnimation != null
            ? FadeTransition(
                opacity: _buttonFadeAnimation!,
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
              )
            : const SizedBox(),

                            SizedBox(height: ResponsiveUtils.spacingM),

                            // Cancel button - animated
        _buttonFadeAnimation != null
            ? FadeTransition(
                opacity: _buttonFadeAnimation!,
                              child: TextButton(
                  onPressed: () => Navigator.pop(context),
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
              )
            : const SizedBox(),

        SizedBox(height: ResponsiveUtils.spacingL),
      ],
    );
  }

  Widget _buildOTPContent() {
    return Column(
      children: [
        SizedBox(height: ResponsiveUtils.dp(100)),

        // Avatar - animated
        _avatarScaleAnimation != null
            ? ScaleTransition(
                scale: _avatarScaleAnimation!,
                child: const ForgotPasswordAvatar(),
              )
            : const ForgotPasswordAvatar(),

        SizedBox(height: ResponsiveUtils.spacingXL),

        // Title - animated
        _contentFadeAnimation != null
            ? FadeTransition(
                opacity: _contentFadeAnimation!,
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
              )
            : Text(
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

        SizedBox(height: ResponsiveUtils.spacingM),

        // Subtitle - animated
        _contentFadeAnimation != null
            ? FadeTransition(
                opacity: _contentFadeAnimation!,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacingM,
                  ),
                  child: Text(
                    'Enter 4-digit code we sent to\n$_maskedEmail',
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
              )
            : Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.spacingM,
                ),
                child: Text(
                  'Enter 4-digit code we sent to\n$_maskedEmail',
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

        SizedBox(height: ResponsiveUtils.spacingXL),

        // OTP input fields - animated
        _contentFadeAnimation != null
            ? FadeTransition(
                opacity: _contentFadeAnimation!,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacingL,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      4,
                      (index) => _buildOTPField(index),
                    ),
                  ),
                ),
              )
            : const SizedBox(),

        // Error message
        if (_errorMessage != null)
          Padding(
            padding: EdgeInsets.only(
              top: ResponsiveUtils.spacingM,
              left: ResponsiveUtils.spacingM,
              right: ResponsiveUtils.spacingM,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.spacingM,
                vertical: ResponsiveUtils.spacingS,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEB),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.cardRadius,
                ),
                border: Border.all(
                  color: const Color(0xFFFF4D4D).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: const Color(0xFFFF4D4D),
                    size: ResponsiveUtils.iconSizeSmall,
                  ),
                  SizedBox(width: ResponsiveUtils.spacingS),
                  Flexible(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        color: const Color(0xFFFF4D4D),
                        fontSize: ResponsiveUtils.bodySmall,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),

        const Spacer(),

        // Verify button
        _buttonFadeAnimation != null
            ? FadeTransition(
                opacity: _buttonFadeAnimation!,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacingM,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: ResponsiveUtils.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOTP,
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
                              'Verify',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: ResponsiveUtils.bodyLarge + 2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              )
            : const SizedBox(),

        SizedBox(height: ResponsiveUtils.spacingM),

        // Resend button
        _buttonFadeAnimation != null
            ? FadeTransition(
                opacity: _buttonFadeAnimation!,
                child: TextButton(
                  onPressed: _resendCooldown > 0 || _isResending
                      ? null
                      : _resendOTP,
                  child: _isResending
                      ? SizedBox(
                          width: ResponsiveUtils.iconSizeSmall,
                          height: ResponsiveUtils.iconSizeSmall,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _resendCooldown > 0
                              ? 'Resend in ${_resendCooldown}s'
                              : 'Send Again',
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: ResponsiveUtils.bodyLarge,
                            fontWeight: FontWeight.w600,
                            color: _resendCooldown > 0
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                ),
              )
            : const SizedBox(),

        // Cancel button
        TextButton(
          onPressed: _handleBack,
          child: Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: ResponsiveUtils.bodyLarge,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
                                ),
                              ),
                            ),

                            SizedBox(height: ResponsiveUtils.spacingL),
      ],
    );
  }

  Widget _buildOTPField(int index) {
    final otpBoxSize = ResponsiveUtils.dp(55);
    final otpBoxHeight = ResponsiveUtils.dp(60);
    
    return GestureDetector(
      onTap: () {
        _otpFocusNodes[index].requestFocus();
      },
      child: Container(
        width: otpBoxSize,
        height: otpBoxHeight,
                              decoration: BoxDecoration(
          color: const Color(0xFFFFF9E6), // Light yellow background
          borderRadius: BorderRadius.circular(ResponsiveUtils.cardRadius),
          border: Border.all(
            color: _otpFocusNodes[index].hasFocus
                ? const Color(0xFFB8860B)
                : const Color(0xFFE0D5B5),
            width: 2,
          ),
        ),
        child: Center(
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            autofocus: index == 0,
            showCursor: false, // Hide cursor
            style: TextStyle(
              fontSize: ResponsiveUtils.headlineSmall,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF202020),
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              fillColor: Colors.transparent,
              filled: false,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) => _onOtpChanged(index, value),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordContent() {
    return Column(
      children: [
        SizedBox(height: ResponsiveUtils.dp(100)),

        // Avatar - animated
        _avatarScaleAnimation != null
            ? ScaleTransition(
                scale: _avatarScaleAnimation!,
                child: const ForgotPasswordAvatar(),
              )
            : const ForgotPasswordAvatar(),

        SizedBox(height: ResponsiveUtils.spacingXL),

        // Title - animated
        _contentFadeAnimation != null
            ? FadeTransition(
                opacity: _contentFadeAnimation!,
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
              )
            : Text(
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

        SizedBox(height: ResponsiveUtils.spacingXL),

        // Password input fields - animated
        _contentFadeAnimation != null
            ? FadeTransition(
                opacity: _contentFadeAnimation!,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacingM,
                  ),
                  child: Column(
                    children: [
                      // New Password field
                      SizedBox(
                        height: ResponsiveUtils.inputHeight,
                        child: TextField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: ResponsiveUtils.bodyLarge,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter New Password',
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
                      
                      SizedBox(height: ResponsiveUtils.spacingM),
                      
                      // Confirm Password field
                      SizedBox(
                        height: ResponsiveUtils.inputHeight,
                        child: TextField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          obscureText: _obscureConfirmPassword,
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: ResponsiveUtils.bodyLarge,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Confirm New Password',
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
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70,
                                size: ResponsiveUtils.iconSize,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(),

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
        _buttonFadeAnimation != null
            ? FadeTransition(
                opacity: _buttonFadeAnimation!,
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
              )
            : const SizedBox(),

        SizedBox(height: ResponsiveUtils.spacingM),

        // Cancel button
        TextButton(
          onPressed: _handleBack,
          child: Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: ResponsiveUtils.bodyLarge,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),

        SizedBox(height: ResponsiveUtils.spacingL),
                          ],
    );
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
          // Animated bubble decorations
          _buildAnimatedBubbles(),

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
                        child: _currentState == ForgotPasswordState.email
                            ? _buildEmailContent()
                            : _currentState == ForgotPasswordState.otp
                                ? _buildOTPContent()
                                : _buildPasswordContent(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Back button - using CustomBackButton from search tab (placed last so it's on top)
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
