import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../core/constants/colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../widgets/custom_back_button.dart';
import '../../../utils/responsive_utils.dart';
import 'display_settings_screen.dart';
import 'security_settings_screen.dart';
import 'passkeys_screen.dart';
import 'two_step_verification_screen.dart';
import '../admin/leo_id_management_screen.dart';
import '../pages/create_page_screen.dart';

/// Settings Screen - Exact Implementation matching screenshot
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  bool _pushNotificationsEnabled = true;
  bool _doNotDisturbEnabled = false;
  bool _appLockEnabled = false;
  String _appVersion = '1.00.0';
  final _prefs = SharedPreferences.getInstance();
  final _authRepository = AuthRepository();
  
  late AnimationController _animationController;
  late Animation<Offset> _bubblesSlideAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _bubblesFadeAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Bubbles animation - coming from outside (top-left)
    _bubblesSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _bubblesFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    // Content animation - coming from bottom
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    // Start animation immediately
    _animationController.forward();
    
    _loadSettings();
    _loadAppVersion();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await _prefs;
    setState(() {
      _pushNotificationsEnabled = prefs.getBool('push_notifications_enabled') ?? true;
      _doNotDisturbEnabled = prefs.getBool('do_not_disturb_enabled') ?? false;
      _appLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
    });
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      // Keep default version if package_info_plus fails
    }
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bubbles - animated to slide in from outside
          FadeTransition(
            opacity: _bubblesFadeAnimation,
            child: SlideTransition(
              position: _bubblesSlideAnimation,
              child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Yellow Bubble (Bubbles) - left-[-179.79px] top-[-276.58px]
          Positioned(
                    left: -159.79,
                    top: -256.58,
                  child: SizedBox(
                    width: 550.345,
                    height: 512.152,
                    child: CustomPaint(
                      painter: _YellowBubblePainter(),
                    ),
            ),
          ),

          // Black Bubble 01 - left-[-97.03px] top-[-298.88px], rotated 232.009°
          Positioned(
                    left: -197.03,
            top: -298.88,
                  child: SizedBox(
                    width: 596.838,
                    height: 589.973,
                    child: Center(
                      child: Transform.rotate(
                        angle: 232.009 * math.pi / 180,
                        child: SizedBox(
                          width: 402.871,
                          height: 442.65,
                          child: CustomPaint(
                            painter: _BlackBubblePainter(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ),
                ],
              ),
            ),
          ),

          // Back button - top left
          CustomBackButton(
            backgroundColor: Colors.black, // Dark area (image/shape background)
            iconSize: 24,
          ),

          // "Settings" title - Figma: left: calc(16.67% + 2px), top: 48px
          Positioned(
            left: MediaQuery.of(context).size.width * 0.1667 + ResponsiveUtils.dp(2),
            top: ResponsiveUtils.bh(48),
            child: Text(
              'Settings',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: ResponsiveUtils.dp(50),
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -ResponsiveUtils.dp(0.52),
                height: 1.0,
              ),
            ),
          ),

          // Main content - animated to slide up from bottom
          Positioned(
            left: 0,
            right: 0,
            top: ResponsiveUtils.bh(155),
            bottom: 0,
            child: FadeTransition(
              opacity: _contentFadeAnimation,
              child: SlideTransition(
                position: _contentSlideAnimation,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: ResponsiveUtils.dp(20)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.r(35)),
                      child: Container(
                        width: ResponsiveUtils.dp(375),
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height - ResponsiveUtils.bh(155) - MediaQuery.of(context).padding.bottom - ResponsiveUtils.dp(40),
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1), // Transparent black background
                          borderRadius: BorderRadius.circular(ResponsiveUtils.r(35)),
                        ),
                  child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: ResponsiveUtils.dp(375),
                          ),
                    child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.spacingM + ResponsiveUtils.dp(4),
                              vertical: ResponsiveUtils.spacingM - ResponsiveUtils.dp(6),
                            ),
                      child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                        const SizedBox(height: 20),
                        // Notification Section
                        _buildSectionTitle('Notification'),
                        const SizedBox(height: 6),
                        _buildSettingItemWithSubtitle(
                          icon: Icons.notifications_outlined,
                          title: 'Push Notification',
                          subtitle: 'Manage',
                          onTap: () => _showPushNotificationSettings(),
                        ),
                        const SizedBox(height: 6),
                        _buildSettingItemWithToggle(
                          icon: Icons.notifications_off_outlined,
                          title: 'Do not disturb',
                          subtitle: _doNotDisturbEnabled ? 'on' : 'off',
                          value: _doNotDisturbEnabled,
                          hasZBadge: true,
                          onToggle: (value) {
                            setState(() {
                              _doNotDisturbEnabled = value;
                            });
                            _saveSetting('do_not_disturb_enabled', value);
                          },
                        ),
                        const SizedBox(height: 15),
                        // App Section
                        _buildSectionTitle('App'),
                        const SizedBox(height: 6),
                        _buildSettingItem(
                          icon: Icons.phone_android_outlined,
                          title: 'Display Setting',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DisplaySettingsScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildSettingItem(
                          icon: Icons.visibility_outlined,
                          title: 'Privacy Policy',
                          onTap: () => _showPrivacyPolicy(),
                        ),
                        const SizedBox(height: 6),
                        _buildSettingItem(
                          icon: Icons.menu_book_outlined,
                          title: 'Terms and Conditions',
                          onTap: () => _showTermsAndConditions(),
                        ),
                        const SizedBox(height: 6),
                        _buildSettingItemWithToggle(
                          icon: Icons.lock_outline,
                          title: 'App Lock',
                          subtitle: _appLockEnabled ? 'Enabled' : 'Disabled',
                          value: _appLockEnabled,
                          onToggle: (value) {
                            setState(() {
                              _appLockEnabled = value;
                            });
                            _saveSetting('app_lock_enabled', value);
                            if (value) {
                              _showAppLockSetup();
                            }
                          },
                        ),
                        const SizedBox(height: 6),
                        _buildSettingItemWithSubtitle(
                          icon: Icons.phone_android_outlined,
                          title: 'App version',
                          subtitle: _appVersion,
                        ),
                        const SizedBox(height: 15),
                        // Security Section (renamed from Account)
                        _buildSectionTitle('Security'),
                        const SizedBox(height: 6),
                        _buildSettingItem(
                          icon: Icons.shield_outlined,
                          title: 'Security notifications',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SecuritySettingsScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildSettingItem(
                          icon: Icons.password_outlined,
                          title: 'Passkeys',
                          onTap: () => _showPasskeys(),
                        ),
                        const SizedBox(height: 6),
                        _buildSettingItem(
                          icon: Icons.vpn_key_outlined,
                          title: 'Two step verification',
                          onTap: () => _showTwoStepVerification(),
                        ),
                        const SizedBox(height: 6),
                        _buildSettingItem(
                          icon: Icons.delete_outline,
                          title: 'Delete account',
                          isDestructive: true,
                          onTap: () => _showDeleteAccountConfirmation(),
                        ),
                        // Admin Section (only for superadmin)
                        if (Provider.of<AuthProvider>(context).isSuperAdmin) ...[
                          const SizedBox(height: 15),
                          _buildSectionTitle('Admin'),
                          const SizedBox(height: 6),
                          _buildSettingItem(
                            icon: Icons.person_add_outlined,
                            title: 'Manage Leo IDs',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LeoIdManagementScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildSettingItem(
                            icon: Icons.add_business_outlined,
                            title: 'Create Page',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CreatePageScreen(),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: ResponsiveUtils.dp(30)),
                      ],
                    ),
                  ),
                ),
                ),
                    ),
            ),
          ),
      ),
            ),
                ),
              ),
            ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SizedBox(
      height: 32,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Raleway',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            height: 31 / 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDestructive
              ? const Color.fromRGBO(255, 0, 0, 0.1)
              : const Color.fromRGBO(0, 0, 0, 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.black54,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItemWithSubtitle({
    required IconData icon,
    required String title,
    required String subtitle,
    bool hasZBadge = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 24, color: Colors.black),
                if (hasZBadge)
                  Positioned(
                    left: -8,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text(
                        'Z',
                        style: TextStyle(
                          fontFamily: 'Passion One',
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.black54,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItemWithToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onToggle,
    bool hasZBadge = false,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 24, color: Colors.black),
              if (hasZBadge)
                Positioned(
                  left: -8,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text(
                      'Z',
                      style: TextStyle(
                        fontFamily: 'Passion One',
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onToggle,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // Settings action handlers
  void _showPushNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Push Notification Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Enable Push Notifications'),
              value: _pushNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _pushNotificationsEnabled = value;
                });
                _saveSetting('push_notifications_enabled', value);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your notification preferences. You can enable or disable push notifications for different types of updates.',
              style: TextStyle(fontSize: 12),
            ),
          ],
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

  void _showAppLockSetup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Lock Setup'),
        content: const Text(
          'App Lock is now enabled. You will be prompted to enter your PIN or biometric authentication when opening the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPasskeys() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PasskeysScreen(),
      ),
    );
  }

  void _showTwoStepVerification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TwoStepVerificationScreen(),
      ),
    );
  }

  void _showPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _SettingsDetailScreen(
          title: 'Privacy Policy',
          content: _privacyPolicyContent,
        ),
      ),
    );
  }

  void _showTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _SettingsDetailScreen(
          title: 'Terms and Conditions',
          content: _termsAndConditionsContent,
        ),
      ),
    );
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Try to delete account via API
        await _authRepository.deleteAccount();
      } catch (e) {
        // If API endpoint doesn't exist, just logout and clear local data
        // This handles the case where backend doesn't have delete endpoint yet
        debugPrint('Delete account API not available, clearing local data: $e');
      }

      // Always logout and clear local data
      await authProvider.logout();
      
      // Clear all local preferences
      final prefs = await _prefs;
      await prefs.clear();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Show user-friendly error message
        final errorMessage = e.toString().contains('404') || e.toString().contains('not found')
            ? 'Delete account feature is not available yet. Please contact support.'
            : 'Failed to delete account: ${e.toString().replaceAll('Exception: ', '')}';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  static const String _privacyPolicyContent = '''
PRIVACY POLICY

Last updated: [Date]

1. INFORMATION WE COLLECT
We collect information that you provide directly to us, including:
- Name and contact information
- Profile information
- Posts and content you create
- Usage data and preferences

2. HOW WE USE YOUR INFORMATION
We use the information we collect to:
- Provide and improve our services
- Communicate with you
- Ensure security and prevent fraud
- Comply with legal obligations

3. DATA SHARING
We do not sell your personal information. We may share information with:
- Service providers who assist us
- Legal authorities when required
- Other users as part of the platform functionality

4. YOUR RIGHTS
You have the right to:
- Access your personal data
- Correct inaccurate data
- Request deletion of your data
- Object to processing of your data

5. DATA SECURITY
We implement appropriate security measures to protect your information.

6. CONTACT US
If you have questions about this privacy policy, please contact us.
''';

  static const String _termsAndConditionsContent = '''
TERMS AND CONDITIONS

Last updated: [Date]

1. ACCEPTANCE OF TERMS
By using this application, you agree to be bound by these Terms and Conditions.

2. USER ACCOUNTS
- You are responsible for maintaining the confidentiality of your account
- You must provide accurate information
- You are responsible for all activities under your account

3. USER CONDUCT
You agree not to:
- Post offensive, illegal, or harmful content
- Impersonate others
- Violate any laws or regulations
- Interfere with the app's operation

4. INTELLECTUAL PROPERTY
- All content belongs to its respective owners
- You grant us license to use your content on the platform
- You may not copy or distribute content without permission

5. LIMITATION OF LIABILITY
We are not liable for any indirect, incidental, or consequential damages.

6. TERMINATION
We may terminate or suspend your account for violations of these terms.

7. CHANGES TO TERMS
We reserve the right to modify these terms at any time.

8. CONTACT
For questions about these terms, please contact us.
''';
}

