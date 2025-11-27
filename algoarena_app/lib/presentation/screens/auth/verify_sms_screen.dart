import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../data/repositories/auth_repository.dart';

/// SMS Verification Screen - Enter 4-digit code
/// Figma node: 117:378
class VerifySmsScreen extends StatefulWidget {
  final String? email;
  final String? phoneNumber;

  const VerifySmsScreen({
    Key? key,
    this.email,
    this.phoneNumber,
  }) : super(key: key);

  @override
  State<VerifySmsScreen> createState() => _VerifySmsScreenState();
}

class _VerifySmsScreenState extends State<VerifySmsScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );
  final _authRepository = AuthRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _maskedPhone {
    if (widget.phoneNumber != null && widget.phoneNumber!.length > 4) {
      final phone = widget.phoneNumber!;
      final last2 = phone.substring(phone.length - 2);
      return '+94*******$last2';
    }
    return '+94*******41';
  }

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    
    // Auto-submit when all fields are filled
    if (index == 3 && value.isNotEmpty) {
      final allFilled = _controllers.every((c) => c.text.isNotEmpty);
      if (allFilled) {
        _handleSendAgain();
      }
    }
  }

  void _onBackspace(int index) {
    if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _handleSendAgain() async {
    final code = _controllers.map((c) => c.text).join();
    
    if (code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 4 digits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Verify SMS code
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/reset-password',
          arguments: {
            'email': widget.email,
            'verificationCode': code,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: ${e.toString()}'),
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
            left: -8.43,
            top: -297.58,
            child: Image.asset(
              'assets/images/bubbles.png',
              width: 566.388,
              height: 620.085,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 566.388,
                  height: 620.085,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    borderRadius: BorderRadius.circular(500),
                  ),
                );
              },
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
                    'Enter 4-digits code we sent you on your phone number',
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

                const SizedBox(height: 15),

                // Phone number (masked)
                Text(
                  _maskedPhone,
                  style: const TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 25),

                // 4-digit code input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (index) {
                      return Container(
                        width: 37,
                        height: 37,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1C6),
                          border: Border.all(
                            color: const Color(0xFF8F7902),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8F7902),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) => _onCodeChanged(index, value),
                          onTap: () {
                            if (_controllers[index].text.isNotEmpty) {
                              _controllers[index].clear();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ),

                const Spacer(),

                // Send Again button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 33.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 61,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSendAgain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: const Color(0xFFF3F3F3),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Send Again',
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
