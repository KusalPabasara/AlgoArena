import 'package:flutter/material.dart';

/// Settings Screen - Exact Figma Implementation 368:1191
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Widget _buildSettingItem({required IconData icon, required String title, String? subtitle, Color? bgColor}) {
    return Container(
      width: 332,
      height: subtitle != null ? 48 : 36,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bgColor ?? const Color(0x1A000000), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.black),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Nunito Sans', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                if (subtitle != null) Text(subtitle, style: const TextStyle(fontFamily: 'Nunito Sans', fontSize: 12, fontWeight: FontWeight.w300, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(right: -100, bottom: 250, child: Container(width: 350, height: 350, decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.28), shape: BoxShape.circle))),
          Positioned(left: -90, top: -80, child: Container(width: 230, height: 230, decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), shape: BoxShape.circle))),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 140,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.black, Color(0xFFFFD700)]),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(left: 10, top: 20, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28), onPressed: () => Navigator.pop(context))),
                      const Positioned(left: 67, top: 58, child: Text('Settings', style: TextStyle(color: Colors.white, fontFamily: 'Raleway', fontSize: 50, fontWeight: FontWeight.bold, letterSpacing: -0.52))),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Notification', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, height: 2.0)),
                        _buildSettingItem(icon: Icons.notifications, title: 'Push Notification', subtitle: 'Manage'),
                        _buildSettingItem(icon: Icons.notifications_off, title: 'Do not disturb', subtitle: 'off'),
                        const SizedBox(height: 15),
                        const Text('App', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, height: 2.0)),
                        _buildSettingItem(icon: Icons.phone_android, title: 'Display Setting'),
                        _buildSettingItem(icon: Icons.privacy_tip, title: 'Privacy Policy'),
                        _buildSettingItem(icon: Icons.description, title: 'Terms and Conditions'),
                        _buildSettingItem(icon: Icons.info, title: 'App version', subtitle: '1.00.0'),
                        _buildSettingItem(icon: Icons.lock, title: 'App Lock', subtitle: 'Disabled'),
                        const SizedBox(height: 15),
                        const Text('Account', style: TextStyle(fontFamily: 'Raleway', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black, height: 2.0)),
                        _buildSettingItem(icon: Icons.security, title: 'Security notifications'),
                        _buildSettingItem(icon: Icons.vpn_key, title: 'Passkeys'),
                        _buildSettingItem(icon: Icons.verified_user, title: 'Two step verification'),
                        _buildSettingItem(icon: Icons.delete_forever, title: 'Delete account', bgColor: const Color(0x1AFF0000)),
                      ],
                    ),
                  ),
                ),
                Center(child: Container(margin: const EdgeInsets.only(bottom: 12), width: 145.848, height: 5.442, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(34)))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
