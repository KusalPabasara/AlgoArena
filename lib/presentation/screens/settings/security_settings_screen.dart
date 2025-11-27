import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';

/// Security Settings Screen - Full implementation
class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({Key? key}) : super(key: key);

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _securityNotificationsEnabled = true;
  bool _loginAlertsEnabled = true;
  bool _passwordChangeAlertsEnabled = true;
  bool _suspiciousActivityAlertsEnabled = true;
  final _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  Future<void> _loadSecuritySettings() async {
    final prefs = await _prefs;
    setState(() {
      _securityNotificationsEnabled = prefs.getBool('security_notifications_enabled') ?? true;
      _loginAlertsEnabled = prefs.getBool('login_alerts_enabled') ?? true;
      _passwordChangeAlertsEnabled = prefs.getBool('password_change_alerts_enabled') ?? true;
      _suspiciousActivityAlertsEnabled = prefs.getBool('suspicious_activity_alerts_enabled') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Security notifications alert you about important security events related to your account.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          
          // Main toggle
          Card(
            child: SwitchListTile(
              title: const Text(
                'Security Notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text('Enable or disable all security notifications'),
              value: _securityNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _securityNotificationsEnabled = value;
                  // If disabling main toggle, disable all sub-options
                  if (!value) {
                    _loginAlertsEnabled = false;
                    _passwordChangeAlertsEnabled = false;
                    _suspiciousActivityAlertsEnabled = false;
                  } else {
                    // If enabling, enable all by default
                    _loginAlertsEnabled = true;
                    _passwordChangeAlertsEnabled = true;
                    _suspiciousActivityAlertsEnabled = true;
                  }
                });
                _saveSetting('security_notifications_enabled', value);
                _saveSetting('login_alerts_enabled', _loginAlertsEnabled);
                _saveSetting('password_change_alerts_enabled', _passwordChangeAlertsEnabled);
                _saveSetting('suspicious_activity_alerts_enabled', _suspiciousActivityAlertsEnabled);
              },
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Sub-options (only shown if main toggle is enabled)
          if (_securityNotificationsEnabled) ...[
            _buildSectionTitle('Notification Types'),
            const SizedBox(height: 8),
            
            Card(
              child: SwitchListTile(
                title: const Text('Login Attempts'),
                subtitle: const Text('Get notified when someone logs into your account from a new device'),
                value: _loginAlertsEnabled,
                onChanged: (value) {
                  setState(() => _loginAlertsEnabled = value);
                  _saveSetting('login_alerts_enabled', value);
                },
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            
            Card(
              child: SwitchListTile(
                title: const Text('Password Changes'),
                subtitle: const Text('Get notified when your password is changed'),
                value: _passwordChangeAlertsEnabled,
                onChanged: (value) {
                  setState(() => _passwordChangeAlertsEnabled = value);
                  _saveSetting('password_change_alerts_enabled', value);
                },
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            
            Card(
              child: SwitchListTile(
                title: const Text('Suspicious Activity'),
                subtitle: const Text('Get notified about unusual account activity'),
                value: _suspiciousActivityAlertsEnabled,
                onChanged: (value) {
                  setState(() => _suspiciousActivityAlertsEnabled = value);
                  _saveSetting('suspicious_activity_alerts_enabled', value);
                },
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Information section
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'About Security Notifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Security notifications help protect your account by alerting you to important security events. We recommend keeping these enabled.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

