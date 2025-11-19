import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';

/// Password Recovery Screen - Choose SMS or Email
/// Figma node: 114:644
class ForgotPasswordScreen extends StatefulWidget {
  final String? email;

  const ForgotPasswordScreen({
    Key? key,
    this.email,
  }) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String _selectedMethod = 'sms'; // 'sms' or 'email'

  void _handleNext() {
    if (_selectedMethod == 'sms') {
      Navigator.pushNamed(
        context,
        '/verify-sms',
        arguments: widget.email,
      );
    } else {
      Navigator.pushNamed(
        context,
        '/verify-email',
        arguments: widget.email,
      );
    }
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Yellow and black bubbles at top
          Positioned(
            left: -249,
            top: -235,
            child: Container(
              width: 816,
              height: 1105,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(500),
              ),
            ),
          ),
          Positioned(
            left: -180,
            top: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(300),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                // Profile avatar
                Container(
                  width: 126,
                  height: 126,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFBFA506),
                      width: 4,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/avatar_placeholder.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                const Text(
                  'Password Recovery',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF202020),
                    letterSpacing: -0.21,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 15),

                // Subtitle
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.0),
                  child: Text(
                    'How you would like to restore your password?',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 19,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                      height: 1.42,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 45),

                // SMS option
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMethod = 'sms'),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: _selectedMethod == 'sms'
                            ? const Color(0xFFFFF1C6)
                            : const Color(0xFFCCCCCC),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SMS',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _selectedMethod == 'sms'
                                  ? const Color(0xFF8F7902)
                                  : Colors.black,
                              letterSpacing: -0.15,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (_selectedMethod == 'sms')
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Color(0xFF8F7902),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              ),
                            )
                          else
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCBCBCB),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Email option
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMethod = 'email'),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: _selectedMethod == 'email'
                            ? const Color(0xFFFFF1C6)
                            : const Color(0xFFCCCCCC),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Email',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _selectedMethod == 'email'
                                  ? const Color(0xFF8F7902)
                                  : Colors.black,
                              letterSpacing: -0.15,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (_selectedMethod == 'email')
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Color(0xFF8F7902),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              ),
                            )
                          else
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCBCBCB),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Next button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 33.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 61,
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: const Color(0xFFF3F3F3),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Cancel button
                TextButton(
                  onPressed: _handleCancel,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
