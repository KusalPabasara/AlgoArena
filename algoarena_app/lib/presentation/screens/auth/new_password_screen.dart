import 'package:flutter/material.dart';
import '../../widgets/forgot_password_widgets.dart';
import '../../../data/repositories/password_recovery_repository.dart';
import '../../../utils/responsive_utils.dart';
import 'password_reset_success_screen.dart';
import '../../widgets/custom_back_button.dart';

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
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _repository = PasswordRecoveryRepository();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  // Animation controllers
  AnimationController? _avatarController;
  AnimationController? _contentController;
  AnimationController? _passwordBorderController;
  AnimationController? _confirmPasswordBorderController;

  Animation<double>? _avatarScaleAnimation;
  Animation<double>? _contentFadeAnimation;
  Animation<double>? _passwordBorderAnimation;
  Animation<double>? _confirmPasswordBorderAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    // Listen to focus changes to update border color
    _passwordFocusNode.addListener(() => setState(() {}));
    _confirmPasswordFocusNode.addListener(() => setState(() {}));
    // Listen to text changes to animate border
    _passwordController.addListener(_onPasswordTextChanged);
    _confirmPasswordController.addListener(_onConfirmPasswordTextChanged);
  }

  void _onPasswordTextChanged() {
    if (_passwordFocusNode.hasFocus && _passwordController.text.isNotEmpty) {
      _passwordBorderController?.forward().then((_) {
        _passwordBorderController?.reverse();
      });
    }
    setState(() {});
  }

  void _onConfirmPasswordTextChanged() {
    if (_confirmPasswordFocusNode.hasFocus && _confirmPasswordController.text.isNotEmpty) {
      _confirmPasswordBorderController?.forward().then((_) {
        _confirmPasswordBorderController?.reverse();
      });
    }
    setState(() {});
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

    _passwordBorderController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _confirmPasswordBorderController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _avatarScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController!, curve: Curves.elasticOut),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController!, curve: Curves.easeIn),
    );

    _passwordBorderAnimation = Tween<double>(begin: 2.0, end: 2.5).animate(
      CurvedAnimation(parent: _passwordBorderController!, curve: Curves.easeInOut),
    );

    _confirmPasswordBorderAnimation = Tween<double>(begin: 2.0, end: 2.5).animate(
      CurvedAnimation(parent: _confirmPasswordBorderController!, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _avatarController?.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentController?.forward();
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordTextChanged);
    _confirmPasswordController.removeListener(_onConfirmPasswordTextChanged);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _avatarController?.dispose();
    _contentController?.dispose();
    _passwordBorderController?.dispose();
    _confirmPasswordBorderController?.dispose();
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
                                          // New Password field - Matching Login Page Style
                                          _passwordBorderAnimation != null
                                              ? AnimatedBuilder(
                                                  animation: _passwordBorderAnimation!,
                                                  builder: (context, child) {
                                                    return AnimatedContainer(
                                                      duration: const Duration(milliseconds: 200),
                                                      curve: Curves.easeInOut,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                                        border: _passwordFocusNode.hasFocus
                                                            ? Border.all(
                                                                color: const Color(0xFFFFD700),
                                                                width: _passwordController.text.isNotEmpty
                                                                    ? _passwordBorderAnimation!.value
                                                                    : 2.0,
                                                              )
                                                            : null,
                                                      ),
                                                      child: child,
                                                    );
                                                  },
                                                  child: SizedBox(
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
                                                )
                                              : AnimatedContainer(
                                                  duration: const Duration(milliseconds: 200),
                                                  curve: Curves.easeInOut,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                                    border: _passwordFocusNode.hasFocus
                                                        ? Border.all(
                                                            color: const Color(0xFFFFD700),
                                                            width: 2.0,
                                                          )
                                                        : null,
                                                  ),
                                                  child: SizedBox(
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
                                    ),

                                          SizedBox(height: ResponsiveUtils.spacingM),

                                          // Confirm Password field - Matching Login Page Style
                                          _confirmPasswordBorderAnimation != null
                                              ? AnimatedBuilder(
                                                  animation: _confirmPasswordBorderAnimation!,
                                                  builder: (context, child) {
                                                    return AnimatedContainer(
                                                      duration: const Duration(milliseconds: 200),
                                                      curve: Curves.easeInOut,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                                        border: _confirmPasswordFocusNode.hasFocus
                                                            ? Border.all(
                                                                color: const Color(0xFFFFD700),
                                                                width: _confirmPasswordController.text.isNotEmpty
                                                                    ? _confirmPasswordBorderAnimation!.value
                                                                    : 2.0,
                                                              )
                                                            : null,
                                                      ),
                                                      child: child,
                                                    );
                                                  },
                                                  child: SizedBox(
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
                                                )
                                              : AnimatedContainer(
                                                  duration: const Duration(milliseconds: 200),
                                                  curve: Curves.easeInOut,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                                    border: _confirmPasswordFocusNode.hasFocus
                                                        ? Border.all(
                                                            color: const Color(0xFFFFD700),
                                                            width: 2.0,
                                                          )
                                                        : null,
                                                  ),
                                                  child: SizedBox(
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
                                                ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: ResponsiveUtils.spacingM,
                                    ),
                                    child: Column(
                                      children: [
                                        // New Password field - Matching Login Page Style
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          curve: Curves.easeInOut,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                            border: _passwordFocusNode.hasFocus
                                                ? Border.all(
                                                    color: const Color(0xFFFFD700),
                                                    width: 2.0,
                                                  )
                                                : null,
                                          ),
                                          child: SizedBox(
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
                                        ),

                                        SizedBox(height: ResponsiveUtils.spacingM),

                                        // Confirm Password field - Matching Login Page Style
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          curve: Curves.easeInOut,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(ResponsiveUtils.buttonRadius),
                                            border: _confirmPasswordFocusNode.hasFocus
                                                ? Border.all(
                                                    color: const Color(0xFFFFD700),
                                                    width: 2.0,
                                                  )
                                                : null,
                                          ),
                                          child: SizedBox(
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
                                    ),
                                  ],
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
                            _contentFadeAnimation != null
                                ? FadeTransition(
                                    opacity: _contentFadeAnimation!,
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
                                : Padding(
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

                            SizedBox(height: ResponsiveUtils.spacingM),

                            // Cancel button
                            _contentFadeAnimation != null
                                ? FadeTransition(
                                    opacity: _contentFadeAnimation!,
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
                                  )
                                : TextButton(
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
          // White on black backgrounds, black on white/yellow backgrounds
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
}
