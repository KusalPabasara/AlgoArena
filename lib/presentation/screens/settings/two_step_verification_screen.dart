import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:otp/otp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/colors.dart';

/// Two-Step Verification Screen - Full implementation with TOTP
class TwoStepVerificationScreen extends StatefulWidget {
  const TwoStepVerificationScreen({Key? key}) : super(key: key);

  @override
  State<TwoStepVerificationScreen> createState() => _TwoStepVerificationScreenState();
}

class _TwoStepVerificationScreenState extends State<TwoStepVerificationScreen> {
  final _secureStorage = const FlutterSecureStorage();
  final _prefs = SharedPreferences.getInstance();
  
  bool _is2FAEnabled = false;
  bool _isLoading = false;
  bool _isSetupMode = false;
  String? _secretKey;
  String? _qrCodeData;
  List<String> _backupCodes = [];
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load2FAStatus();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _load2FAStatus() async {
    final prefs = await _prefs;
    final enabled = prefs.getBool('2fa_enabled') ?? false;
    setState(() {
      _is2FAEnabled = enabled;
    });
  }

  Future<void> _save2FAStatus(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool('2fa_enabled', enabled);
  }

  Future<void> _generateSecretKey() async {
    // Generate a random secret key (32 characters base32)
    final random = Random.secure();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'; // Base32 alphabet
    final secretKey = String.fromCharCodes(
      Iterable.generate(
        32,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );

    setState(() {
      _secretKey = secretKey;
      _isSetupMode = true;
    });

    // Store secret key securely
    await _secureStorage.write(key: '2fa_secret', value: secretKey);

    // Generate QR code data (TOTP URI format)
    // In a real app, you'd use the user's email and app name
    _qrCodeData = 'otpauth://totp/AlgoArena:user@example.com?secret=$secretKey&issuer=AlgoArena&algorithm=SHA1&digits=6&period=30';

    // Generate backup codes
    _generateBackupCodes();
  }

  void _generateBackupCodes() {
    final random = Random.secure();
    _backupCodes = List.generate(10, (_) {
      // Generate 8-digit backup codes
      return (10000000 + random.nextInt(90000000)).toString();
    });
    
    // Store backup codes securely
    _secureStorage.write(
      key: '2fa_backup_codes',
      value: _backupCodes.join(','),
    );
  }

  Future<void> _verifyAndEnable() async {
    final code = _codeController.text.trim();
    
    if (code.length != 6) {
      _showError('Please enter a valid 6-digit code');
      return;
    }

    if (_secretKey == null) {
      _showError('Secret key not found. Please restart setup.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Verify the code (also check previous and next 30-second windows for clock skew)
      final now = DateTime.now().millisecondsSinceEpoch;
      final codes = [
        OTP.generateTOTPCodeString(_secretKey!, now, algorithm: Algorithm.SHA1, isGoogle: true),
        OTP.generateTOTPCodeString(_secretKey!, now - 30000, algorithm: Algorithm.SHA1, isGoogle: true),
        OTP.generateTOTPCodeString(_secretKey!, now + 30000, algorithm: Algorithm.SHA1, isGoogle: true),
      ];

      if (codes.contains(code)) {
        await _save2FAStatus(true);
        
        setState(() {
          _is2FAEnabled = true;
          _isSetupMode = false;
          _isLoading = false;
        });

        _codeController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Two-step verification enabled successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        _showError('Invalid code. Please try again.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Verification failed: ${e.toString()}');
    }
  }

  Future<void> _disable2FA() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Two-Step Verification'),
        content: const Text(
          'Are you sure you want to disable two-step verification? Your account will be less secure.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disable'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        // Verify with a code before disabling
        final code = await _showCodeInputDialog('Enter your verification code to disable 2FA');
        
        if (code != null && code.length == 6) {
          final secretKey = await _secureStorage.read(key: '2fa_secret');
          if (secretKey != null) {
            final now = DateTime.now().millisecondsSinceEpoch;
            final codes = [
              OTP.generateTOTPCodeString(secretKey, now, algorithm: Algorithm.SHA1, isGoogle: true),
              OTP.generateTOTPCodeString(secretKey, now - 30000, algorithm: Algorithm.SHA1, isGoogle: true),
              OTP.generateTOTPCodeString(secretKey, now + 30000, algorithm: Algorithm.SHA1, isGoogle: true),
            ];

            if (codes.contains(code)) {
              await _secureStorage.delete(key: '2fa_secret');
              await _secureStorage.delete(key: '2fa_backup_codes');
              await _save2FAStatus(false);

              setState(() {
                _is2FAEnabled = false;
                _isSetupMode = false;
                _isLoading = false;
                _secretKey = null;
                _qrCodeData = null;
                _backupCodes = [];
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Two-step verification disabled')),
                );
              }
            } else {
              setState(() => _isLoading = false);
              _showError('Invalid code. Please try again.');
            }
          }
        } else {
          setState(() => _isLoading = false);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showError('Failed to disable 2FA: ${e.toString()}');
      }
    }
  }

  Future<String?> _showCodeInputDialog(String title) async {
    final codeController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: '6-digit code',
            hintText: '000000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, codeController.text),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBackupCodes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Codes'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Save these backup codes in a safe place. You can use them to sign in if you lose access to your authenticator app.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ..._backupCodes.map((code) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      code,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
            ],
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Step Verification'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.security, color: Colors.blue.shade700, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Two-Step Verification',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Add an extra layer of security to your account. You\'ll need to enter a verification code from your authenticator app when signing in.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Status Card
                Card(
                  child: SwitchListTile(
                    title: const Text(
                      'Two-Step Verification',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _is2FAEnabled
                          ? 'Two-step verification is enabled'
                          : 'Two-step verification is disabled',
                    ),
                    value: _is2FAEnabled,
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            if (value) {
                              _generateSecretKey();
                            } else {
                              _disable2FA();
                            }
                          },
                    activeColor: AppColors.primary,
                  ),
                ),

                // Setup Mode - QR Code and Verification
                if (_isSetupMode && _qrCodeData != null) ...[
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Step 1: Scan QR Code',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Open your authenticator app (Google Authenticator, Authy, etc.) and scan this QR code:',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: QrImageView(
                                data: _qrCodeData!,
                                version: QrVersions.auto,
                                size: 200,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Or enter this code manually:',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SelectableText(
                              _secretKey!,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Step 2: Verify Code',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter the 6-digit code from your authenticator app:',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: InputDecoration(
                              labelText: 'Verification Code',
                              hintText: '000000',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.lock_outline),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _verifyAndEnable,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Verify and Enable'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Backup Codes
                if (_is2FAEnabled && _backupCodes.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange.shade700),
                              const SizedBox(width: 8),
                              const Text(
                                'Backup Codes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Save these backup codes in a safe place. You can use them to sign in if you lose access to your authenticator app.',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _showBackupCodes,
                            icon: const Icon(Icons.visibility),
                            label: const Text('View Backup Codes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Information Card
                const SizedBox(height: 24),
                Card(
                  color: Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'How It Works',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Download an authenticator app (Google Authenticator, Authy, Microsoft Authenticator)\n'
                          '• Scan the QR code or enter the secret key manually\n'
                          '• Enter the 6-digit code from the app to verify\n'
                          '• You\'ll need to enter a code every time you sign in\n'
                          '• Save your backup codes in case you lose access to your device',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

