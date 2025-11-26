import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Notifications Screen - Exact Figma Implementation
/// Source: notification/src/imports/Notifications.tsx
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Yellow Bubble (Bubbles) - left-[-179.79px] top-[-276.58px]
            // viewBox="0 0 551 513" - pf4ece00
            Positioned(
              left: -179.79,
              top: -276.58,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: SizedBox(
                      width: 550.345,
                      height: 512.152,
                      child: CustomPaint(
                        painter: _YellowBubblePainter(),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Black Bubble 01 - left-[-97.03px] top-[-298.88px], rotated 232.009°
            // viewBox="0 0 403 443" - p36b3a180
            Positioned(
              left: -97.03,
              top: -298.88,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
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
                  );
                },
              ),
            ),

            // Back button - left-[10px] top-[50px]
            Positioned(
              left: 10,
              top: 50,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: SizedBox(
                  width: 50,
                  height: 53,
                  child: Image.asset(
                    'assets/images/notifications/a6c3b1de0238b60ae5f0966181a9108216c6d648.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // "Notifications" title - left-[calc(16.67%+2px)] top-[48px]
            Positioned(
              left: screenWidth * 0.1667 + 2,
              top: 48,
              child: const Text(
                'Notifications',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.52,
                ),
              ),
            ),

            // Announcement Section Header - top-[168px]
            Positioned(
              left: screenWidth * 0.0833 + 1.5,
              top: 168,
              child: const SizedBox(
                width: 332,
                height: 32,
                child: Text(
                  'Announcement :',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 31 / 26,
                  ),
                ),
              ),
            ),

            // Announcement Frame - top-[210px]
            Positioned(
              left: screenWidth * 0.0833 + 1.5,
              top: 210,
              child: SizedBox(
                width: 332,
                height: 143,
                child: Column(
                  children: [
                    _buildNotificationCard(
                      'Monthly meeting schedule for November is now available.',
                      'assets/images/notifications/4cab12f568771ad0b3afa40dc378bc7ed480eb86.png',
                    ),
                    const SizedBox(height: 11),
                    _buildNotificationCard(
                      'Attendance policy updated — please read the new guidelines.',
                      'assets/images/notifications/31d07557884264b1b070f971cc49466a561b5a39.png',
                    ),
                  ],
                ),
              ),
            ),

            // See more button for Announcement - top-[363px]
            Positioned(
              left: screenWidth * 0.0833 + 1.5,
              top: 363,
              child: _buildSeeMoreButton(),
            ),

            // News Section Header - top-[422px]
            Positioned(
              left: screenWidth * 0.0833 + 1.5,
              top: 422,
              child: const SizedBox(
                width: 332,
                height: 32,
                child: Text(
                  'News :',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 31 / 26,
                  ),
                ),
              ),
            ),

            // News Frame - top-[464px]
            Positioned(
              left: screenWidth * 0.0833 + 1.5,
              top: 464,
              child: _buildNotificationCardRich(
                'Leo Club of Colombo',
                ' recognized as Best Community Service Club 2025!',
                'assets/images/notifications/c6d5f9dff52b37a28977be041de113bc88dfa388.png',
              ),
            ),

            // See more button for News - top-[540px]
            Positioned(
              left: screenWidth * 0.0833 + 1.5,
              top: 540,
              child: _buildSeeMoreButton(),
            ),

            // Notifications Section Header - top-[599px]
            Positioned(
              left: screenWidth * 0.0833 + 1.5,
              top: 599,
              child: const SizedBox(
                width: 332,
                height: 32,
                child: Text(
                  'Notifications :',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 31 / 26,
                  ),
                ),
              ),
            ),

            // Notifications Frame - top-[641px]
            Positioned(
              left: screenWidth * 0.0833 + 1.5,
              top: 641,
              child: SizedBox(
                width: 332,
                height: 143,
                child: Column(
                  children: [
                    _buildNotificationCard(
                      "Membership renewal due soon. Don't forget to renew before Nov 15",
                      'assets/images/notifications/4816b29d2caebc6a6bd478c7c78d68fe9b858b82.png',
                    ),
                    const SizedBox(height: 11),
                    _buildNotificationCard(
                      'New message from Club President.',
                      'assets/images/notifications/6cd6f189d2f86fcc32f0d234e0416b42a8dcf4dd.png',
                    ),
                  ],
                ),
              ),
            ),

            // See more button for Notifications - top-[794px]
            Positioned(
              left: screenWidth * 0.0833 + 1.5,
              top: 794,
              child: _buildSeeMoreButton(),
            ),

            // Bottom bar - left-[calc(33.33%-3px)] top-[863px]
            Positioned(
              left: screenWidth * 0.3333 - 3,
              top: 863,
              child: Container(
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
    );
  }

  Widget _buildNotificationCard(String text, String avatarImage) {
    return Container(
      width: 332,
      height: 66,
      decoration: BoxDecoration(
        color: const Color(0x1A000000), // rgba(0,0,0,0.1)
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const SizedBox(width: 9),
          // Avatar with drop shadow and image - 46x46
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: 5,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Ellipse background - #8F7902
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF8F7902),
                  ),
                ),
                // Avatar image
                ClipOval(
                  child: Image.asset(
                    avatarImage,
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF8F7902),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Text - ml-[61px] mt-[21px] w-[255px]
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10, top: 9, bottom: 9),
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCardRich(String boldText, String normalText, String avatarImage) {
    return Container(
      width: 332,
      height: 66,
      decoration: BoxDecoration(
        color: const Color(0x1A000000), // rgba(0,0,0,0.1)
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const SizedBox(width: 9),
          // Avatar with drop shadow and image
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: 5,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF8F7902),
                  ),
                ),
                ClipOval(
                  child: Image.asset(
                    avatarImage,
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF8F7902),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Text with rich formatting
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10, top: 9, bottom: 9),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: boldText,
                      style: const TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        height: 1.0,
                      ),
                    ),
                    TextSpan(
                      text: normalText,
                      style: const TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.0,
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

  Widget _buildSeeMoreButton() {
    return Container(
      width: 332,
      height: 39,
      decoration: BoxDecoration(
        color: const Color(0xFFE6E6E6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Text(
          'See more...',
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 31 / 15,
          ),
        ),
      ),
    );
  }
}

/// Yellow Bubble Painter - Exact Figma SVG path pf4ece00
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
