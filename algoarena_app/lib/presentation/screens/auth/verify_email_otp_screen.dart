import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/forgot_password_widgets.dart';
import '../../../data/repositories/password_recovery_repository.dart';
import '../../../utils/responsive_utils.dart';
import 'new_password_screen.dart';
import '../../widgets/custom_back_button.dart';

/// OTP Verification Screen for Email Password Recovery
/// Shows 4 digit code input like in Figma design
class VerifyEmailOTPScreen extends StatefulWidget {
  final String email;
  final String? devOtp; // For development testing only

  const VerifyEmailOTPScreen({
    super.key,
    required this.email,
    this.devOtp,
  });

  @override
  State<VerifyEmailOTPScreen> createState() => _VerifyEmailOTPScreenState();
}

class _VerifyEmailOTPScreenState extends State<VerifyEmailOTPScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final _repository = PasswordRecoveryRepository();
  
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  int _resendCooldown = 0;

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
    
    // Don't auto-fill OTP - let user enter it manually from email
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
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _avatarController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String get _maskedEmail {
    final parts = widget.email.split('@');
    if (parts.length != 2) return widget.email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return widget.email;
    return '${name.substring(0, 2)}***@$domain';
  }

  String get _otpValue {
    return _otpControllers.map((c) => c.text).join();
  }

  /// Clean up error messages for display
  String _getCleanErrorMessage(String message) {
    // Parse JSON-like error messages
    if (message.contains('"message"')) {
      final regex = RegExp(r'"message"\s*:\s*"([^"]+)"');
      final match = regex.firstMatch(message);
      if (match != null) {
        return match.group(1) ?? message;
      }
    }
    // Remove "Network error:" prefix if present
    if (message.startsWith('Network error:')) {
      message = message.replaceFirst('Network error:', '').trim();
    }
    // Remove "Server error (XXX):" prefix if present
    final serverErrorRegex = RegExp(r'Server error \(\d+\):\s*');
    message = message.replaceFirst(serverErrorRegex, '');
    
    return message;
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Handle backspace - move to previous field
      _focusNodes[index - 1].requestFocus();
    }
    
    // Auto-verify when all digits are entered
    if (_otpValue.length == 4) {
      _verifyOTP();
    }
    
    setState(() => _errorMessage = null);
  }

  Future<void> _verifyOTP() async {
    final otp = _otpValue;
    
    if (otp.length != 4) {
      setState(() => _errorMessage = 'Please enter all 4 digits');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repository.verifyOTP(widget.email, otp);

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewPasswordScreen(email: widget.email),
          ),
        );
      }
    } else {
      setState(() => _errorMessage = result['message']);
      // Clear OTP fields on error
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  Future<void> _resendOTP() async {
    if (_resendCooldown > 0) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    final result = await _repository.resendOTP(widget.email);

    setState(() {
      _isResending = false;
      _resendCooldown = 60;
    });

    // Start cooldown timer
    _startCooldownTimer();

    if (result['success'] == true) {
      // Clear OTP fields so user can enter the new OTP
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New OTP sent to your email'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  void _startCooldownTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _resendCooldown > 0) {
        setState(() => _resendCooldown--);
        return true;
      }
      return false;
    });
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

                            SizedBox(height: ResponsiveUtils.dp(100)),

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
                            ),

                            SizedBox(height: ResponsiveUtils.spacingXL),

                            // OTP input fields - animated
                            FadeTransition(
                              opacity: _contentFadeAnimation,
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
                            ),

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
                                          _getCleanErrorMessage(_errorMessage!),
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
                            ),

                            SizedBox(height: ResponsiveUtils.spacingM),

                            // Resend button
                            FadeTransition(
                              opacity: _contentFadeAnimation,
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
                            ),

                            // Cancel button
                            TextButton(
                              onPressed: _handleCancel,
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
                        ),
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
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOTPField(int index) {
    final otpBoxSize = ResponsiveUtils.dp(55);
    final otpBoxHeight = ResponsiveUtils.dp(60);
    
    return GestureDetector(
      onTap: () {
        _focusNodes[index].requestFocus();
      },
      child: Container(
        width: otpBoxSize,
        height: otpBoxHeight,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9E6), // Light yellow background
          borderRadius: BorderRadius.circular(ResponsiveUtils.cardRadius),
          border: Border.all(
            color: _focusNodes[index].hasFocus
                ? const Color(0xFFB8860B)
                : const Color(0xFFE0D5B5),
            width: 2,
          ),
        ),
        child: Center(
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
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
}
