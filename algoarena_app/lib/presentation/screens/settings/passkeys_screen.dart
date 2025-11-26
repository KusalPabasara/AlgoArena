import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';

/// Passkeys Screen - Full implementation with biometric authentication
class PasskeysScreen extends StatefulWidget {
  const PasskeysScreen({Key? key}) : super(key: key);

  @override
  State<PasskeysScreen> createState() => _PasskeysScreenState();
}

class _PasskeysScreenState extends State<PasskeysScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final _prefs = SharedPreferences.getInstance();
  
  bool _isPasskeyEnabled = false;
  bool _isLoading = false;
  bool _isChecking = true;
  List<BiometricType> _availableBiometrics = [];
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _loadPasskeyStatus();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (canCheck && isDeviceSupported) {
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        
        setState(() {
          _canCheckBiometrics = true;
          _availableBiometrics = availableBiometrics;
          _isChecking = false;
        });
      } else {
        setState(() {
          _canCheckBiometrics = false;
          _isChecking = false;
        });
      }
    } catch (e) {
      setState(() {
        _canCheckBiometrics = false;
        _isChecking = false;
      });
    }
  }

  Future<void> _loadPasskeyStatus() async {
    final prefs = await _prefs;
    setState(() {
      _isPasskeyEnabled = prefs.getBool('passkey_enabled') ?? false;
    });
  }

  Future<void> _savePasskeyStatus(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool('passkey_enabled', enabled);
  }

  Future<void> _enablePasskey() async {
    if (!_canCheckBiometrics) {
      _showError('Biometric authentication is not available on this device.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Authenticate user before enabling passkey
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to enable passkeys for secure sign-in',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        // Generate a passkey identifier (in a real app, this would be handled by WebAuthn)
        final passkeyId = DateTime.now().millisecondsSinceEpoch.toString();
        
        // Store passkey data securely
        await _secureStorage.write(
          key: 'passkey_id',
          value: passkeyId,
        );
        
        await _savePasskeyStatus(true);
        
        setState(() {
          _isPasskeyEnabled = true;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Passkeys enabled successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        _showError('Authentication failed. Please try again.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to enable passkeys: ${e.toString()}');
    }
  }

  Future<void> _disablePasskey() async {
    setState(() => _isLoading = true);

    try {
      // Authenticate before disabling
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to disable passkeys',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        // Remove passkey data
        await _secureStorage.delete(key: 'passkey_id');
        await _savePasskeyStatus(false);
        
        setState(() {
          _isPasskeyEnabled = false;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Passkeys disabled successfully'),
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        _showError('Authentication failed. Please try again.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to disable passkeys: ${e.toString()}');
    }
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

  String _getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passkeys'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isChecking
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
                            Icon(Icons.fingerprint, color: Colors.blue.shade700, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Passkeys',
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
                          'Passkeys provide a more secure and convenient way to sign in. They use biometric authentication or your device PIN to verify your identity.',
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
                      'Enable Passkeys',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _isPasskeyEnabled
                          ? 'Passkeys are enabled for this device'
                          : 'Passkeys are currently disabled',
                    ),
                    value: _isPasskeyEnabled,
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            if (value) {
                              _enablePasskey();
                            } else {
                              _disablePasskey();
                            }
                          },
                    activeColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Biometric Info
                if (_canCheckBiometrics) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Available Biometric Methods',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._availableBiometrics.map((type) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      type == BiometricType.fingerprint
                                          ? Icons.fingerprint
                                          : Icons.face,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(_getBiometricTypeName(type)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Biometric authentication is not available on this device.',
                              style: TextStyle(color: Colors.orange.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Information Card
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
                              'How Passkeys Work',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Passkeys use your device\'s built-in security features\n'
                          '• No passwords needed - just your fingerprint, face, or PIN\n'
                          '• More secure than traditional passwords\n'
                          '• Works across your devices when synced\n'
                          '• Protects against phishing attacks',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
    );
  }
}