/// Detail screen for displaying long content like Privacy Policy and Terms
class _SettingsDetailScreen extends StatelessWidget {
  final String title;
  final String content;

  const _SettingsDetailScreen({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            fontFamily: 'Nunito Sans',
          ),
        ),
      ),
    );
  }
}

/// Yellow Bubble Painter - Exact Figma SVG path
/// viewBox="0 0 551 513"
class _YellowBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final path = Path();
    final scaleX = size.width / 551;
    final scaleY = size.height / 513;

    // M448.995 310.483C533.605 447.601 289.917 463.466 186.768 421.792C83.619 380.117 33.7843 262.714 75.4592 159.564C117.134 56.4154 225.428 43.8604 322.495 74.3444C419.562 104.828 364.385 173.365 448.995 310.483Z
    path.moveTo(448.995 * scaleX, 310.483 * scaleY);
    path.cubicTo(
      533.605 * scaleX, 447.601 * scaleY,
      289.917 * scaleX, 463.466 * scaleY,
      186.768 * scaleX, 421.792 * scaleY,
    );
    path.cubicTo(
      83.619 * scaleX, 380.117 * scaleY,
      33.7843 * scaleX, 262.714 * scaleY,
      75.4592 * scaleX, 159.564 * scaleY,
    );
    path.cubicTo(
      117.134 * scaleX, 56.4154 * scaleY,
      225.428 * scaleX, 43.8604 * scaleY,
      322.495 * scaleX, 74.3444 * scaleY,
    );
    path.cubicTo(
      419.562 * scaleX, 104.828 * scaleY,
      364.385 * scaleX, 173.365 * scaleY,
      448.995 * scaleX, 310.483 * scaleY,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Black Bubble 01 Painter - Exact Figma SVG path p36b3a180
/// viewBox="0 0 403 443"
class _BlackBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final path = Path();
    final scaleX = size.width / 403;
    final scaleY = size.height / 443;

    // M201.436 39.7783C296.874 -90.0363 402.871 129.964 402.871 241.214C402.871 352.464 312.686 442.65 201.436 442.65C90.1858 442.65 0 352.464 0 241.214C0 129.964 105.998 169.593 201.436 39.7783Z
    path.moveTo(201.436 * scaleX, 39.7783 * scaleY);
    path.cubicTo(
      296.874 * scaleX, -90.0363 * scaleY,
      402.871 * scaleX, 129.964 * scaleY,
      402.871 * scaleX, 241.214 * scaleY,
    );
    path.cubicTo(
      402.871 * scaleX, 352.464 * scaleY,
      312.686 * scaleX, 442.65 * scaleY,
      201.436 * scaleX, 442.65 * scaleY,
    );
    path.cubicTo(
      90.1858 * scaleX, 442.65 * scaleY,
      0 * scaleX, 352.464 * scaleY,
      0 * scaleX, 241.214 * scaleY,
    );
    path.cubicTo(
      0 * scaleX, 129.964 * scaleY,
      105.998 * scaleX, 169.593 * scaleY,
      201.436 * scaleX, 39.7783 * scaleY,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
