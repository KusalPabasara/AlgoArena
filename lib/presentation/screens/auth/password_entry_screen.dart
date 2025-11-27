import 'package:flutter/material.dart';
import '../../../utils/responsive_utils.dart';

class PasswordEntryScreen extends StatefulWidget {
  final String username;

  const PasswordEntryScreen({
    super.key,
    required this.username,
  });

  @override
  State<PasswordEntryScreen> createState() => _PasswordEntryScreenState();
}

class _PasswordEntryScreenState extends State<PasswordEntryScreen>
    with TickerProviderStateMixin {
  late AnimationController _avatarController;
  late AnimationController _greetingController;
  late AnimationController _inputController;
  late AnimationController _buttonController;

  late Animation<double> _avatarScaleAnimation;
  late Animation<Offset> _greetingSlideAnimation;
  late Animation<double> _greetingFadeAnimation;
  late Animation<Offset> _inputSlideAnimation;
  late Animation<double> _inputFadeAnimation;
  late Animation<double> _buttonScaleAnimation;

  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _greetingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _inputController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _avatarScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.elasticOut),
    );

    _greetingSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _greetingController, curve: Curves.easeOut));

    _greetingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _greetingController, curve: Curves.easeIn),
    );

    _inputSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _inputController, curve: Curves.easeOut));

    _inputFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _inputController, curve: Curves.easeIn),
    );

    _buttonScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      _avatarController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _greetingController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _inputController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _greetingController.dispose();
    _inputController.dispose();
    _buttonController.dispose();
    _passwordController.dispose();
    super.dispose();
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
          // Large gray organic shape top-left
          Positioned(
            top: ResponsiveUtils.bh(-150),
            left: ResponsiveUtils.bw(-200),
            child: Container(
              width: ResponsiveUtils.bs(600),
              height: ResponsiveUtils.bs(600),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE0E0E0).withOpacity(0.6),
              ),
            ),
          ),

          // Yellow/cream organic shape bottom-right
          Positioned(
            bottom: ResponsiveUtils.bh(-150),
            right: ResponsiveUtils.bw(-100),
            child: Container(
              width: ResponsiveUtils.bs(500),
              height: ResponsiveUtils.bs(500),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFF8DC),
                    Color(0xFFFFF4B3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),

                    // Greeting with avatar
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Greeting text
                        Expanded(
                          child: SlideTransition(
                            position: _greetingSlideAnimation,
                            child: FadeTransition(
                              opacity: _greetingFadeAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello,',
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          height: 1.1,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.username,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Avatar
                        ScaleTransition(
                          scale: _avatarScaleAnimation,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE0E0E0),
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              size: 40,
                              color: Color(0xFFBDBDBD),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 120),

                    // Password input and button
                    SlideTransition(
                      position: _inputSlideAnimation,
                      child: FadeTransition(
                        opacity: _inputFadeAnimation,
                        child: Column(
                          children: [
                            // Password field
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 16,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFBDBDBD),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.grey.shade600,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Next button
                            ScaleTransition(
                              scale: _buttonScaleAnimation,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: FilledButton(
                                    onPressed: () {
                                      // Navigate to home
                                      Navigator.pushReplacementNamed(context, '/home');
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Next',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Forgot password link
                            ScaleTransition(
                              scale: _buttonScaleAnimation,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/password-recovery');
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

