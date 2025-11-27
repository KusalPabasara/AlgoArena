import 'package:flutter/material.dart';

/// Settings Screen - Exact Figma Implementation from Settings.tsx
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background bubbles - Yellow bubble (bubble 02) from Figma with fade-in transition
          Positioned(
            left: -89,
            top: -215,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, opacity, child) {
                return Opacity(
                  opacity: opacity,
                  child: child,
                );
              },
              child: SizedBox(
                width: 456.112,
                height: 389.587,
                child: CustomPaint(
                  painter: _YellowBubblePainter(),
                ),
              ),
            ),
          ),
          // Black bubble (bubble 01) - rotated 229.834deg with fade-in transition
          Positioned(
            left: -200,
            top: -317,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, opacity, child) {
                return Opacity(
                  opacity: opacity,
                  child: child,
                );
              },
              child: Transform.rotate(
                angle: 229.834 * 3.14159 / 180,
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
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header with back button and title
                _buildHeader(context),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Notification Section
                          _buildSectionTitle('Notification'),
                          const SizedBox(height: 6),
                          _buildSettingItemWithSubtitle(
                            icon: Icons.notifications_outlined,
                            title: 'Push Notification',
                            subtitle: 'Manage',
                          ),
                          const SizedBox(height: 6),
                          _buildSettingItemWithSubtitle(
                            icon: Icons.notifications_off_outlined,
                            title: 'Do not disturb',
                            subtitle: 'off',
                            hasZBadge: true,
                          ),
                          const SizedBox(height: 15),
                          // App Section
                          _buildSectionTitle('App'),
                          const SizedBox(height: 6),
                          _buildSettingItem(
                            icon: Icons.phone_android_outlined,
                            title: 'Display Setting',
                          ),
                          const SizedBox(height: 6),
                          _buildSettingItem(
                            icon: Icons.visibility_outlined,
                            title: 'Privacy Policy',
                          ),
                          const SizedBox(height: 6),
                          _buildSettingItem(
                            icon: Icons.menu_book_outlined,
                            title: 'Terms and Conditions',
                          ),
                          const SizedBox(height: 6),
                          _buildSettingItemWithSubtitle(
                            icon: Icons.lock_outline,
                            title: 'App Lock',
                            subtitle: 'Disabled',
                          ),
                          const SizedBox(height: 6),
                          _buildSettingItemWithSubtitle(
                            icon: Icons.phone_android_outlined,
                            title: 'App version',
                            subtitle: '1.00.0',
                          ),
                          const SizedBox(height: 15),
                          // Account Section
                          _buildSectionTitle('Account'),
                          const SizedBox(height: 6),
                          _buildSettingItem(
                            icon: Icons.shield_outlined,
                            title: 'Security notifications',
                          ),
                          const SizedBox(height: 6),
                          _buildSettingItem(
                            icon: Icons.password_outlined,
                            title: 'Passkeys',
                          ),
                          const SizedBox(height: 6),
                          _buildSettingItem(
                            icon: Icons.vpn_key_outlined,
                            title: 'Two step verification',
                          ),
                          const SizedBox(height: 6),
                          _buildSettingItem(
                            icon: Icons.delete_outline,
                            title: 'Delete account',
                            isDestructive: true,
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom bar indicator - Figma: w: 145.848px, h: 5.442px, rounded: 34px
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    width: 145.848,
                    height: 5.442,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(34),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.only(left: 10, top: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back button - Figma: left: 10px, top: 50px, 50x53px
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 50,
              height: 53,
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 9),
          // Settings title - Figma: Raleway Bold 50px, white, tracking: -0.52px
          const Text(
            'Settings',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 50,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.52,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    // Figma: Raleway Bold 12px, black, height: 32px, leading: 31px
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
  }) {
    // Figma: h: 36px, w: 332px, bg: rgba(0,0,0,0.1), rounded: 10px
    // For destructive: bg: rgba(255,0,0,0.1)
    return Container(
      width: 332,
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
        ],
      ),
    );
  }

  Widget _buildSettingItemWithSubtitle({
    required IconData icon,
    required String title,
    required String subtitle,
    bool hasZBadge = false,
  }) {
    // Figma: h: 48px, w: 332px, bg: rgba(0,0,0,0.1), rounded: 10px
    return Container(
      width: 332,
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
                const Positioned(
                  left: -8,
                  top: 2,
                  child: Text(
                    'Z',
                    style: TextStyle(
                      fontFamily: 'Passion One',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
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
                // Title - Figma: Nunito Sans Bold 12px
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
                // Subtitle - Figma: Nunito Sans Light 12px
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
        ],
      ),
    );
  }
}

/// Yellow bubble painter - path p15c6d040 from svg-t2hpb5aleg.ts
class _YellowBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    // Figma SVG path scaled to size
    final double scaleX = size.width / 457;
    final double scaleY = size.height / 390;

    final path = Path();
    path.moveTo(408.939 * scaleX, 173.445 * scaleY);
    path.cubicTo(
      542.181 * scaleX, 264.035 * scaleY,
      326.236 * scaleX, 378.066 * scaleY,
      215.061 * scaleX, 382.165 * scaleY,
    );
    path.cubicTo(
      103.887 * scaleX, 386.264 * scaleY,
      10.4396 * scaleX, 299.462 * scaleY,
      6.34072 * scaleX, 188.288 * scaleY,
    );
    path.cubicTo(
      2.24182 * scaleX, 77.1137 * scaleY,
      95.9588 * scaleX, 21.4144 * scaleY,
      197.01 * scaleX, 9.5856 * scaleY,
    );
    path.cubicTo(
      298.061 * scaleX, -2.24323 * scaleY,
      275.696 * scaleX, 82.8541 * scaleY,
      408.939 * scaleX, 173.445 * scaleY,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Black bubble painter - path p36b3a180 from svg-t2hpb5aleg.ts
class _BlackBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Figma SVG path scaled to size
    final double scaleX = size.width / 403;
    final double scaleY = size.height / 443;

    final path = Path();
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
